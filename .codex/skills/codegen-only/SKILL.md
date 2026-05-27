---
name: codegen-only
description: 兼容入口。CRUD、脚手架、Controller、Service、Mapper/XML、DTO/VO 生成任务必须改用 codegen-java-springboot-crud 先识别 adapter；generic 只允许审查预览，真实落地需确认后转入生产级实现。
---

# 代码生成兼容入口

本 skill 仅保留为兼容入口。

## 必须读取
- `AGENTS.md`
- `docs/SKILL_ROUTING.md`

## 必须改用
- `codegen-java-springboot-crud`

## 强制规则
- 禁止绕过 adapter 判定直接低质量模板拼接 CRUD。
- 必须先通过 `codegen-java-springboot-crud` 识别 adapter。
- 未确认 adapter 时禁止生成脚手架。
- gupo 项目才可转入 `codegen-java-springboot-gupo-crud`。
- 真正执行 adapter 时必须 preview first。
- generic adapter 只生成审查预览包，不能直接写业务源码。
- 真实落地时，可在用户确认后转入 `backend-java-springboot` 做生产级手写实现。
- 覆盖已有文件必须等待用户确认。
