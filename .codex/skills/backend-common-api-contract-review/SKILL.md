---
name: backend-common-api-contract-review
description: 审查 API 路径、请求 DTO、响应 VO、分页、兼容性、错误码、敏感字段和前后端契约。用于任何接口新增、修改或删除。
---

# API 契约审查

## 必须读取
- `AGENTS.md`
- `docs/API_RULES.md`
- 相关 OpenSpec specs/changes

## 流程
1. 明确新增、修改或删除的 API。
2. 检查请求字段、校验、默认值和分页参数。
3. 检查响应结构、VO、敏感字段和兼容性。
4. 检查前端调用方影响。
5. 输出契约风险和修复建议。

## 输出
- API 路径
- 请求 DTO
- 响应 VO
- 分页结构
- 兼容性影响
- 前端联动
- 待确认问题
