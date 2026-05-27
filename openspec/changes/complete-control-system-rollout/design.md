# Design

## Overview
本次变更只触及控制系统自身的脚本、文档、模板、profile 和示例。安装脚本采用保守默认策略：dry-run 可预览，冲突默认失败，`--backup` 负责备份目标文件，`--force` 才允许覆盖，`--merge` 允许目录级合并但不会静默覆盖同名文件。

## Install Script
- 参数：
  - `--dry-run`：只输出计划，不复制。
  - `--backup`：冲突时先备份目标路径到 `.codex-install-backup/<timestamp>/`。
  - `--force`：允许覆盖目标路径。
  - `--merge`：目录合并；文件冲突仍需 `--force` 或 `--backup`。
  - `--only <item>`：只安装指定条目，可重复。
  - `--profile <name|path>`：按 profile 安装条目。
- 默认 profile 为 `profiles/default/profile.toml`。
- summary 输出包含 installed、skipped、backed up、conflicts。

## Profiles
`profiles/<name>/profile.toml` 使用简单 TOML 子集：

```toml
name = "default"
description = "完整控制系统"
items = [
  "AGENTS.md",
  "CODEX_TASK_TEMPLATE.md"
]
```

脚本只解析 `items = [...]`，避免引入 TOML 依赖。README 负责说明格式和约束。

## Checks
- `skill-check.sh` 检查 `.codex/skills/*/SKILL.md` 一层结构、frontmatter name 与目录名一致、description 存在、兼容入口没有承载完整规则。
- `route-check.sh` 检查 `docs/SKILL_ROUTING.md` 是否覆盖主入口、兼容入口、并行/循环/回退和 AGENTS 引用。
- `docs-link-check.sh` 检查 Markdown 相对链接指向存在文件。
- `new-skill.sh` 从 `templates/skill/SKILL.md` 生成新 skill，并阻止覆盖已有目录。

## Documentation
- README 作为安装和总览入口，引用 `docs/SKILL_ROUTING.md`，补 profiles 和 scripts。
- CODEX_TASK_TEMPLATE 补任务分级和快速通道说明。
- CONTEXT/CONTEXT-MAP 记录本项目控制系统术语，不使用虚构业务场景。
- UX/PERFORMANCE/CODE_REVIEW 规则补可执行细节。

## Rollback
回滚方式为移除新增文件并恢复被修改的 Markdown/Bash 文件。没有数据库或运行时迁移。
