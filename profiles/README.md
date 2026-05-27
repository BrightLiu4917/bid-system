# Profiles

profile 用来控制 `scripts/install-to-project.sh` 复制哪些控制系统文件到目标项目。

## 格式

每个 profile 位于：

```text
profiles/<profile-name>/profile.toml
```

当前安装脚本只解析 `items = [...]` 和 `exclude_items = [...]`，这是刻意保持的简单 TOML 子集，避免引入新依赖。

```toml
name = "default"
description = "完整安装"
items = [
  "AGENTS.md",
  "CODEX_TASK_TEMPLATE.md",
  "openspec",
  "docs",
  ".codex",
  "tools/codegen/java-springboot-crud-adapters/README.md",
  "tools/codegen/java-springboot-crud-adapters/generic",
  "scripts",
  "templates",
  "profiles",
  "CONTEXT.md",
  "CONTEXT-MAP.md"
]

exclude_items = [
  ".codex/skills/codegen-java-springboot-gupo-crud"
]
```

## 使用

```bash
bash scripts/install-to-project.sh --dry-run --profile default /path/to/project
bash scripts/install-to-project.sh --backup --profile minimal /path/to/project
bash scripts/install-to-project.sh --backup --profile local-agent /path/to/project
bash scripts/install-to-project.sh --backup --profile gupo /path/to/gupo-project
bash scripts/install-to-project.sh --only AGENTS.md --only docs /path/to/project
```

## 约束

- `items` 必须是仓库内相对路径。
- `exclude_items` 可排除文件或目录；匹配目录时会排除其子路径。
- 禁止使用绝对路径或 `..`。
- 默认安装遇到冲突会失败。
- 需要覆盖时显式使用 `--force`。
- 需要保留目标文件备份时使用 `--backup`。
- `default` 不包含公司专用 codegen adapter skill 或工具。
- gupo 项目使用 `profiles/gupo/profile.toml`。
- 需要 OpenCode/qianwen-coder 本地执行闭环时，使用 `profiles/local-agent/profile.toml`。
- `local-agent` 默认不包含 gupo 专用 adapter；如果目标项目同时需要本地 Agent 和 gupo adapter，优先使用 `scripts/setup-control-system.sh`，或安装后单独 `--only` 安装 gupo adapter。
- gupo profile 使用 `.codex` 整体安装并通过 `exclude_items` 排除旧兼容入口，避免新增 skill 后漏装。
