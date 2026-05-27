# Proposal

## Why
通用 Java Spring Boot CRUD adapter 当前尚未实现。如果规则简单禁止手写 CRUD，会导致非 gupo 项目无法推进必要的后端功能。正确边界应是：禁止把 gupo adapter 当通用脚手架，禁止低质量模板拼接；但允许 AI 在没有可用通用 adapter 时，按生产级后端实现流程手写代码。

## What
- 明确 generic adapter 不可用时，可以转入 `backend-java-springboot` 手写实现。
- 手写实现必须高标准：先读既有项目抽象、复用统一响应/分页/异常/权限/租户/事务/Mapper 风格，不新增未确认依赖，不发明字段和业务规则。
- CRUD 手写仍需 OpenSpec、API contract、DBA、测试和 release review 约束。
- 更新 codegen 路由、后端规则、Spring Boot 规则、README 和 adapter 文档。

## Non-Goals
- 不实现 generic adapter。
- 不允许用 gupo adapter 生成非 gupo 项目。
- 不允许伪代码、空方法、TODO 实现或粗糙模板拼接。
- 不放松 DB/API/权限/租户/状态流转确认要求。

## Impact
- 后端：非 gupo 项目可在 adapter 缺失时走生产级手写实现。
- codegen：`codegen-java-springboot-crud` 仍只做 adapter 判定，不生成代码。
- 测试/审查：手写 CRUD 必须接受更严格的架构、契约、DB 和测试审查。

## Risks
- 手写实现比生成器更依赖工程判断，必须通过更强的上下文阅读和验证降低风险。
- 如果项目既有抽象不清楚，必须停止询问，不能自行发明。

## Open Questions
- 无。用户已确认 generic adapter 为空时允许 AI 开发代码，但必须高级、抽象封装好且严谨。
