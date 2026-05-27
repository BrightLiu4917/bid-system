---
name: springboot-backend
description: 兼容入口。Java Spring Boot 后端接口、Service、Mapper/XML、DTO/VO、事务和业务实现任务必须改用 backend-java-springboot。
---

# Spring Boot 后端兼容入口

本 skill 仅保留为兼容入口。

## 必须读取
- `AGENTS.md`
- `docs/SKILL_ROUTING.md`

## 必须改用
- `backend-java-springboot`

## 强制规则
- 标准 CRUD 先用 `codegen-java-springboot-crud` 识别 adapter；generic adapter 只允许生成审查预览包，真实落地需确认后转入 `backend-java-springboot`。
- 涉及数据库先走 `dba-mysql`。
- 涉及 API 契约先走 `backend-common-api-contract-review`。
