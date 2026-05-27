# Codegen Adapters Spec Delta

## MODIFIED Requirements

### Requirement: generic adapter 缺失时允许生产级手写实现
系统 SHALL 在通用 Java Spring Boot CRUD adapter 不可用时，允许用户确认后转入 `backend-java-springboot` 进行生产级手写实现。

#### Scenario: 非 gupo 项目需要 CRUD 能力
- GIVEN 目标项目不是 gupo 项目
- AND generic adapter 尚未实现
- WHEN 用户确认允许 AI 手写实现
- THEN 系统转入 `backend-java-springboot`
- AND 遵循 API contract、DBA、测试和 release review 流程
- AND 不使用 gupo adapter。

#### Scenario: 手写实现缺少业务规则
- GIVEN 字段含义、权限、租户、状态流转或 API 响应不清楚
- WHEN 用户要求继续实现
- THEN 系统停止询问
- AND 不发明规则或伪实现。
