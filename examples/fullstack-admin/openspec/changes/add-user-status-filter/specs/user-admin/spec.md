# User Admin Spec Delta

## ADDED Requirements

### Requirement: 用户列表应支持按已确认状态筛选
系统 SHALL 允许运营人员在用户列表中选择已确认的用户状态进行筛选。

#### Scenario: 按状态筛选用户
- GIVEN 运营人员拥有用户列表查看权限
- WHEN 运营人员选择一个用户状态
- THEN 列表只展示匹配该状态的用户
- AND 分页信息与筛选结果一致。

### Requirement: 状态筛选不得发明枚举值
系统 SHALL 从后端事实源或已确认规格读取状态选项。

#### Scenario: 状态选项加载
- GIVEN 用户列表页需要展示状态筛选
- WHEN 页面加载状态选项
- THEN 状态值来自已确认来源
- AND 前端不得硬编码未确认状态。
