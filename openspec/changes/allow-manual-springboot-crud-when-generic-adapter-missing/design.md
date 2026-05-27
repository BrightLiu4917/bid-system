# Design

## Route

```text
codegen-java-springboot-crud
-> codegen-java-springboot-gupo-crud，如 adapter 确认为 gupo
-> backend-java-springboot，如 generic adapter 缺失且用户确认允许手写实现
-> STOP and ASK，如 adapter、字段、契约、权限、租户或业务规则不清
```

## Manual Implementation Bar
手写实现必须满足：

- 先使用 `method-zoom-out` 梳理既有后端分层、包结构、统一响应、分页、异常、权限、租户和 Mapper/XML 风格。
- 如涉及 API，先走 `backend-common-api-contract-review`。
- 如涉及 DB/SQL/索引/表字段，先走 `dba-mysql`。
- 实现入口为 `backend-java-springboot`，不是 codegen skill。
- 测试优先走 `method-tdd`，至少覆盖关键行为、参数校验、权限/租户、分页和异常路径。
- 交付前走 `release-production-review`。

## Quality Rules
- 优先复用既有 Base 类、统一响应、分页对象、异常类型、权限注解、租户上下文、软删除字段和 Mapper/XML 约定。
- 只在既有模式无法承载复杂度时新增抽象。
- 新增抽象必须有明确命名、单一职责、调用边界和测试保护。
- Controller 不写业务逻辑。
- Service 负责业务编排，复杂查询放到 Mapper/XML。
- 禁止把 Entity 直接作为响应，除非项目既有约定允许。
- 禁止为了“像脚手架”而创建空方法或无业务含义的层。

## Rollback
本 change 只调整规则和文档，无运行时代码迁移。
