#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOCAL_ENV_FILE="$ROOT/.agent/local-agent.env"
REVIEW_DIR="$ROOT/.agent/reviews"
OUTPUT_FILE="${1:-$REVIEW_DIR/deepv4-input.md}"
TEST_LOG="$ROOT/.agent/logs/test.log"
TEST_SUMMARY="$REVIEW_DIR/test-summary.log"

if [[ -f "$LOCAL_ENV_FILE" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$LOCAL_ENV_FILE"
  set +a
fi

mkdir -p "$REVIEW_DIR"

if [[ -f "$TEST_LOG" ]]; then
  bash "$ROOT/scripts/summarize-log.sh" "$TEST_LOG" > "$TEST_SUMMARY"
else
  printf 'TEST_LOG_NOT_FOUND: %s\n' "$TEST_LOG" > "$TEST_SUMMARY"
fi

CHANGE_ID="${OPENSPEC_CHANGE_ID:-}"
CHANGE_DIR=""
if [[ -n "$CHANGE_ID" && -d "$ROOT/openspec/changes/$CHANGE_ID" ]]; then
  CHANGE_DIR="$ROOT/openspec/changes/$CHANGE_ID"
fi

write_file_if_exists() {
  local title="$1"
  local file="$2"

  printf '\n## %s\n' "$title"
  if [[ -f "$file" ]]; then
    printf '```markdown\n'
    sed -n '1,220p' "$file"
    printf '\n```\n'
  else
    printf 'NOT_PROVIDED\n'
  fi
}

{
  printf '# deepv4 Review Input\n\n'
  printf '## Review Goal\n'
  printf 'Review the current local changes for business logic, security, data safety, API compatibility, SQL risk, transaction boundaries, and missing tests. Do not rewrite code. Report only review findings.\n\n'

  printf '## Project Context\n'
  printf '```text\n'
  printf 'Repository: %s\n' "$ROOT"
  printf 'OpenSpec change: %s\n' "${CHANGE_ID:-NOT_PROVIDED}"
  printf '```\n'

  write_file_if_exists "OpenSpec Proposal" "$CHANGE_DIR/proposal.md"
  write_file_if_exists "OpenSpec Design" "$CHANGE_DIR/design.md"
  write_file_if_exists "OpenSpec Tasks" "$CHANGE_DIR/tasks.md"

  printf '\n## Test Summary\n'
  printf '```text\n'
  sed -n '1,240p' "$TEST_SUMMARY"
  printf '\n```\n'

  printf '\n## Git Diff Stat\n'
  printf '```text\n'
  git -C "$ROOT" status --short || true
  printf '\n'
  if git -C "$ROOT" rev-parse --verify HEAD >/dev/null 2>&1; then
    git -C "$ROOT" diff --stat || true
  else
    printf 'NO_BASELINE_COMMIT: repository has no initial commit, so untracked project files are not expanded for deepv4 review.\n'
    printf 'Create an initial baseline commit before using deepv4 for code-change review.\n'
  fi
  printf '\n```\n'

  printf '\n## Git Diff\n'
  printf '```diff\n'
  if git -C "$ROOT" rev-parse --verify HEAD >/dev/null 2>&1; then
    git -C "$ROOT" diff -- . ':!.agent' ':!**/node_modules/**' ':!**/dist/**' ':!**/target/**' || true
    git -C "$ROOT" ls-files --others --exclude-standard \
      | grep -Ev '(^|/)(\.agent|\.codex|docs|examples|openspec|profiles|scripts|templates|tools|node_modules|dist|target|\.git\.bak-[^/]+)(/|$)' \
      | grep -Ev '^(AGENTS.md|CODEX_TASK_TEMPLATE.md|CONTEXT-MAP.md|README.md)$' \
      | while IFS= read -r file; do
          [[ -f "$ROOT/$file" ]] || continue
          size="$(wc -c < "$ROOT/$file" | tr -d ' ')"
          if [[ "$size" -gt 200000 ]]; then
            printf '\n# Skipped large untracked file: %s (%s bytes)\n' "$file" "$size"
            continue
          fi
          if file "$ROOT/$file" | grep -Eq 'text|JSON|XML|Java|script|empty|Markdown|UTF-8|ASCII'; then
            printf '\n# Untracked file: %s\n' "$file"
            git -C "$ROOT" diff --no-index -- /dev/null "$file" || true
          else
            printf '\n# Skipped binary untracked file: %s\n' "$file"
          fi
        done
  else
    printf 'NO_BASELINE_COMMIT: diff omitted. Commit the current baseline first, then rerun this script after a code change.\n'
  fi
  printf '\n```\n'

  printf '\n## Review Questions\n'
  printf -- '- Did the change guess business rules, fields, enums, API paths, permissions, status flows, or response formats?\n'
  printf -- '- Are there tenant, permission, soft-delete, or data visibility gaps?\n'
  printf -- '- Are transaction boundaries, concurrency, idempotency, and repeated-submit behavior safe?\n'
  printf -- '- Are SQL and database changes safe, indexed, rollbackable, and compatible with existing data?\n'
  printf -- '- Are API contracts and frontend expectations compatible?\n'
  printf -- '- Are tests or verification steps missing for high-risk behavior?\n'

  printf '\n## Required Output Format\n'
  printf '1. Blocking issues\n'
  printf '2. Important risks\n'
  printf '3. Questions needing user confirmation\n'
  printf '4. Suggested tests\n'
  printf '5. Whether this is ready for Codex final review\n'
} > "$OUTPUT_FILE"

printf 'DEEPV4_INPUT=%s\n' "$OUTPUT_FILE"
