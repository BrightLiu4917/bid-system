# API Contract: Admin Audit Log List

## Endpoint
- Method: `GET`
- Path: `/admin/audit-logs`
- Auth: `admin:audit-log:view`

## Request
```json
{
  "pageNum": 1,
  "pageSize": 20,
  "operatorId": 10001,
  "operationType": "UPDATE",
  "targetType": "USER",
  "startTime": "2026-05-01T00:00:00+08:00",
  "endTime": "2026-05-09T23:59:59+08:00"
}
```

## Response
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "list": [
      {
        "id": 1,
        "operatorId": 10001,
        "operatorName": "admin",
        "operationType": "UPDATE",
        "targetType": "USER",
        "targetId": "20001",
        "summary": "更新用户状态",
        "createdAt": "2026-05-09T10:30:00+08:00"
      }
    ],
    "total": 1,
    "pageNum": 1,
    "pageSize": 20
  }
}
```

## Errors
- `FORBIDDEN`: 无审计日志查看权限。
- `INVALID_TIME_RANGE`: 时间范围无效。

## Pagination
- list/data: `data.list`
- total: `data.total`
- pageNum/current: `data.pageNum`
- pageSize: `data.pageSize`

## 兼容性
- 是否兼容：新增接口，不破坏既有接口。
- 影响前端：需要新增审计日志列表页或接入既有页面。

## Security
- 敏感字段：不返回完整请求体、密码、token、private key 或生产连接串。
- 权限：需要审计日志查看权限。
- 租户：如项目存在租户模型，必须按租户隔离。
