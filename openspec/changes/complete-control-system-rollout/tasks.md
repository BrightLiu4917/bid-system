# Tasks

## Spec
- [x] 记录本次收口范围。
- [x] 明确不涉及 DB、API、业务运行时代码。

## Implementation
- [x] 增强 `scripts/install-to-project.sh`。
- [x] 新增 `profiles/` 目录、profile 示例和 README。
- [x] 新增 `scripts/skill-check.sh`、`scripts/route-check.sh`、`scripts/docs-link-check.sh`、`scripts/new-skill.sh`。
- [x] 同步 README、CODEX_TASK_TEMPLATE、CONTEXT、CONTEXT-MAP。
- [x] 补充 UX、性能、代码审查规则。
- [x] 补齐 examples 示例。
- [x] 中文化 skill 文档残留英文标题或描述。

## Verification
- [x] 运行 `bash scripts/skill-check.sh`。
- [x] 运行 `bash scripts/route-check.sh`。
- [x] 运行 `bash scripts/docs-link-check.sh`。
- [x] 运行 `bash scripts/openspec-check.sh openspec/changes/complete-control-system-rollout`。
- [x] 运行 `bash scripts/install-to-project.sh --dry-run --profile default /private/tmp/ai-fullstack-control-system-install-check`。
- [x] 运行 `bash scripts/new-skill.sh --dry-run sample-demo "示例 skill，用于验证生成脚本。"`。
- [x] 运行真实安装和默认冲突预检。
- [x] 做发布前变更审查。
