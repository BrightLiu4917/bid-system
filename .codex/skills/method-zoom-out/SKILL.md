---
name: method-zoom-out
description: 借鉴 Matt Pocock zoom-out 思路，在陌生代码区域先上升一层抽象，梳理相关模块、调用方、领域术语、OpenSpec 能力和 ADR 决策。用于不熟悉代码、接手复杂模块或开始架构/诊断前。
---

# 后端全局视角梳理

## 必须读取
- `AGENTS.md`
- `CONTEXT.md` 或 `CONTEXT-MAP.md`
- `docs/adr/`，如存在
- 相关 `openspec/specs/`

## 流程
1. 定位当前问题涉及的能力和领域术语。
2. 梳理相关模块、入口、调用链、数据表、API 和前端入口。
3. 标出关键 seam、依赖方向和外部系统。
4. 对照 OpenSpec 和 ADR，指出事实源和代码是否冲突。
5. 给出一张高层地图，不进入实现。

## 输出
- 能力地图
- 相关模块和调用方
- 数据/API/UI 关系
- 关键 seam
- OpenSpec/ADR 关联
- 后续建议 skill
