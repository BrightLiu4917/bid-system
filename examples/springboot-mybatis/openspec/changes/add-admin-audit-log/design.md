# Design

## Overview
查询能力以只读分页接口为边界。实现前必须通过 `dba-mysql` 确认表结构、字段含义、索引和历史数据规模。

## API
- Method: `GET`
- Path: `/admin/audit-logs`
- Auth: 需要后台审计日志查看权限。
- Request: 分页参数、操作人、操作类型、业务对象、开始时间、结束时间。
- Response: 分页列表，隐藏敏感请求内容。

## Data
- 表：待确认。
- 字段：待确认。
- 索引：建议待 DBA 根据实际查询条件确认。
- 迁移：没有明确 migration SQL 前不得修改表。

## Backend
- Controller 只做参数接收和响应包装。
- Service 负责业务校验、权限检查和查询条件组装。
- Mapper/XML 只承载 SQL。
- 查询必须包含租户隔离和软删除条件，如项目存在这些模型。

## Rollback
只读接口可通过下线路由或回滚代码关闭；如后续涉及建表，必须提供单独 rollback SQL。
