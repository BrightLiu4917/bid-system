#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

PROJECT_DIR=""
PROJECT_NAME=""
PROFILE="default"
BACKEND_DIR=""
FRONTEND_DIR=""
USE_LOCAL_AGENT=0
USE_DEEPV4=0
USE_GUPO=0
DRY_RUN=0
FORCE=0
BACKUP=1
INIT_GIT=0

usage() {
  cat <<'USAGE'
Usage:
  bash scripts/bootstrap-new-project.sh --project-dir /path/to/project [options]

Options:
  --project-dir <path>     Target project directory. Required.
  --project-name <name>    Project name. Defaults to directory name.
  --profile <name>         default, local-agent, gupo, or minimal. Default: default.
  --local-agent            Configure .agent/local-agent.env.
  --deepv4                 Add deepv4 placeholder config. Implies --local-agent.
  --gupo                   Install and configure gupo adapter.
  --backend <dir>          Backend directory, for example api.
  --frontend <dir>         Frontend directory, for example vue.
  --backup                 Back up conflicts. Default.
  --force                  Replace conflicts. Use carefully.
  --init-git               Run git init when target is not a git repository.
  --dry-run                Show install actions without writing.
  -h, --help               Show help.
USAGE
}

fail() {
  printf '[FAIL] %s\n' "$*" >&2
  exit 2
}

replace_or_append_env() {
  local file="$1"
  local key="$2"
  local value="$3"
  local tmp

  tmp="$(mktemp)"
  awk -v key="$key" -v line="${key}=${value}" '
    BEGIN { done=0 }
    $0 ~ "^[#[:space:]]*" key "=" {
      if (done == 0) {
        print line
        done=1
      }
      next
    }
    { print }
    END {
      if (done == 0) {
        print line
      }
    }
  ' "$file" > "$tmp"
  mv "$tmp" "$file"
}

detect_test_command() {
  local project_dir="$1"
  local backend_dir="$2"
  local frontend_dir="$3"
  local backend_test=""
  local frontend_test=""

  if [[ -n "$backend_dir" && -f "$project_dir/$backend_dir/pom.xml" ]]; then
    if [[ -x "$project_dir/$backend_dir/mvnw" ]]; then
      backend_test="cd $backend_dir && ./mvnw test"
    else
      backend_test="cd $backend_dir && mvn test"
    fi
  elif [[ -f "$project_dir/pom.xml" ]]; then
    if [[ -x "$project_dir/mvnw" ]]; then
      backend_test="./mvnw test"
    else
      backend_test="mvn test"
    fi
  fi

  if [[ -n "$frontend_dir" && -f "$project_dir/$frontend_dir/package.json" ]]; then
    if [[ -f "$project_dir/$frontend_dir/pnpm-lock.yaml" ]]; then
      frontend_test="cd $frontend_dir && pnpm build"
    elif [[ -f "$project_dir/$frontend_dir/package-lock.json" ]]; then
      frontend_test="cd $frontend_dir && npm run build"
    else
      frontend_test="cd $frontend_dir && npm test"
    fi
  elif [[ -f "$project_dir/package.json" ]]; then
    if [[ -f "$project_dir/pnpm-lock.yaml" ]]; then
      frontend_test="pnpm build"
    elif [[ -f "$project_dir/package-lock.json" ]]; then
      frontend_test="npm run build"
    else
      frontend_test="npm test"
    fi
  fi

  if [[ -n "$backend_test" && -n "$frontend_test" ]]; then
    printf '%s && cd .. && %s\n' "$backend_test" "$frontend_test"
  elif [[ -n "$backend_test" ]]; then
    printf '%s\n' "$backend_test"
  elif [[ -n "$frontend_test" ]]; then
    printf '%s\n' "$frontend_test"
  fi
}

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --project-dir)
      [[ "${2:-}" ]] || fail "--project-dir requires a value"
      PROJECT_DIR="$2"
      shift 2
      ;;
    --project-name)
      [[ "${2:-}" ]] || fail "--project-name requires a value"
      PROJECT_NAME="$2"
      shift 2
      ;;
    --profile)
      [[ "${2:-}" ]] || fail "--profile requires a value"
      PROFILE="$2"
      shift 2
      ;;
    --backend)
      [[ "${2:-}" ]] || fail "--backend requires a value"
      BACKEND_DIR="$2"
      shift 2
      ;;
    --frontend)
      [[ "${2:-}" ]] || fail "--frontend requires a value"
      FRONTEND_DIR="$2"
      shift 2
      ;;
    --local-agent)
      USE_LOCAL_AGENT=1
      shift
      ;;
    --deepv4)
      USE_DEEPV4=1
      USE_LOCAL_AGENT=1
      shift
      ;;
    --gupo)
      USE_GUPO=1
      PROFILE="gupo"
      shift
      ;;
    --backup)
      BACKUP=1
      FORCE=0
      shift
      ;;
    --force)
      FORCE=1
      BACKUP=0
      shift
      ;;
    --init-git)
      INIT_GIT=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      fail "Unknown option: $1"
      ;;
  esac
done

[[ -n "$PROJECT_DIR" ]] || { usage; exit 2; }

PROJECT_DIR="${PROJECT_DIR/#\~/$HOME}"
mkdir -p "$PROJECT_DIR"
PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"
PROJECT_NAME="${PROJECT_NAME:-$(basename "$PROJECT_DIR")}"

if [[ "$PROJECT_DIR" == "$ROOT" ]]; then
  fail "Refusing to install into control-system repository itself"
fi

if [[ "$USE_LOCAL_AGENT" -eq 1 && "$PROFILE" == "default" ]]; then
  PROFILE="local-agent"
fi

if [[ "$USE_GUPO" -eq 1 && "$USE_LOCAL_AGENT" -eq 0 ]]; then
  PROFILE="gupo"
fi

if [[ "$INIT_GIT" -eq 1 && "$DRY_RUN" -eq 0 ]]; then
  if ! git -C "$PROJECT_DIR" rev-parse --git-dir >/dev/null 2>&1; then
    git -C "$PROJECT_DIR" init
  fi
fi

INSTALL_ARGS=(--profile "$PROFILE")
if [[ "$DRY_RUN" -eq 1 ]]; then
  INSTALL_ARGS+=(--dry-run)
elif [[ "$FORCE" -eq 1 ]]; then
  INSTALL_ARGS+=(--force)
elif [[ "$BACKUP" -eq 1 ]]; then
  INSTALL_ARGS+=(--backup)
fi

printf 'Project: %s\n' "$PROJECT_NAME"
printf 'Directory: %s\n' "$PROJECT_DIR"
printf 'Profile: %s\n' "$PROFILE"
printf 'Local Agent: %s\n' "$([[ "$USE_LOCAL_AGENT" -eq 1 ]] && echo yes || echo no)"
printf 'deepv4: %s\n' "$([[ "$USE_DEEPV4" -eq 1 ]] && echo yes || echo no)"
printf 'gupo: %s\n' "$([[ "$USE_GUPO" -eq 1 ]] && echo yes || echo no)"

"$ROOT/scripts/install-to-project.sh" "${INSTALL_ARGS[@]}" "$PROJECT_DIR"

if [[ "$DRY_RUN" -eq 1 ]]; then
  printf 'Dry run completed. No files written.\n'
  exit 0
fi

if [[ "$USE_LOCAL_AGENT" -eq 1 && "$USE_GUPO" -eq 1 && "$PROFILE" != "gupo" ]]; then
  "$ROOT/scripts/install-to-project.sh" \
    --backup \
    --only "tools/codegen/java-springboot-crud-adapters/gupo" \
    --only ".codex/skills/codegen-java-springboot-gupo-crud" \
    "$PROJECT_DIR"
fi

"$ROOT/scripts/init-project.sh" --name "$PROJECT_NAME" --force "$PROJECT_DIR"

if [[ "$USE_GUPO" -eq 1 ]]; then
  mkdir -p "$PROJECT_DIR/.codex"
  cat > "$PROJECT_DIR/.codex/codegen.toml" <<'TOML'
[java.springboot.crud]
adapter = "gupo"
TOML
fi

if [[ "$USE_LOCAL_AGENT" -eq 1 ]]; then
  ENV_FILE="$PROJECT_DIR/.agent/local-agent.env"
  mkdir -p "$(dirname "$ENV_FILE")"
  if [[ ! -f "$ENV_FILE" ]]; then
    cp "$ROOT/templates/local-agent.env.example" "$ENV_FILE"
  fi

  TEST_COMMAND="$(detect_test_command "$PROJECT_DIR" "$BACKEND_DIR" "$FRONTEND_DIR")"
  if [[ -n "$TEST_COMMAND" ]]; then
    replace_or_append_env "$ENV_FILE" "PROJECT_TEST_COMMAND" "'$TEST_COMMAND'"
  fi

  if [[ "$USE_DEEPV4" -eq 1 ]]; then
    replace_or_append_env "$ENV_FILE" "DEEPV4_BASE_URL" "'https://api.example.com/v1'"
    replace_or_append_env "$ENV_FILE" "DEEPV4_API_KEY" "'replace-with-your-key'"
    replace_or_append_env "$ENV_FILE" "DEEPV4_MODEL" "'deepv4'"
    replace_or_append_env "$ENV_FILE" "DEEPV4_TEMPERATURE" "'0.1'"
    replace_or_append_env "$ENV_FILE" "DEEPV4_REVIEW_COMMAND" "'bash scripts/providers/deepv4-openai-compatible.sh'"
  fi

  if ! grep -q '^\.agent/' "$PROJECT_DIR/.gitignore" 2>/dev/null; then
    printf '.agent/\n' >> "$PROJECT_DIR/.gitignore"
  fi
fi

if [[ -x "$PROJECT_DIR/scripts/skill-check.sh" ]]; then
  "$PROJECT_DIR/scripts/skill-check.sh"
fi

if [[ -x "$PROJECT_DIR/scripts/docs-link-check.sh" ]]; then
  "$PROJECT_DIR/scripts/docs-link-check.sh"
fi

printf 'Bootstrap completed: %s\n' "$PROJECT_DIR"
