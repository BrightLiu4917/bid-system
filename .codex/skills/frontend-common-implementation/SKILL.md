---
name: frontend-common-implementation
description: 实现前端页面、组件、状态、表单、权限态和 API 集成。用于 React/Vue/管理端前端功能开发，必须遵循既有项目约定。
---

# 前端实现

## 必须读取
- `AGENTS.md`
- `docs/FRONTEND_RULES.md`
- `docs/API_RULES.md`
- `docs/UX_RULES.md`
- 相关 OpenSpec specs/changes

## 流程
1. 定位既有框架、目录、组件库和状态管理。
2. 明确 API 契约和前端字段映射。
3. 实现加载态、空态、错误态、成功态和权限态。
4. 保持最小变更，不做无关重构。
5. 运行类型检查、lint、测试或手动验证。

## 停止并询问
- API 契约不清。
- 权限态或交互不清。
- 需要新增依赖。
- 会破坏既有路由或组件行为。

## 输出
- 页面/组件变化
- API 集成
- 状态处理
- 验证步骤
- 风险
