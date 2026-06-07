#!/usr/bin/env bash
set -euo pipefail

APP_NAME="${APP_NAME:-bidding-system}"
DEPLOY_DIR="${DEPLOY_DIR:-/opt/bidding-system}"
COMPOSE_CMD="${COMPOSE_CMD:-docker compose}"
BACKUP_TIME="$(date +%Y%m%d%H%M%S)"
BACKUP_DIR="${DEPLOY_DIR}/backup/${BACKUP_TIME}"
SKIP_GIT_PULL="${SKIP_GIT_PULL:-0}"
SKIP_DB_BACKUP="${SKIP_DB_BACKUP:-0}"
OVERWRITE_SQL="${OVERWRITE_SQL:-auto}"
NGINX_HTTP_PORT="${NGINX_HTTP_PORT:-80}"

log() {
  echo "[INFO] $1"
}

warn() {
  echo "[WARN] $1"
}

err() {
  echo "[ERROR] $1" >&2
  exit 1
}

usage() {
  cat <<'EOF'
用法：
  bash scripts/prod-deploy.sh
  bash scripts/prod-deploy.sh yes   # 覆盖 data/sql/init.sql
  bash scripts/prod-deploy.sh no    # 不覆盖 data/sql/init.sql

可选环境变量：
  DEPLOY_DIR=/opt/bidding-system bash scripts/prod-deploy.sh
  SKIP_GIT_PULL=1 bash scripts/prod-deploy.sh
  SKIP_DB_BACKUP=1 bash scripts/prod-deploy.sh
  OVERWRITE_SQL=1 bash scripts/prod-deploy.sh
  OVERWRITE_SQL=0 bash scripts/prod-deploy.sh

说明：
  生产服务器只部署 release 产物，不执行 Maven 或 npm build。
  第一次初始化 SQL 来自 sql/INIT.sql.zip，脚本会展开到 data/sql/init.sql。
  如果生产 MySQL 已经初始化，MySQL 官方镜像不会再次执行 data/sql/init.sql。
EOF
}

parse_args() {
  if [[ "$#" -gt 1 ]]; then
    usage
    err "参数过多"
  fi
  if [[ "$#" -eq 0 ]]; then
    return
  fi

  case "$1" in
    yes|YES|y|Y|true|TRUE|1)
      OVERWRITE_SQL=1
      ;;
    no|NO|n|N|false|FALSE|0)
      OVERWRITE_SQL=0
      ;;
    -h|--help|help)
      usage
      exit 0
      ;;
    *)
      usage
      err "未知参数：$1"
      ;;
  esac
}

detect_compose_cmd() {
  if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
    return
  fi
  if command -v docker-compose >/dev/null 2>&1; then
    COMPOSE_CMD="docker-compose"
    return
  fi
  err "未发现 docker compose 或 docker-compose，请先安装 Docker Compose"
}

require_env_key() {
  local key="$1"
  grep -Eq "^[[:space:]]*${key}=" "${DEPLOY_DIR}/.env" || err ".env 缺少配置：${key}"
}

read_env_value() {
  local key="$1"
  local env_file="${DEPLOY_DIR}/.env"
  local line value
  line="$(grep -E "^[[:space:]]*${key}=" "${env_file}" | tail -n 1 || true)"
  [[ -n "${line}" ]] || return 0
  value="${line#*=}"
  value="${value%$'\r'}"
  value="${value%\"}"
  value="${value#\"}"
  value="${value%\'}"
  value="${value#\'}"
  printf '%s' "${value}"
}

load_safe_env_values() {
  local value
  value="$(read_env_value APP_NAME)"
  [[ -n "${value}" ]] && APP_NAME="${value}"
  value="$(read_env_value NGINX_HTTP_PORT)"
  [[ -n "${value}" ]] && NGINX_HTTP_PORT="${value}"
}

check_base_files() {
  [[ -d "${DEPLOY_DIR}" ]] || err "部署目录不存在：${DEPLOY_DIR}"
  if [[ ! -d "${DEPLOY_DIR}/.git" && "${SKIP_GIT_PULL}" != "1" ]]; then
    warn "部署目录不是 git 仓库，按 ZIP 初始化包模式跳过 git pull"
    SKIP_GIT_PULL=1
  fi
  [[ -f "${DEPLOY_DIR}/.env" ]] || err "缺少 ${DEPLOY_DIR}/.env，请先复制 .env.example 并填写生产配置"

  require_env_key MYSQL_DB
  require_env_key MYSQL_USER
  require_env_key MYSQL_PASSWORD
  require_env_key MYSQL_ROOT_PASSWORD
  require_env_key REDIS_PASSWORD
  require_env_key BIA_JWT_SECRET
  require_env_key BIA_MAIL_CONFIG_SECRET

  if grep -Eq "CHANGE_ME|GENERATE_WITH_OPENSSL|PLEASE_CHANGE" "${DEPLOY_DIR}/.env"; then
    err ".env 仍包含占位值，请先替换生产密码和密钥"
  fi
}

check_release_files() {
  [[ -f "${DEPLOY_DIR}/docker-compose.yml" ]] || err "缺少 docker-compose.yml"
  [[ -f "${DEPLOY_DIR}/nginx/default.conf" ]] || err "缺少 nginx/default.conf"
  [[ -f "${DEPLOY_DIR}/release/backend/app.jar" ]] || err "缺少 release/backend/app.jar，请先执行 scripts/package-prod.sh 并提交产物"
  [[ -f "${DEPLOY_DIR}/release/frontend/dist/index.html" ]] || err "缺少 release/frontend/dist/index.html，请先执行 scripts/package-prod.sh 并提交产物"
}

backup_current() {
  log "备份当前生产文件到 ${BACKUP_DIR}"
  mkdir -p "${BACKUP_DIR}"

  [[ -f "${DEPLOY_DIR}/.env" ]] && cp "${DEPLOY_DIR}/.env" "${BACKUP_DIR}/.env"
  [[ -f "${DEPLOY_DIR}/docker-compose.yml" ]] && cp "${DEPLOY_DIR}/docker-compose.yml" "${BACKUP_DIR}/docker-compose.yml"
  [[ -f "${DEPLOY_DIR}/nginx/default.conf" ]] && cp "${DEPLOY_DIR}/nginx/default.conf" "${BACKUP_DIR}/default.conf"
  [[ -f "${DEPLOY_DIR}/release/backend/app.jar" ]] && cp "${DEPLOY_DIR}/release/backend/app.jar" "${BACKUP_DIR}/app.jar"

  if [[ -d "${DEPLOY_DIR}/release/frontend/dist" ]]; then
    tar -czf "${BACKUP_DIR}/frontend-dist.tar.gz" -C "${DEPLOY_DIR}/release/frontend" dist
  fi

  if [[ -d "${DEPLOY_DIR}/sql" ]]; then
    tar -czf "${BACKUP_DIR}/repo-sql.tar.gz" -C "${DEPLOY_DIR}" sql
  fi

  if [[ -d "${DEPLOY_DIR}/data/sql" ]]; then
    tar -czf "${BACKUP_DIR}/runtime-sql.tar.gz" -C "${DEPLOY_DIR}/data" sql
  fi

  backup_database
}

backup_database() {
  if [[ ! -f "${DEPLOY_DIR}/docker-compose.yml" ]]; then
    warn "缺少 docker-compose.yml，跳过数据库备份"
    return
  fi

  cd "${DEPLOY_DIR}"
  local mysql_container
  mysql_container="$(${COMPOSE_CMD} --env-file .env ps -q mysql 2>/dev/null || true)"
  if [[ -z "${mysql_container}" ]]; then
    warn "未检测到 MySQL 容器，跳过数据库备份"
    return
  fi

  local running
  running="$(docker inspect -f '{{.State.Running}}' "${mysql_container}" 2>/dev/null || true)"
  if [[ "${running}" != "true" ]]; then
    warn "MySQL 容器未运行，跳过数据库备份"
    return
  fi

  local database_backup_dir dump_file
  database_backup_dir="${BACKUP_DIR}/database"
  dump_file="${database_backup_dir}/${APP_NAME}_mysql_${BACKUP_TIME}.sql.gz"
  mkdir -p "${database_backup_dir}"

  log "导出数据库结构和数据到 ${dump_file}"
  if ${COMPOSE_CMD} --env-file .env exec -T mysql sh -c 'mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" --databases "$MYSQL_DATABASE" --single-transaction --routines --triggers --events' | gzip > "${dump_file}"; then
    ls -lh "${dump_file}"
  else
    rm -f "${dump_file}"
    if [[ "${SKIP_DB_BACKUP}" == "1" ]]; then
      warn "数据库备份失败，已设置 SKIP_DB_BACKUP=1，继续发布"
      return
    fi
    err "数据库备份失败，已中止发布；如确认可跳过，执行 SKIP_DB_BACKUP=1 bash scripts/prod-deploy.sh"
  fi
}

pull_latest() {
  if [[ "${SKIP_GIT_PULL}" == "1" ]]; then
    warn "已设置 SKIP_GIT_PULL=1，跳过 git pull"
    return
  fi
  log "拉取最新代码和 release 产物"
  cd "${DEPLOY_DIR}"
  git pull --ff-only
}

prepare_dirs() {
  log "准备持久化目录"
  mkdir -p "${DEPLOY_DIR}/data/files"
  mkdir -p "${DEPLOY_DIR}/data/mysql"
  mkdir -p "${DEPLOY_DIR}/data/redis"
  mkdir -p "${DEPLOY_DIR}/data/sql"
  mkdir -p "${DEPLOY_DIR}/sql"
  mkdir -p "${DEPLOY_DIR}/backup"
}

find_init_sql_zip() {
  INIT_SQL_ZIP=""
  if [[ -f "${DEPLOY_DIR}/sql/INIT.sql.zip" ]]; then
    INIT_SQL_ZIP="${DEPLOY_DIR}/sql/INIT.sql.zip"
    return
  fi
  if [[ -f "${DEPLOY_DIR}/sql/init.sql.zip" ]]; then
    INIT_SQL_ZIP="${DEPLOY_DIR}/sql/init.sql.zip"
  fi
}

should_prepare_runtime_sql() {
  case "${OVERWRITE_SQL}" in
    1|true|TRUE|yes|YES|y|Y)
      return 0
      ;;
    0|false|FALSE|no|NO|n|N)
      return 1
      ;;
    auto)
      [[ ! -f "${DEPLOY_DIR}/data/sql/init.sql" ]]
      ;;
    *)
      err "OVERWRITE_SQL 只能是 auto、1 或 0，当前值：${OVERWRITE_SQL}"
      ;;
  esac
}

mysql_data_initialized() {
  local mysql_data_dir first_entry
  mysql_data_dir="${DEPLOY_DIR}/data/mysql"
  [[ -d "${mysql_data_dir}/mysql" ]] && return 0
  [[ -d "${mysql_data_dir}" ]] || return 1
  first_entry="$(find "${mysql_data_dir}" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null || true)"
  [[ -n "${first_entry}" ]]
}

prepare_runtime_sql() {
  find_init_sql_zip
  if [[ -z "${INIT_SQL_ZIP}" ]]; then
    warn "未发现 sql/INIT.sql.zip，跳过首次初始化 SQL 准备"
    return
  fi

  if mysql_data_initialized; then
    warn "检测到 data/mysql 已有数据，MySQL 官方镜像不会再次执行 data/sql/init.sql"
  fi

  if ! should_prepare_runtime_sql; then
    log "保留当前 data/sql/init.sql，不覆盖初始化 SQL"
    return
  fi

  if mysql_data_initialized; then
    warn "本次只会更新 data/sql/init.sql 文件，不会自动导入到已有 MySQL 数据库"
  fi

  log "展开首次初始化 SQL：${INIT_SQL_ZIP} -> ${DEPLOY_DIR}/data/sql/init.sql"
  mkdir -p "${DEPLOY_DIR}/data/sql"
  if unzip -p "${INIT_SQL_ZIP}" init.sql > "${DEPLOY_DIR}/data/sql/init.sql"; then
    ls -lh "${DEPLOY_DIR}/data/sql/init.sql"
  else
    rm -f "${DEPLOY_DIR}/data/sql/init.sql"
    err "解压 ${INIT_SQL_ZIP} 失败，压缩包内必须包含 init.sql"
  fi
}

validate_compose() {
  log "校验 Docker Compose 配置"
  cd "${DEPLOY_DIR}"
  ${COMPOSE_CMD} --env-file .env config >/dev/null
}

has_existing_containers() {
  cd "${DEPLOY_DIR}"
  ${COMPOSE_CMD} --env-file .env ps -q mysql redis backend nginx 2>/dev/null | grep -q .
}

deploy_services() {
  cd "${DEPLOY_DIR}"
  if has_existing_containers; then
    log "检测到已有容器，保留数据卷并重启服务"
    ${COMPOSE_CMD} --env-file .env up -d mysql redis
    ${COMPOSE_CMD} --env-file .env up -d backend nginx
    ${COMPOSE_CMD} --env-file .env restart backend nginx
  else
    log "首次启动服务"
    ${COMPOSE_CMD} --env-file .env up -d
  fi
}

show_status() {
  cd "${DEPLOY_DIR}"
  echo
  ${COMPOSE_CMD} --env-file .env ps
  echo
  log "验证前端入口"
  if curl -fsSI "http://127.0.0.1:${NGINX_HTTP_PORT:-80}/" >/dev/null; then
    curl -I "http://127.0.0.1:${NGINX_HTTP_PORT:-80}/"
  else
    warn "前端入口验证失败，请检查 nginx 和 backend 日志"
  fi
  echo
  echo "常用命令："
  echo "  cd ${DEPLOY_DIR} && ${COMPOSE_CMD} --env-file .env logs --tail=200 backend"
  echo "  cd ${DEPLOY_DIR} && ${COMPOSE_CMD} --env-file .env logs --tail=200 nginx"
  echo "  cd ${DEPLOY_DIR} && ${COMPOSE_CMD} --env-file .env ps"
  echo "  curl -I http://127.0.0.1:${NGINX_HTTP_PORT:-80}/"
  echo "  curl -i http://127.0.0.1:${NGINX_HTTP_PORT:-80}/api/admin/v1/auth/captcha"
  echo
  echo "本次备份目录：${BACKUP_DIR}"
}

main() {
  parse_args "$@"
  detect_compose_cmd
  check_base_files
  load_safe_env_values
  backup_current
  pull_latest
  check_release_files
  prepare_dirs
  prepare_runtime_sql
  validate_compose
  deploy_services
  show_status
}

main "$@"
