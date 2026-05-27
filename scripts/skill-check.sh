#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$ROOT/.codex/skills"
fail=0
count=0

error() {
  printf '[FAIL] %s\n' "$*"
  fail=1
}

warn() {
  printf '[WARN] %s\n' "$*"
}

should_skip_reference() {
  local ref="$1"
  [[ -z "$ref" ]] && return 0
  [[ "$ref" == *"<"* || "$ref" == *">"* ]] && return 0
  [[ "$ref" == *"*"* ]] && return 0
  [[ "$ref" == *"..."* ]] && return 0
  [[ "$ref" == http://* || "$ref" == https://* ]] && return 0
  [[ "$ref" == "如存在" || "$ref" == "如需要" ]] && return 0
  return 1
}

check_required_references() {
  local file="$1"
  local ref

  while IFS= read -r ref; do
    should_skip_reference "$ref" && continue
    if [[ ! -e "$ROOT/$ref" ]]; then
      error "$file required reference does not exist: $ref"
    fi
  done < <(
    awk '
      /^## 必须读取/ { in_section=1; next }
      in_section && /^## / { in_section=0 }
      in_section && /^[[:space:]]*-[[:space:]]*`[^`]+`/ {
        line=$0
        sub(/^[[:space:]]*-[[:space:]]*`/, "", line)
        sub(/`.*/, "", line)
        print line
      }
    ' "$file"
  )
}

[[ -d "$SKILLS_DIR" ]] || error "Missing .codex/skills directory"

while IFS= read -r dir; do
  skill="$(basename "$dir")"
  file="$dir/SKILL.md"
  count=$((count + 1))

  if [[ ! -f "$file" ]]; then
    error "Missing SKILL.md for $skill"
    continue
  fi

  name="$(awk '
    NR == 1 && $0 == "---" { in_frontmatter=1; next }
    in_frontmatter && $0 == "---" { exit }
    in_frontmatter && $1 == "name:" { print $2; exit }
  ' "$file")"

  if [[ "$name" != "$skill" ]]; then
    error "$file frontmatter name '$name' does not match directory '$skill'"
  fi

  if ! awk '
    NR == 1 && $0 == "---" { in_frontmatter=1; next }
    in_frontmatter && $0 == "---" { exit }
    in_frontmatter && /^description:[[:space:]]*[^[:space:]]/ { found=1 }
    END { exit found ? 0 : 1 }
  ' "$file"; then
    error "$file missing non-empty description"
  fi

  if ! grep -q '^## 必须读取' "$file"; then
    warn "$file has no '## 必须读取' section"
  else
    check_required_references "$file"
  fi

  case "$skill" in
    codegen-only|mysql-dba|springboot-backend|reviewer)
      if ! grep -q '兼容入口' "$file"; then
        error "$file compatibility entry must mention 兼容入口"
      fi
      ;;
  esac

  if [[ "$skill" == "codegen-java-springboot-gupo-crud" ]]; then
    if ! grep -q '禁止用于非 gupo 项目' "$file"; then
      error "$file must forbid use outside gupo projects"
    fi
  fi

  if [[ "$skill" == "codegen-java-springboot-crud" ]]; then
    if ! grep -q 'adapter 路由入口' "$file"; then
      error "$file must be adapter routing entry, not a concrete generator"
    fi
  fi
done < <(find "$SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d | sort)

if [[ "$count" -eq 0 ]]; then
  error "No skills found"
fi

if find "$SKILLS_DIR" -mindepth 3 -name SKILL.md | grep -q .; then
  error "Nested SKILL.md files are not allowed under .codex/skills"
fi

if [[ -f "$ROOT/profiles/gupo/profile.toml" ]]; then
  if ! grep -q '".codex"' "$ROOT/profiles/gupo/profile.toml"; then
    error "profiles/gupo/profile.toml should install .codex as a whole to avoid missing new skills"
  fi
  for legacy in codegen-only mysql-dba reviewer springboot-backend; do
    if ! grep -q "\".codex/skills/$legacy\"" "$ROOT/profiles/gupo/profile.toml"; then
      error "profiles/gupo/profile.toml should exclude legacy compatibility skill: $legacy"
    fi
  done
fi

if [[ "$fail" -eq 1 ]]; then
  printf 'Skill check failed.\n'
  exit 2
fi

printf 'Skill check passed. skills=%s\n' "$count"
