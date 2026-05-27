# Tasks

## Spec
- [x] 记录 generic adapter 缺失时允许手写实现的边界。
- [x] 明确不放松 DB/API/权限/租户/业务规则确认要求。

## Implementation
- [x] 更新 `codegen-java-springboot-crud` 路由规则。
- [x] 更新 `backend-java-springboot`、兼容入口和 routing 文档。
- [x] 补充 `docs/SPRING_BOOT_RULES.md` 和 `docs/BACKEND_RULES.md` 的高级手写实现标准。
- [x] 更新 README 和 adapter 文档。
- [x] 更新检查脚本，允许 adapter 缺失时转入后端实现但禁止 gupo 误用。

## Verification
- [x] 运行 `bash scripts/skill-check.sh`。
- [x] 运行 `bash scripts/route-check.sh`。
- [x] 运行 `bash scripts/docs-link-check.sh`。
- [x] 运行 `bash scripts/openspec-check.sh openspec/changes/allow-manual-springboot-crud-when-generic-adapter-missing`。
- [x] 搜索确认无“adapter 缺失时禁止开发”的绝对表述。
- [x] 做发布前变更审查。
