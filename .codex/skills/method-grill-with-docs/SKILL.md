---
name: method-grill-with-docs
description: Matt Pocock 风格的需求追问和文档沉淀方法。用于在编码前追问需求、校准领域术语、更新 CONTEXT.md，并在必要时建议 ADR；不直接替代 OpenSpec。
---

# 需求追问和文档沉淀

## 定位
这是方法层 skill，不是实现入口。

它负责把问题问清楚、把术语说准、把长期有价值的上下文写进文档。
如果任务需要进入规格流程，应继续使用 `workflow-openspec-propose` 或 `workflow-openspec-grill`。

## 必须读取
- `AGENTS.md`
- `CONTEXT.md` 或 `CONTEXT-MAP.md`
- `docs/adr/`，如存在
- 相关 `openspec/specs/`

## 流程
1. 一次只问一个关键问题。
2. 如果问题能通过代码或文档回答，先自己查，不把可查事实丢给用户。
3. 遇到模糊词、重名词、和 `CONTEXT.md` 冲突的词，立即指出。
4. 用具体业务场景压力测试边界。
5. 领域术语确认后，建议更新 `CONTEXT.md`。
6. 只有当决策难逆转、令人意外、有真实取舍时，才建议写 ADR。

## 禁止
- 禁止把未确认建议写成事实。
- 禁止把业务行为只写进 `CONTEXT.md` 而不进入 OpenSpec。
- 禁止替用户做业务决策。

## 输出
- 已澄清问题
- 待确认问题
- 术语变化建议
- ADR 建议，如有
- 下一步是否需要 `workflow-openspec-propose`
