---
name: dba-mysql
description: 生产级 MySQL 8 DBA skill，设计和审查表结构、字段、索引、迁移 SQL、回滚 SQL、种子数据、查询性能、租户隔离和软删除。用于数据库、SQL、索引、数据兼容和生产数据安全任务。
---

# MySQL DBA

## 适用场景
- 创建或修改 MySQL 8 表结构、索引、字段、约束或初始化数据。
- 编写迁移 SQL、rollback SQL、查询 SQL、批量 UPDATE/DELETE。
- 审查 SQL 的租户隔离、软删除、索引命中、兼容性和生产安全。

## 必须读取
- `AGENTS.md`
- `docs/DB_SCHEMA_RULES.md`
- 相关 OpenSpec specs/changes

## 执行流程
1. 先读取既有表结构、Mapper/XML、迁移脚本和相关业务代码。
2. 确认需求是否明确要求创建或修改表结构。
3. 对照既有命名、字段类型、字符集、排序规则、ID 规则和审计字段。
4. 设计 SQL 时同时考虑 forward SQL、必要 rollback SQL、索引影响和兼容性风险。
5. 写查询 SQL 时显式列名，确认租户条件、软删除条件和索引条件。
6. 写 UPDATE/DELETE 时确认精确 WHERE、影响范围和是否需要事务。
7. CREATE、UPDATE、DELETE、ALTER、DROP、TRUNCATE 或高风险 SQL 执行前，必须向用户确认。
8. 更新表结构前，必须先输出 Entity、Mapper/XML、DTO、VO、API 的联动改动清单并等待确认。
9. 删除表或截断表前，必须先输出备份方案，备份表名使用 `原表名_copy_yyyyMMdd`，并等待用户确认。
10. 无法确认业务含义、状态枚举或数据范围时，停止并询问。

## 必须检查
- 租户隔离。
- 软删除。
- 索引使用。
- 字符集和排序规则一致性。
- 回滚策略。
- 数据兼容性。
- `pk_id` 与 `id` 的使用边界：`pk_id` 为自增内部主键，`id` 为雪花算法业务 ID；业务关联和对外 API 使用 `id`，内部关联在不对外暴露的场景下可使用 `pk_id`。
- 时间字段精度和默认值。
- 批量操作的影响范围。
- 单个业务动作写入或修改超过一张表时是否需要事务。
- Entity/Mapper/XML/DTO/VO/API 与表结构是否一致。

## 禁止事项
- 禁止使用 `SELECT *`。
- 禁止全表 UPDATE/DELETE。
- 未经批准，禁止 DROP。
- 未经确认，禁止执行 CREATE、UPDATE、DELETE、ALTER、DROP、TRUNCATE。
- 除非既有约定要求，否则禁止使用含义不清的 `status` 字段。
- 未经确认，禁止执行生产破坏性 SQL。
- 禁止发明字段、枚举、表关系或租户规则。
- 禁止在没有迁移 SQL 的情况下变更表结构。
- 禁止物理删除，除非用户明确确认。

## 输出内容
- 实施计划。
- 影响表和影响字段。
- DDL/DML。
- 用户确认项：CREATE/UPDATE/DELETE/ALTER/DROP/TRUNCATE 或高风险 SQL 的确认状态。
- 存在风险时提供 rollback SQL。
- DROP/TRUNCATE 备份方案：原表名、备份表名、备份 SQL、校验 SQL、执行 SQL。
- Entity/Mapper/XML/DTO/VO/API 联动改动清单。
- 索引设计和查询路径说明。
- 租户隔离与软删除说明。
- 兼容性、数据安全和生产风险。
- 验证步骤。
