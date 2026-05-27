#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE="$ROOT/templates/skill/SKILL.md"
DRY_RUN=0

usage() {
  cat <<'USAGE'
Usage:
  bash scripts/new-skill.sh [--dry-run] <skill-name> "<中文 description>"

Example:
  bash scripts/new-skill.sh backend-node-nestjs "NestJS 后端实现 skill，用于..."
USAGE
}

fail() {
  printf '[FAIL] %s\n' "$*" >&2
  exit 1
}

if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=1
  shift
fi

SKILL_NAME="${1:-}"
DESCRIPTION="${2:-}"

[[ -n "$SKILL_NAME" && -n "$DESCRIPTION" ]] || { usage; exit 1; }
[[ "$SKILL_NAME" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || fail "Skill name must use lowercase kebab-case: $SKILL_NAME"
[[ -f "$TEMPLATE" ]] || fail "Missing template: templates/skill/SKILL.md"

DEST_DIR="$ROOT/.codex/skills/$SKILL_NAME"
DEST_FILE="$DEST_DIR/SKILL.md"

escape_sed_replacement() {
  printf '%s' "$1" | sed -e 's/[\\&|]/\\&/g'
}

if [[ -e "$DEST_DIR" ]]; then
  fail "Skill already exists: .codex/skills/$SKILL_NAME"
fi

printf '[CREATE] %s\n' "${DEST_FILE#$ROOT/}"

if [[ "$DRY_RUN" -eq 1 ]]; then
  printf 'Mode: dry-run\n'
  exit 0
fi

mkdir -p "$DEST_DIR"
SAFE_DESCRIPTION="$(escape_sed_replacement "$DESCRIPTION")"
sed \
  -e "s/name: <skill-name>/name: $SKILL_NAME/" \
  -e "s|description: <中文描述：说明何时使用、职责边界、关键约束。路径、命令、技术名保留英文。>|description: $SAFE_DESCRIPTION|" \
  -e "s/# <Skill Title>/# $SKILL_NAME/" \
  "$TEMPLATE" > "$DEST_FILE"

printf 'Skill created: %s\n' "${DEST_FILE#$ROOT/}"
