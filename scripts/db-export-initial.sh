#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_DB_HOST="${SOURCE_DB_HOST:-127.0.0.1}"
SOURCE_DB_PORT="${SOURCE_DB_PORT:-13306}"
SOURCE_DB_NAME="${SOURCE_DB_NAME:-bia}"
SOURCE_DB_USER="${SOURCE_DB_USER:-root}"
SOURCE_DB_PASSWORD="${SOURCE_DB_PASSWORD:-}"
BACKUP_TIME="$(date +%Y%m%d%H%M%S)"
OUT_DIR="${OUT_DIR:-${ROOT_DIR}/sql}"
OUT_FILE="${OUT_FILE:-${OUT_DIR}/INIT.sql.zip}"
TMP_DIR=""

log() {
  echo "[INFO] $1"
}

usage() {
  cat <<'EOF'
用法：
  bash scripts/db-export-initial.sh

默认源库：
  SOURCE_DB_HOST=127.0.0.1
  SOURCE_DB_PORT=13306
  SOURCE_DB_NAME=bia
  SOURCE_DB_USER=root

示例：
  SOURCE_DB_HOST=127.0.0.1 \
  SOURCE_DB_PORT=13306 \
  SOURCE_DB_NAME=bia \
  SOURCE_DB_USER=root \
  SOURCE_DB_PASSWORD=<源库密码> \
  bash scripts/db-export-initial.sh

输出：
  sql/INIT.sql.zip

压缩包内容：
  init.sql

说明：
  仅用于第一次生产初始化导出全量结构和数据。
  导出文件不要提交到 Git。
EOF
}

err() {
  echo "[ERROR] $1" >&2
  exit 1
}

check_tools() {
  command -v mysqldump >/dev/null 2>&1 || err "未发现 mysqldump，请先安装 MySQL client"
  command -v zip >/dev/null 2>&1 || err "未发现 zip"
}

dump_database() {
  mkdir -p "${OUT_DIR}"
  log "导出首次初始化数据：${SOURCE_DB_HOST}:${SOURCE_DB_PORT}/${SOURCE_DB_NAME}"
  log "输出文件：${OUT_FILE}"
  TMP_DIR="$(mktemp -d)"
  trap '[[ -n "${TMP_DIR}" ]] && rm -rf "${TMP_DIR}"' EXIT
  local init_sql="${TMP_DIR}/init.sql"

  if [[ -n "${SOURCE_DB_PASSWORD}" ]]; then
    MYSQL_PWD="${SOURCE_DB_PASSWORD}" mysqldump \
      -h"${SOURCE_DB_HOST}" \
      -P"${SOURCE_DB_PORT}" \
      -u"${SOURCE_DB_USER}" \
      --databases "${SOURCE_DB_NAME}" \
      --single-transaction \
      --routines \
      --triggers \
      --events \
      --default-character-set=utf8mb4 \
      ${MYSQLDUMP_EXTRA_ARGS:-} \
      > "${init_sql}"
  else
    mysqldump \
      -h"${SOURCE_DB_HOST}" \
      -P"${SOURCE_DB_PORT}" \
      -u"${SOURCE_DB_USER}" \
      -p \
      --databases "${SOURCE_DB_NAME}" \
      --single-transaction \
      --routines \
      --triggers \
      --events \
      --default-character-set=utf8mb4 \
      ${MYSQLDUMP_EXTRA_ARGS:-} \
      > "${init_sql}"
  fi

  rm -f "${OUT_FILE}"
  (cd "${TMP_DIR}" && zip -q -9 "${OUT_FILE}" init.sql)
  ls -lh "${OUT_FILE}"
}

show_next_steps() {
  cat <<EOF

下一步：
1. 上传到生产服务器：
   scp "${OUT_FILE}" root@服务器IP:/opt/bidding-system/sql/

2. 在生产服务器执行发布：
   cd /opt/bidding-system
   bash scripts/prod-deploy.sh

注意：
- 该文件包含生产初始化所需的表结构和数据，不要提交到 Git。
- 导出的全量库应包含 flyway_schema_history，后续 DDL migration 才能按版本继续执行。
- 生产脚本会展开 sql/INIT.sql.zip 到 data/sql/init.sql，MySQL 首次创建数据目录时自动执行。
EOF
}

main() {
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" || "${1:-}" == "help" ]]; then
    usage
    exit 0
  fi

  check_tools
  dump_database
  show_next_steps
}

main "$@"
