# Proposal

## Why
当前控制系统已经完成 skill 重命名、路由文档和部分公共模板，但安装、profile、校验脚本、上下文文档、规则细节和示例仍停留在半完成状态。继续保留这些残留会让目标项目安装时覆盖风险不可见，也会让后续 skill 创建、路由检查和文档链接检查缺少自动安全网。

## What
- 增强 `scripts/install-to-project.sh`，支持 dry-run、backup、force、merge、only、profile 和 summary。
- 新增 `profiles/` 目录，定义 profile 格式、默认 profile 和最小 profile。
- 新增 `scripts/skill-check.sh`、`scripts/route-check.sh`、`scripts/docs-link-check.sh`、`scripts/new-skill.sh`。
- 同步 README、任务模板、CONTEXT、CONTEXT-MAP 和规则文档，使其与 `docs/SKILL_ROUTING.md` 一致。
- 补充 examples，提供 OpenSpec change、API contract 和 review report 示例。
- 将 skill 文档中残留的英文标题或正文说明调整为中文优先，保留技术名和 skill name。

## Non-Goals
- 不修改数据库、SQL migration、业务接口、后端运行时代码或前端运行时代码。
- 不新增外部依赖。
- 不改变 `.codex/skills/<skill-name>/SKILL.md` 的一层发现结构。
- 不删除兼容入口；兼容入口只保持指向新主入口。

## Impact
- 产品/业务：无目标业务规则变化，仅完善控制系统自身用法和约束。
- UX/UI：无页面变化。
- 前端：无前端运行时代码变化。
- API：无 API 变化。
- 后端：无后端运行时代码变化。
- 数据库：无数据库变化。
- 测试：新增脚本级检查，可用于安装前后验证。
- 发布：安装脚本默认更保守，存在冲突时需要显式 `--force` 或 `--merge`。

## Risks
- 安装脚本行为从直接覆盖改为默认拒绝冲突，可能改变旧用户习惯。
- `--merge` 对文件只保留目标文件，不做语义合并；目录合并仍可能遇到同名文件冲突。
- 文档中文化可能无法覆盖所有技术名，但会保持描述和正文中文优先。

## Open Questions
- 无影响正确性的待确认问题。用户已确认继续收口残留项。
