---
name: workflow-local-agent-loop
description: 本地 Agent 执行闭环 skill。用于 OpenSpec change 已确认后，将最小实现切片交给 OpenCode/qianwen-coder 执行，并通过统一测试脚本、日志摘要、deepv4 二审和 Codex 最终 Review 控制风险。
---

# 本地 Agent 执行闭环

## 适用场景
- 用户明确希望使用 OpenCode、qianwen-coder、本地模型或本地 Agent 执行代码实现。
- OpenSpec change 已确认，准备把 tasks.md 的最小切片交给本地执行层。
- 需要降低远程模型生成代码量，但仍保留 Codex 审查和测试闭环。

## 必须读取
- `AGENTS.md`
- `docs/LOCAL_AGENT_WORKFLOW.md`
- `docs/OPENCODE_QWEN_RUNNER.md`
- `docs/TESTING_RULES.md`
- 相关 `openspec/changes/<change-id>/proposal.md`
- 相关 `openspec/changes/<change-id>/design.md`，如存在
- 相关 `openspec/changes/<change-id>/tasks.md`

## 流程
1. 确认 OpenSpec change 已获用户确认；未确认时停止。
2. 选择一个最小可验证任务切片。
3. 判断本任务适用的 skill，例如 `backend-java-springboot`、`dba-mysql`、`frontend-common-implementation`、`method-tdd` 或 `release-production-review`。
4. Codex 读取完整 skill，并在任务文件中写入“适用 Skill”“Skill 约束摘要”和“必读原始规则文件”。
5. 用 `templates/local-agent-task.md` 生成本地 Agent 任务输入。
6. 明确允许修改文件、禁止修改项、验证命令和最大修复轮数。
7. 交给 OpenCode/qianwen-coder 执行。
8. 要求每轮运行 `bash scripts/run-tests.sh`。
9. 测试失败时，仅把 `bash scripts/summarize-log.sh <log-file>` 摘要回喂给本地 Agent。
10. 自动修复最多 3 轮；超过后停止并报告。
11. 对复杂业务、DB、权限、状态流或发布风险，运行 `bash scripts/prepare-deepv4-review.sh` 准备 deepv4 二审输入。
12. 如 `.agent/local-agent.env` 已配置 `DEEPV4_REVIEW_COMMAND`，运行 `bash scripts/run-deepv4-review.sh`。
13. deepv4 输出只作为审查输入；影响业务规则的建议必须回到 OpenSpec 或用户确认。
14. 最终进入 `release-production-review`。

## 禁止事项
- 禁止本地 Agent 决定未确认业务规则。
- 禁止假设 qianwen-coder 会自动识别 `.codex/skills`；必须通过任务文件传递 skill 摘要和必读文件。
- 禁止扩大任务范围或修改任务未允许的文件。
- 禁止为了通过测试删除测试、跳过测试、降低校验或修改生产配置。
- 禁止把 deepv4 建议直接当作已确认业务规则。
- 禁止在未确认数据库方案时执行数据库写操作。

## 输出
- 本地 Agent 任务文件路径。
- 适用 skill、skill 约束摘要和必读原始规则文件。
- 执行 Agent 和模型。
- 修改范围。
- 验证命令和结果。
- 失败摘要，如有。
- deepv4 二审结果，如运行。
- 后续 Codex Review 风险点。
