# Codex 局部契约

本文件与项目根目录 `AGENTS.md` 保持同一职责：定义安全红线、OpenSpec-first 工作流和 skill 路由。

如本文件与根 `AGENTS.md` 冲突，以根 `AGENTS.md` 为准，并立即提示用户同步。

必须遵守：
- 非简单任务先进入 OpenSpec。
- 不清楚就 STOP and ASK。
- 不猜业务、字段、枚举、权限、租户、API、UI 交互。
- `method-*` 只负责工程方法，不直接操作 OpenSpec 文件。
- `workflow-openspec-*` 必须围绕 `openspec/` 读写。
- 涉及数据库先走 `dba-mysql`。
- Java Spring Boot CRUD 脚手架先走 `codegen-java-springboot-crud` 识别 adapter；未确认 adapter 时禁止生成脚手架。generic adapter 不可用时，经用户确认可转入 `backend-java-springboot` 做生产级手写实现；gupo 项目才可转入 `codegen-java-springboot-gupo-crud`。
- Spring Boot 后端实现走 `backend-java-springboot`。
- 交付前走 `release-production-review`。

兼容入口只用于旧项目迁移：
- `codegen-only` -> `codegen-java-springboot-crud`
- `mysql-dba` -> `dba-mysql`
- `springboot-backend` -> `backend-java-springboot`
- `reviewer` -> `release-production-review`

详细路由见 `docs/SKILL_ROUTING.md`。
