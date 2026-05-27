---
name: workflow-openspec-propose
description: OpenSpec 变更提案入口。用于非简单任务编码前创建或完善 openspec/changes/<change-id>/ 下的 proposal.md、design.md、tasks.md 和 specs delta，并等待用户确认。
---

# OpenSpec 变更提案

## 适用场景
- 新功能、接口变更、数据库变更、页面流程、重构、权限或状态流转变化。
- 任意不满足简单任务定义的需求。

## 必须读取
- `AGENTS.md`
- `CODEX_TASK_TEMPLATE.md`
- `CONTEXT.md` 或 `CONTEXT-MAP.md`
- 相关 `openspec/specs/`
- 相关 `docs/`

## 流程
1. 判断任务是否为简单任务。
2. 选择清晰的 `<change-id>`，使用短横线命名。
3. 创建或完善 `openspec/changes/<change-id>/`。
4. 编写 `proposal.md`：为什么做、做什么、不做什么、影响范围、风险、待确认问题。
5. 如涉及跨模块、数据库、接口、UI、状态流或架构取舍，编写 `design.md`。
6. 编写 `tasks.md`，任务必须可验证。
7. 编写 specs delta，禁止把未确认规则写成事实。
8. 输出给用户确认，确认前禁止实现。

## 输出
- change 路径
- proposal 摘要
- design 是否需要
- tasks 摘要
- specs delta 摘要
- 待确认问题
- 下一步 skill 路由建议
