#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TASK_FILE="${1:-}"
LOCAL_ENV_FILE="$ROOT/.agent/local-agent.env"

if [[ -f "$LOCAL_ENV_FILE" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$LOCAL_ENV_FILE"
  set +a
fi

MAX_ROUNDS="${MAX_ROUNDS:-3}"
LOCAL_AGENT_COMMAND="${LOCAL_AGENT_COMMAND:-opencode run}"
LOG_DIR="$ROOT/.agent/logs"

usage() {
  cat <<'USAGE'
Usage:
  LOCAL_AGENT_COMMAND='opencode run' bash scripts/local-agent-loop-example.sh path/to/local-agent-task.md

Environment:
  LOCAL_AGENT_COMMAND  Command used to invoke the local Agent. Default: opencode run
  MAX_ROUNDS           Maximum repair rounds. Default: 3
  PROJECT_TEST_COMMAND Optional command consumed by scripts/run-tests.sh

This script is an integration example. Review and adapt it to your OpenCode CLI before using it in production.
USAGE
}

[[ -n "$TASK_FILE" ]] || { usage; exit 1; }
[[ -f "$TASK_FILE" ]] || { printf 'Task file not found: %s\n' "$TASK_FILE" >&2; exit 2; }

mkdir -p "$LOG_DIR"
cd "$ROOT"

round=1
while [[ "$round" -le "$MAX_ROUNDS" ]]; do
  printf 'LOCAL_AGENT_ROUND=%s\n' "$round"

  if [[ "$round" -eq 1 ]]; then
    prompt="$TASK_FILE"
  else
    prompt="$LOG_DIR/repair-round-$((round - 1)).md"
  fi

  # shellcheck disable=SC2086
  $LOCAL_AGENT_COMMAND "$prompt"

  if bash scripts/run-tests.sh; then
    printf 'LOCAL_AGENT_TEST_PASSED\n'
    git diff --stat || true
    exit 0
  fi

  bash scripts/summarize-log.sh "$LOG_DIR/test.log" > "$LOG_DIR/test-summary-round-$round.log"

  if [[ "$round" -ge "$MAX_ROUNDS" ]]; then
    printf 'LOCAL_AGENT_TEST_FAILED_AFTER_%s_ROUNDS\n' "$MAX_ROUNDS"
    cat "$LOG_DIR/test-summary-round-$round.log"
    exit 2
  fi

  cat > "$LOG_DIR/repair-round-$round.md" <<EOF
# 本地 Agent 修复任务

上一轮验证失败。只能根据下方错误摘要做最小修复。

## 原始任务
$TASK_FILE

## 错误摘要
\`\`\`text
$(cat "$LOG_DIR/test-summary-round-$round.log")
\`\`\`

## 约束
- 不允许扩大原始任务范围。
- 不允许删除测试或降低校验。
- 不允许修改生产配置。
- 不允许新增依赖，除非原始任务明确允许。
- 修改后必须再次运行 scripts/run-tests.sh。
EOF

  round=$((round + 1))
done
