#!/usr/bin/env bash
set -euo pipefail

APP_NAME="${APP_NAME:-bidding-system}"
DEPLOY_DIR="${DEPLOY_DIR:-/opt/bidding-system}"
COMPOSE_CMD="${COMPOSE_CMD:-docker compose}"
DOCKER_APT_MIRROR="${DOCKER_APT_MIRROR:-https://download.docker.com/linux/ubuntu}"

usage() {
  cat <<'EOF'
用法：
  sudo bash deploy.sh

默认配置：
  DEPLOY_DIR=/opt/bidding-system

可选环境变量：
  DOCKER_APT_MIRROR=https://mirrors.aliyun.com/docker-ce/linux/ubuntu sudo -E bash deploy.sh

说明：
  该脚本用于 Ubuntu 22.04+ 服务器首次部署辅助：
  1. 检查并安装 Docker 与 Docker Compose 插件。
  2. 检查生产 .env 是否存在。
  3. 调用 scripts/prod-deploy.sh 执行发布。
EOF
}

log() {
  echo -e "\033[1;32m[INFO]\033[0m $1"
}

warn() {
  echo -e "\033[1;33m[WARN]\033[0m $1"
}

err() {
  echo -e "\033[1;31m[ERROR]\033[0m $1" >&2
  exit 1
}

check_os() {
  if [[ ! -f /etc/os-release ]]; then
    err "无法识别系统版本，当前脚本仅支持 Ubuntu 22.04+"
  fi
  . /etc/os-release
  if [[ "${ID:-}" != "ubuntu" ]]; then
    err "当前系统为 ${ID:-unknown}，脚本仅支持 Ubuntu 22.04+"
  fi
}

check_root() {
  if [[ "$(id -u)" -ne 0 ]]; then
    err "请使用 root 或 sudo 执行：sudo bash deploy.sh"
  fi
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
  COMPOSE_CMD="docker compose"
}

install_docker() {
  if command -v docker >/dev/null 2>&1 && (docker compose version >/dev/null 2>&1 || command -v docker-compose >/dev/null 2>&1); then
    log "Docker 已安装，跳过安装"
    detect_compose_cmd
    return
  fi

  log "安装 Docker 与 Docker Compose 插件"
  apt-get update
  apt-get install -y ca-certificates curl gnupg lsb-release rsync unzip
  install -m 0755 -d /etc/apt/keyrings
  if [[ ! -f /etc/apt/keyrings/docker.asc ]]; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc
  fi
  ARCH="$(dpkg --print-architecture)"
  CODENAME="$(. /etc/os-release && echo "${VERSION_CODENAME}")"
  cat >/etc/apt/sources.list.d/docker.list <<EOL
deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.asc] ${DOCKER_APT_MIRROR} ${CODENAME} stable
EOL
  apt-get update
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin rsync unzip
  systemctl enable docker
  systemctl start docker
  detect_compose_cmd
}

check_project_files() {
  [[ -d "${DEPLOY_DIR}" ]] || err "部署目录不存在：${DEPLOY_DIR}。请先 clone 仓库到该目录"
  [[ -f "${DEPLOY_DIR}/scripts/prod-deploy.sh" ]] || err "缺少 ${DEPLOY_DIR}/scripts/prod-deploy.sh"
  [[ -f "${DEPLOY_DIR}/.env" ]] || err "缺少 ${DEPLOY_DIR}/.env。请先复制 .env.example 为 .env 并填写生产配置"
}

main() {
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" || "${1:-}" == "help" ]]; then
    usage
    exit 0
  fi

  check_os
  check_root
  install_docker
  check_project_files
  log "执行生产发布"
  cd "${DEPLOY_DIR}"
  bash scripts/prod-deploy.sh
  warn "发布完成后请执行 curl 和页面登录验证"
}

main "$@"
