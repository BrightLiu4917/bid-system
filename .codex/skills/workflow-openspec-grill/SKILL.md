---
name: workflow-openspec-grill
description: 结合 OpenSpec 和 Matt Pocock grill-with-docs 思路，对需求进行严格追问、术语校准、场景压力测试，并生成或完善 proposal.md、design.md、tasks.md 和 specs delta。用于所有非简单任务编码前。
---

# OpenSpec 需求追问

## 必须读取
- `AGENTS.md`
- `CODEX_TASK_TEMPLATE.md`
- `CONTEXT.md` 或 `CONTEXT-MAP.md`
- `docs/adr/`，如存在
- 相关 `docs/`
- 相关 `openspec/specs/`

## 流程
1. 判断是否为简单任务。
2. 为非简单任务创建或读取 `openspec/changes/<change-id>/`。
3. 校准领域语言：发现模糊词、重名词、和 `CONTEXT.md` 冲突的词，立即指出并要求确认。
4. 追问需求、范围、非范围、用户、业务规则、数据/API/UI/权限影响。
5. 用具体场景压力测试规则边界，尤其是异常、权限、租户、并发、历史数据和失败场景。
6. 如果问题可以通过代码或文档回答，先探索项目，不把可查事实丢给用户。
7. 输出 `proposal.md`、必要的 `design.md`、`tasks.md` 和 specs delta 草案。
8. 明确已确认规则和待确认建议。
9. 用户确认前禁止实现。

## 必须拷问
- 用户是谁，业务目标是什么。
- 哪些行为是新增、修改、废弃。
- 是否影响 DB、API、权限、租户、状态、UI、测试和发布。
- 是否存在历史数据和兼容性风险。
- 需求中的名词是否已经在 `CONTEXT.md` 定义。
- 是否存在需要 ADR 记录的难以逆转、令人意外且有真实取舍的决策。

## 文档沉淀
- 业务行为写入 OpenSpec，不写入 `CONTEXT.md`。
- 领域术语写入 `CONTEXT.md`，避免放实现细节。
- 架构或技术取舍写入 `docs/adr/`，仅在确有长期价值时创建。
- 不要把未确认规则写成事实。

## 输出
- OpenSpec change 路径
- 需求理解
- 范围和非范围
- 领域术语变化，如有
- ADR 建议，如有
- 风险点
- 待确认问题
- 下一步 skill 路由建议
