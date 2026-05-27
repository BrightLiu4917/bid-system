---
name: release-production-review
description: 生产上线前综合审查 skill，结合原 reviewer 规则，按业务正确性、数据安全、安全性、事务、API/前端兼容、SQL 性能、测试和发布风险审查变更。
---

# 生产上线审查

## 适用场景
- 用户要求 review、code review、审查变更、检查风险、上线前检查。
- 需要判断代码是否符合 `AGENTS.md`、OpenSpec、产品/业务/UX/API/后端/DB/安全/测试/发布规则。
- 需要优先发现阻塞问题，而不是总结代码做了什么。

## 必须读取
- `AGENTS.md`
- `docs/CODE_REVIEW_RULES.md`
- 相关 OpenSpec specs/changes
- 相关 `docs/`

## 审查流程
1. 先识别变更范围和用户意图。
2. 阅读相关 diff、受影响文件和被调用的既有代码。
3. 按优先级检查业务正确性、数据安全、安全性、事务、兼容性、性能和可维护性。
4. 只报告可定位、可复现、会影响生产或维护质量的问题。
5. 每条问题必须说明影响、触发条件和建议修复方向。
6. 如果没有发现问题，明确说明未发现阻塞问题，并列出剩余测试缺口。

## 必查项
- 是否猜测业务规则、字段、状态流、权限或响应格式。
- CRUD 脚手架是否先通过 `codegen-java-springboot-crud` 识别 adapter，而不是手工拼文件。
- gupo 脚手架是否仅用于 gupo 项目，且通过 `codegen-java-springboot-gupo-crud` 执行。
- generic adapter 只生成审查预览包；真实落地是否经用户确认并通过 `backend-java-springboot` 或项目专用 adapter 执行。
- 手写 CRUD 是否复用既有抽象，避免低质量模板拼接、伪抽象、空方法或 TODO 实现。
- CRUD 生成脚本是否与项目 adapter 和 Spring Boot 版本匹配。
- CRUD 生成输出是否明确包含 adapter、adapter 判断依据、Spring Boot 版本、版本判断依据和实际使用脚本。
- 表结构、字段、索引、默认值、是否必填或字段含义变化是否有明确清单。
- 表结构变化是否有 migration SQL、必要 rollback SQL 和历史数据兼容策略。
- 高风险 SQL 变更是否已获得用户确认。
- DROP/TRUNCATE 是否先按 `原表名_copy_yyyyMMdd` 备份，并提供备份 SQL、校验 SQL 和用户确认记录。
- 后端代码中的 Entity/DTO/VO 字段是否与数据库表结构一致。
- SQL 是否存在 N+1 查询、缺失索引、大表全表扫描或笛卡尔积风险。
- 多表写入、状态变更、扣减、日志记录是否有事务边界。
- 单个业务动作写入或修改超过一张表时是否使用 `@Transactional`。
- SQL 是否存在 `SELECT *`、租户隔离缺失、软删除缺失或危险 UPDATE/DELETE。
- Controller 是否包含业务逻辑或直接访问 Mapper/Redis。
- API 响应格式、路径、分页结构是否破坏兼容性。
- 前端是否缺失加载态、空态、错误态、权限态或重复提交防护。
- 是否暴露敏感字段、异常堆栈、token、密码或隐私数据。
- 是否引入未经批准的依赖、架构变化或无关重构。

## 审查格式
1. 阻塞问题
2. 重要问题
3. 次要建议
4. 表结构/字段变化审查
5. Entity/DTO/VO 与表结构一致性审查
6. API/前端契约审查
7. SQL 性能风险审查
8. 安全和权限审查
9. 验证步骤
10. 风险总结

## 输出要求
- 问题优先于总结，按严重程度排序。
- 每个问题包含文件路径、行号或最小可定位范围。
- 没有问题时，也必须说明验证范围和残余风险。
- 不输出无依据的猜测；证据不足时列为待确认问题。
