# Tasks

## Spec
- [x] 记录 gupo adapter 拆分范围。
- [x] 明确本次不实现通用 CRUD 脚手架。

## Implementation
- [x] 新增 `codegen-java-springboot-gupo-crud` skill，并将现有执行规则迁入。
- [x] 将 `codegen-java-springboot-crud` 改为 adapter 路由入口。
- [x] 移动工具目录到 `tools/codegen/java-springboot-crud-adapters/gupo/`。
- [x] 新增 adapter registry README、generic 占位和 gupo `adapter.toml`。
- [x] 新增 `profiles/gupo` 并调整 default profile。
- [x] 更新 AGENTS、README、SKILL_ROUTING、SKILL_NAMING_RULES、相关 skill 和 review 规则。
- [x] 更新检查脚本对 codegen adapter 的校验。

## Verification
- [x] 运行 `bash scripts/skill-check.sh`。
- [x] 运行 `bash scripts/route-check.sh`。
- [x] 运行 `bash scripts/docs-link-check.sh`。
- [x] 运行 `bash scripts/openspec-check.sh openspec/changes/split-gupo-codegen-adapter`。
- [x] 运行 `bash -n` 检查 gupo adapter 脚本。
- [x] 运行安装脚本 dry-run 验证 default、minimal 和 gupo profiles。
- [x] 做发布前变更审查。
