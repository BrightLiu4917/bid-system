# Codegen Adapters Spec Delta

## ADDED Requirements

### Requirement: CRUD 代码生成必须先选择 adapter
系统 SHALL 在 Java Spring Boot CRUD 代码生成前先选择已确认 adapter。

#### Scenario: 用户显式指定 gupo adapter
- GIVEN 用户明确说明目标项目是 gupo 项目
- WHEN 用户请求生成 Java Spring Boot CRUD
- THEN 系统选择 `codegen-java-springboot-gupo-crud`
- AND 再按 Spring Boot 版本选择脚本。

#### Scenario: 无法识别 adapter
- GIVEN 目标项目没有 `.codex/codegen.toml`
- AND 项目指纹不足以识别 gupo
- WHEN 用户请求生成 Java Spring Boot CRUD
- THEN 系统停止并询问
- AND 不使用 gupo 脚手架试生成。

### Requirement: gupo 脚手架不得伪装为通用脚手架
系统 SHALL 将 gupo 专用脚手架命名、文档和 profile 明确标注为 gupo adapter。

#### Scenario: 查看 gupo adapter 文档
- GIVEN 用户打开 gupo adapter README
- THEN 文档说明该脚手架仅适用于 gupo 项目封装和约定。

### Requirement: generic adapter 暂不可用
系统 SHALL 明确标注通用 Java Spring Boot CRUD adapter 尚未实现，并禁止用 gupo adapter 冒充通用实现。

#### Scenario: 用户请求通用 adapter
- GIVEN 通用 adapter 尚未实现
- WHEN 用户请求非 gupo 项目生成 CRUD
- THEN 系统说明暂无通用 adapter
- AND 不使用 gupo adapter
- AND 要求先创建/选择已确认 adapter，或在用户确认后转入生产级手写实现。
