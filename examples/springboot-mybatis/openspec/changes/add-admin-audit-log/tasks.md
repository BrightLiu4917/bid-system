# Tasks

## Spec
- [ ] 确认审计日志能力边界。
- [ ] 确认表结构、字段含义、租户和软删除规则。
- [ ] 确认 API 契约。

## Implementation
- [ ] 通过 `dba-mysql` 审查表结构和索引。
- [ ] 通过 `backend-common-api-contract-review` 审查接口路径、请求和响应。
- [ ] 实现 Controller、Service、Mapper/XML。
- [ ] 补充测试。

## Verification
- [ ] 分页查询正常。
- [ ] 筛选条件正常。
- [ ] 无权限用户不可查询。
- [ ] 响应不包含敏感字段。
- [ ] SQL 不使用 `SELECT *`。
