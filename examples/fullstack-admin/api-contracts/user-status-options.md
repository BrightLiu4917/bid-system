# API Contract: User Status Options

## Endpoint
- Method: `GET`
- Path: `/admin/users/status-options`
- Auth: `admin:user:view`

## Request
```json
{}
```

## Response
```json
{
  "code": 0,
  "message": "success",
  "data": [
    {
      "label": "正常",
      "value": "ACTIVE"
    }
  ]
}
```

## Errors
- `FORBIDDEN`: 无用户列表查看权限。

## Pagination
- list/data: 不分页，返回 `data` 数组。
- total: 不适用。
- pageNum/current: 不适用。
- pageSize: 不适用。

## 兼容性
- 是否兼容：新增接口，不破坏既有接口。
- 影响前端：用户列表筛选控件依赖该接口。

## Security
- 敏感字段：不返回用户数据。
- 权限：需要用户列表查看权限。
- 租户：如果状态选项受租户配置影响，必须按当前租户返回。
