#!/usr/bin/env bash
set -euo pipefail

FILE="${1:-}"
if [[ -z "$FILE" || ! -f "$FILE" ]]; then
  echo "Usage: $0 <api-contract-file>"
  exit 1
fi

fail=0

require_heading_any() {
  local label="$1"
  local pattern="$2"
  if ! grep -Eq "^##[[:space:]]+($pattern)$" "$FILE"; then
    echo "[FAIL] Missing section: $label"
    fail=1
  fi
}

require_heading_any "Endpoint/端点" "Endpoint|端点"
require_heading_any "Request/请求" "Request|请求"
require_heading_any "Response/响应" "Response|响应"
require_heading_any "Compatibility/兼容性" "Compatibility|兼容性"

if [[ "$fail" -eq 1 ]]; then
  echo "API contract check failed."
  exit 2
fi

echo "API contract check passed."
