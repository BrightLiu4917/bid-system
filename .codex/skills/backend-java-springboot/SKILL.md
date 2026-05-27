---
name: backend-java-springboot
description: 生产级 Java Spring Boot 后端实现 skill，基于 Java 17、Spring Boot、MyBatis-Plus、MyBatis XML、DTO/VO、事务和既有约定实现后端接口、Service、Mapper/XML、业务校验和状态流。
---

# Java Spring Boot 后端实现

## 适用场景
- 实现或修改 Spring Boot 后端接口、Service、Mapper/XML、DTO/VO、业务校验或事务逻辑。
- 用户要求修复后端 bug、补充接口、调整查询、保存、审批、状态流或分页。
- 需要遵循 Java 17、MyBatis-Plus、MyBatis XML、MySQL 8 和项目既有约定。

## 必须读取
- `AGENTS.md`
- `CONTEXT.md` 或 `CONTEXT-MAP.md`
- `docs/SPRING_BOOT_RULES.md`
- `docs/BACKEND_RULES.md`
- `docs/API_RULES.md`
- `docs/DB_SCHEMA_RULES.md`
- 相关 OpenSpec specs/changes

## Skill 路由
- 标准 CRUD 脚手架生成必须改用 `codegen-java-springboot-crud` 先识别 adapter；generic adapter 只允许生成审查预览包，真实落地时可在用户确认后由本 skill 做生产级实现。
- 涉及数据库表结构、字段、索引、迁移、回滚或高风险 SQL 时，必须先使用 `dba-mysql`。
- 涉及 API 契约时，必须先使用 `backend-common-api-contract-review`。
- Bug 修复应先使用 `method-diagnose` 建立反馈回路。

## 编码前
1. 定位既有包结构。
2. 定位统一响应类。
3. 定位全局异常类。
4. 定位既有 Mapper/XML 风格。
5. 定位既有 DTO/VO 命名方式。
6. 定位认证、租户、权限、软删除和分页的既有实现。
7. 定位既有抽象：BaseController、BaseService、分页对象、查询条件对象、转换器、枚举和审计字段，如项目存在。
8. 如果字段、状态、权限、租户、删除、通知、时间冲突、支付或响应格式不清楚，必须先询问。

## 实现流程
1. 先阅读受影响模块的 Controller、Service、ServiceImpl、Mapper、XML、DTO、VO、Entity 和相关测试。
2. 给出最小实现计划，明确受影响文件和不修改的边界。
3. 明确数据库影响：涉及哪些表、字段、索引、历史数据、迁移和回滚。
4. 明确 API 影响：新增、修改、删除的路径、请求 DTO、响应 VO、分页结构。
5. 按既有分层实现：Controller -> Service -> ServiceImpl -> Mapper -> XML -> Database。
6. Controller 只做参数接收、基础校验、调用 Service 和返回统一响应。
7. Service/ServiceImpl 处理业务校验、权限、状态流、事务、缓存协调和通知触发。
8. Mapper 只定义持久化方法，XML 写显式 SQL。
9. 涉及多表写入、状态变更、扣减、日志、订单、通知时使用 `@Transactional`。
10. 单个业务动作写入或修改超过一张表时，必须使用 `@Transactional`，并说明事务覆盖的写操作。
11. 实现后运行可行的编译、单测或最小验证命令；无法运行时说明原因。

## 手写 CRUD 质量门槛
generic adapter 只生成审查预览包，用户确认真实落地时必须满足：
- 先复用既有项目抽象，禁止重新发明统一响应、分页、异常、权限、租户或软删除模型。
- Controller 只保留薄层入口；复杂编排进入 Service。
- Service 方法按业务动作命名，避免只有机械 `save/update/delete` 且无语义边界的大方法。
- DTO/VO 与 Entity 分离；除非项目既有约定允许，禁止直接返回 Entity。
- 查询条件、分页、排序、租户、软删除和权限条件必须集中、清晰、可测试。
- Mapper/XML 使用显式字段，禁止 `SELECT *`。
- 新增抽象必须说明职责、调用方和为什么现有抽象不够。
- 至少补充关键路径测试或说明可运行的最小验证命令。

## 数据库影响报告
只要涉及表结构、字段、索引或 SQL 写入变化，必须明确列出：
- 受影响表。
- 新增字段。
- 修改字段。
- 删除字段。
- 字段类型变化。
- 默认值变化。
- 是否必填变化。
- 字段含义变化。
- 索引变化。
- 历史数据影响。
- migration SQL。
- rollback SQL。
- 受影响 Entity、Mapper/XML、DTO、VO、API。

更新表结构前，必须先把 Entity、Mapper/XML、DTO、VO、API 的联动改动清单输出给用户，并等待确认。

## 停止并询问
- 字段含义、枚举值、状态转换、权限、租户、删除行为或响应格式不明确。
- 需要新增依赖、修改表结构、改变 API 兼容性或调整既有架构。
- 需求需要业务决策，例如扣减规则、冲突规则、通知规则、支付规则。
- 找不到既有统一响应、异常、分页、租户或权限约定。
- 用户要求生成完整 CRUD 脚手架，但 adapter 未确认。
- 用户要求手写 CRUD，但尚未确认允许手写或缺少关键业务/契约/数据规则。
- 表结构或字段变化会影响历史数据，但没有明确迁移策略。
- 需要执行 CREATE、UPDATE、DELETE、ALTER、DROP、TRUNCATE 或高风险 SQL，但用户尚未确认。

## 禁止事项
- 除非既有项目已经使用 JPA，否则禁止引入 JPA。
- 禁止在 Controller 中编写业务逻辑。
- 禁止在 Service 中拼接 SQL 字符串。
- 禁止使用 `SELECT *`。
- 禁止无关重构。
- 禁止伪实现。
- 禁止手工拼低质量模板式 CRUD；禁止把 gupo adapter 用于非 gupo 项目。
- 禁止为了凑层数创建无业务含义的空方法或伪抽象。
- 禁止新增依赖，除非用户明确批准。
- 禁止直接返回 Entity，除非项目既有约定允许。
- 禁止吞异常或向前端暴露堆栈。

## 输出内容
- 实施计划。
- 变更文件。
- 代码变更。
- SQL 变更。
- 表结构/字段变化。
- API 变化。
- 事务边界。
- 数据兼容和迁移/回滚。
- 验证步骤。
- 假设和风险。
