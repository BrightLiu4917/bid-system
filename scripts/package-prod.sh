#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
API_DIR="${ROOT_DIR}/api"
WEB_DIR="${ROOT_DIR}/vue"
RELEASE_DIR="${ROOT_DIR}/release"

log() {
  echo "[INFO] $1"
}

err() {
  echo "[ERROR] $1" >&2
  exit 1
}

detect_maven_cmd() {
  if [[ -x "${API_DIR}/mvnw" ]]; then
    MAVEN_CMD=("${API_DIR}/mvnw")
    return
  fi
  if command -v mvn >/dev/null 2>&1; then
    MAVEN_CMD=(mvn)
    return
  fi
  err "未发现 Maven。请安装 mvn，或在 api 目录提供 mvnw"
}

check_prerequisites() {
  [[ -f "${API_DIR}/pom.xml" ]] || err "缺少后端 pom.xml：${API_DIR}/pom.xml"
  [[ -f "${WEB_DIR}/package.json" ]] || err "缺少前端 package.json：${WEB_DIR}/package.json"
  command -v npm >/dev/null 2>&1 || err "未发现 npm，无法打包前端"
  detect_maven_cmd
}

find_backend_jar() {
  jars=()
  while IFS= read -r jar; do
    jars+=("${jar}")
  done < <(
    find "${API_DIR}/target" -maxdepth 1 -type f -name "*.jar" \
      ! -name "*-sources.jar" \
      ! -name "*-javadoc.jar" \
      ! -name "*.original" \
      | sort
  )
  if [[ "${#jars[@]}" -ne 1 ]]; then
    printf '%s\n' "${jars[@]:-}" >&2
    err "后端 jar 数量不是 1，请检查 ${API_DIR}/target"
  fi
  BACKEND_JAR="${jars[0]}"
}

build_backend() {
  log "打包后端 jar"
  cd "${API_DIR}"
  "${MAVEN_CMD[@]}" -B -ntp clean package -DskipTests
  find_backend_jar
  [[ -f "${BACKEND_JAR}" ]] || err "后端 jar 不存在：${BACKEND_JAR}"
}

build_frontend() {
  log "打包前端 dist"
  cd "${WEB_DIR}"
  npm run build
  [[ -f "${WEB_DIR}/dist/index.html" ]] || err "前端 dist 不存在：${WEB_DIR}/dist/index.html"
}

write_release() {
  log "生成 release 目录"
  rm -rf "${RELEASE_DIR}"
  mkdir -p "${RELEASE_DIR}/backend" "${RELEASE_DIR}/frontend"
  cp "${BACKEND_JAR}" "${RELEASE_DIR}/backend/app.jar"
  cp -R "${WEB_DIR}/dist" "${RELEASE_DIR}/frontend/dist"

  log "发布产物已生成"
  ls -lh "${RELEASE_DIR}/backend/app.jar"
  ls -lh "${RELEASE_DIR}/frontend/dist/index.html"
}

show_next_steps() {
  cat <<'EOF'

下一步：
1. 检查生产配置模板和发布产物：
   git status --short .env.example docker-compose.yml nginx scripts release PROD_DEPLOY.md
2. 提交发布脚本和 release 产物。
3. 登录生产服务器执行：
   cd /opt/bidding-system
   bash scripts/prod-deploy.sh

注意：生产服务器只部署 release 产物，不执行 Maven 或 npm build。
EOF
}

main() {
  log "项目根目录：${ROOT_DIR}"
  check_prerequisites
  build_backend
  build_frontend
  write_release
  show_next_steps
}

main "$@"
