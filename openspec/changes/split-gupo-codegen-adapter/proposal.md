# Proposal

## Why
当前 `codegen-java-springboot-crud` 和迁移前的 Java Spring Boot CRUD 工具目录暗示存在通用脚手架，但实际脚本只适用于 gupo 项目的封装、包结构、返回体、分页、异常、DTO/VO 和 Mapper/XML 约定。继续以通用名称暴露会导致非 gupo 项目误用，破坏项目约定。

## What
- 将现有脚手架明确拆为 gupo 专用 adapter：`codegen-java-springboot-gupo-crud`。
- 将工具目录改为 `tools/codegen/java-springboot-crud-adapters/gupo/`。
- 保留 `codegen-java-springboot-crud` 作为安全路由入口，不生成代码，只负责识别 adapter 或停止询问。
- 新增 adapter registry 文档和 `adapter.toml`，定义显式配置、profile、项目指纹和停止条件。
- 新增 `profiles/gupo`，默认 profile 不默认安装 gupo 专用脚手架。
- 更新 README、AGENTS、SKILL_ROUTING、SKILL_NAMING_RULES、release review 和兼容入口文档。

## Non-Goals
- 不实现通用 Java Spring Boot CRUD 脚手架；generic adapter 缺失时的手写实现规则由后续 change 明确。
- 不改变 gupo 脚本生成内容。
- 不为非 gupo 项目自动选择 gupo adapter。
- 不修改数据库、业务接口、后端运行时代码或前端运行时代码。

## Impact
- 产品/业务：无目标业务规则变化。
- API：无运行时 API 变化。
- 后端：无运行时代码变化。
- 数据库：无数据库变化。
- 工具链：代码生成入口从“通用生成器”调整为“adapter 路由 + gupo 专用 adapter”。
- 安装：`profiles/gupo` 明确安装 gupo 专用脚手架；默认 profile 保持控制系统通用资产。

## Risks
- 已经引用旧路径 `tools/codegen/java-springboot-crud/scripts/...` 的文档或流程需要同步迁移。
- 如果目标项目没有 adapter 配置且项目指纹不够强，生成流程会停止询问。

## Open Questions
- 无影响正确性的待确认问题。用户已确认按 gupo adapter 拆分，并将通用脚手架留给后续全新维护。
