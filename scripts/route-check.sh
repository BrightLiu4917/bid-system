#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROUTING="$ROOT/docs/SKILL_ROUTING.md"
AGENTS="$ROOT/AGENTS.md"
fail=0

error() {
  printf '[FAIL] %s\n' "$*"
  fail=1
}

require_in_file() {
  local file="$1"
  local text="$2"
  if ! grep -Fq -- "$text" "$file"; then
    error "Missing '$text' in ${file#$ROOT/}"
  fi
}

[[ -f "$ROUTING" ]] || error "Missing docs/SKILL_ROUTING.md"
[[ -f "$AGENTS" ]] || error "Missing AGENTS.md"

for token in \
  "workflow-openspec-propose" \
  "workflow-openspec-grill" \
  "workflow-openspec-apply" \
  "workflow-openspec-archive" \
  "method-grill-with-docs" \
  "method-diagnose" \
  "method-tdd" \
  "method-architecture-review" \
  "method-zoom-out" \
  "backend-common-api-contract-review" \
  "backend-java-springboot" \
  "dba-mysql" \
  "codegen-java-springboot-crud" \
  "codegen-java-springboot-gupo-crud" \
  "release-production-review" \
  "并行标注" \
  "循环/回退" \
  "兼容入口"; do
  require_in_file "$ROUTING" "$token"
done

for mapping in \
  "codegen-only:codegen-java-springboot-crud" \
  "mysql-dba:dba-mysql" \
  "springboot-backend:backend-java-springboot" \
  "reviewer:release-production-review"; do
  old="${mapping%%:*}"
  new="${mapping##*:}"
  pattern="\`?${old}\`?[[:space:]]*->[[:space:]]*\`?${new}\`?"
  if ! grep -Eq -- "$pattern" "$ROUTING"; then
    error "Missing compatibility mapping '$old -> $new' in docs/SKILL_ROUTING.md"
  fi
  if ! grep -Eq -- "$pattern" "$AGENTS"; then
    error "Missing compatibility mapping '$old -> $new' in AGENTS.md"
  fi
done

require_in_file "$AGENTS" "docs/SKILL_ROUTING.md"

if grep -R "tools/codegen/java-springboot-crud/scripts" "$ROOT/AGENTS.md" "$ROOT/docs" "$ROOT/.codex/skills" "$ROOT/README.md" >/dev/null 2>&1; then
  error "Old generic-looking codegen script path is still referenced"
fi

if ! grep -Fq "未确认 adapter 时禁止生成" "$ROUTING"; then
  error "docs/SKILL_ROUTING.md must state adapter must be confirmed before CRUD generation"
fi

if ! grep -Fq "generic adapter 只允许生成审查预览包" "$ROUTING" || ! grep -Fq "backend-java-springboot" "$ROUTING"; then
  error "docs/SKILL_ROUTING.md must route generic preview and confirmed implementation correctly"
fi

if [[ "$fail" -eq 1 ]]; then
  printf 'Route check failed.\n'
  exit 2
fi

printf 'Route check passed.\n'
