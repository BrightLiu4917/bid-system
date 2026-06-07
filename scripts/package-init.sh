#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="${ROOT_DIR}/dist"
PACKAGE_NAME="${PACKAGE_NAME:-INIT.bidding-system.zip}"
PACKAGE_FILE="${DIST_DIR}/${PACKAGE_NAME}"
EXPORT_INIT_SQL="${EXPORT_INIT_SQL:-1}"

log() {
  echo "[INFO] $1"
}

err() {
  echo "[ERROR] $1" >&2
  exit 1
}

usage() {
  cat <<'EOF'
用法：
  bash scripts/package-init.sh

默认行为：
  1. 打包后端 jar 和前端 dist。
  2. 导出源库全量结构和数据到 sql/INIT.sql.zip。
  3. 生成完整生产初始化包 dist/INIT.bidding-system.zip。

源库配置：
  SOURCE_DB_HOST=127.0.0.1
  SOURCE_DB_PORT=13306
  SOURCE_DB_NAME=bia
  SOURCE_DB_USER=root
  SOURCE_DB_PASSWORD=<源库密码>

跳过 SQL 导出：
  EXPORT_INIT_SQL=0 bash scripts/package-init.sh

生产使用：
  mkdir -p /opt/bidding-system
  unzip INIT.bidding-system.zip -d /opt/bidding-system
  cd /opt/bidding-system
  cp .env.example .env
  vi .env
  bash scripts/prod-deploy.sh
EOF
}

check_tools() {
  command -v zip >/dev/null 2>&1 || err "未发现 zip"
  command -v unzip >/dev/null 2>&1 || err "未发现 unzip"
}

build_release() {
  log "生成后端和前端 release 产物"
  bash "${ROOT_DIR}/scripts/package-prod.sh"
}

build_init_sql() {
  if [[ "${EXPORT_INIT_SQL}" == "0" ]]; then
    log "EXPORT_INIT_SQL=0，跳过 sql/INIT.sql.zip 生成"
    return
  fi
  log "生成 sql/INIT.sql.zip"
  bash "${ROOT_DIR}/scripts/db-export-initial.sh"
}

check_package_files() {
  [[ -f "${ROOT_DIR}/release/backend/app.jar" ]] || err "缺少 release/backend/app.jar"
  [[ -f "${ROOT_DIR}/release/frontend/dist/index.html" ]] || err "缺少 release/frontend/dist/index.html"
  [[ -f "${ROOT_DIR}/docker-compose.yml" ]] || err "缺少 docker-compose.yml"
  [[ -f "${ROOT_DIR}/nginx/default.conf" ]] || err "缺少 nginx/default.conf"
  [[ -f "${ROOT_DIR}/.env.example" ]] || err "缺少 .env.example"
  if [[ "${EXPORT_INIT_SQL}" != "0" ]]; then
    [[ -f "${ROOT_DIR}/sql/INIT.sql.zip" ]] || err "缺少 sql/INIT.sql.zip"
  fi
}

write_package() {
  log "生成完整初始化包：${PACKAGE_FILE}"
  mkdir -p "${DIST_DIR}"
  rm -f "${PACKAGE_FILE}"

  cd "${ROOT_DIR}"
  package_paths=(
    .env.example \
    docker-compose.yml \
    deploy.sh \
    PROD_DEPLOY.md \
    nginx \
    scripts/prod-deploy.sh \
    release \
    openspec/changes/add-prod-deploy-scripts \
  )
  if [[ -d "${ROOT_DIR}/sql" ]]; then
    package_paths+=(sql)
  fi

  zip -q -r "${PACKAGE_FILE}" \
    "${package_paths[@]}" \
    -x "*.DS_Store" \
    -x "__MACOSX/*" \
    -x "scripts/*.log"

  ls -lh "${PACKAGE_FILE}"
}

show_next_steps() {
  if [[ -f "${ROOT_DIR}/sql/INIT.sql.zip" ]]; then
    sql_note="- 初始化包内已包含 sql/INIT.sql.zip，prod-deploy.sh 会自动展开到 data/sql/init.sql。"
  else
    sql_note="- 初始化包内未包含 sql/INIT.sql.zip；如果是首次生产初始化，请先生成或放入该文件。"
  fi

  cat <<EOF

生产服务器执行：
  mkdir -p /opt/bidding-system
  unzip ${PACKAGE_NAME} -d /opt/bidding-system
  cd /opt/bidding-system
  cp .env.example .env
  vi .env
  bash scripts/prod-deploy.sh

说明：
- 初始化包内包含 release/backend/app.jar、release/frontend/dist、Compose、Nginx 和脚本。
${sql_note}
- 目录不是 git 仓库时，prod-deploy.sh 会自动跳过 git pull。
EOF
}

main() {
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" || "${1:-}" == "help" ]]; then
    usage
    exit 0
  fi

  check_tools
  build_release
  build_init_sql
  check_package_files
  write_package
  show_next_steps
}

main "$@"
