---
name: workflow-openspec-apply
description: OpenSpec 变更执行入口。用于用户确认 openspec/changes/<change-id>/ 后，按 tasks.md 调度 product/design/frontend/backend/dba/qa/security/performance/release 等 skill 执行最小安全变更。
---

# OpenSpec 变更执行

## 适用场景
- OpenSpec change 已确认，准备进入实现。
- 需要按 `tasks.md` 分批执行。

## 必须读取
- `AGENTS.md`
- `openspec/changes/<change-id>/proposal.md`
- `openspec/changes/<change-id>/design.md`，如存在
- `openspec/changes/<change-id>/tasks.md`
- 相关 specs delta

## 流程
1. 确认用户已批准该 change。
2. 按 `tasks.md` 识别任务类型和所需 skill。
3. 涉及 DB 先 `dba-mysql`。
4. 涉及 Java Spring Boot CRUD 先 `codegen-java-springboot-crud` 识别 adapter；gupo 项目才转入 `codegen-java-springboot-gupo-crud`；generic adapter 只生成审查预览包；真实落地需用户确认后转入 `backend-java-springboot` 或项目专用 adapter。
5. 涉及 API 先 `backend-common-api-contract-review`。
6. 涉及 UI/交互先 `design-ux-review` 或 `design-ui-system`。
7. 如用户选择 OpenCode/qianwen-coder 本地执行，转入 `workflow-local-agent-loop`，并先生成本地 Agent 任务输入。
8. 每次只实施最小可验证切片。
9. 更新任务状态和验证结果。

## 输出
- 执行任务
- 使用 skill
- 变更文件
- 验证结果
- 未完成任务
- 风险
