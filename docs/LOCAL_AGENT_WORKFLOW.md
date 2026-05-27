# 本地 Agent 执行闭环

## 目标
把 OpenSpec 已确认任务交给本地执行 Agent，实现“写代码、跑验证、看日志、修复、交 diff”的闭环。

本流程不替代 OpenSpec、Codex 审查或人工业务确认。它只负责在已确认范围内执行代码修改和本地验证。

## 角色边界

```text
OpenSpec：需求、业务规则、设计和任务事实源
Codex：架构、任务拆分、规则审查和最终 Review
OpenCode：本地执行 Agent
qianwen-coder：OpenCode 使用的代码模型
deepv4：按需逻辑二审
scripts/run-tests.sh：统一验证入口
scripts/summarize-log.sh：日志摘要入口
Git 分支或 worktree：隔离每个任务的代码变更
```

## 标准流程

```text
workflow-openspec-propose
-> 用户确认 OpenSpec change
-> workflow-openspec-apply
-> workflow-local-agent-loop，如选择本地 Agent 执行
-> OpenCode/qianwen-coder 按 templates/local-agent-task.md 实现
-> scripts/run-tests.sh
-> scripts/summarize-log.sh
-> 最多 3 轮日志回喂和修复
-> deepv4 二审，如涉及复杂业务、DB、权限、状态流或发布风险
-> release-production-review
```

## 强制约束
- 本地 Agent 只能执行已确认 OpenSpec change 或明确简单任务。
- 本地 Agent 不能发明业务规则、字段、枚举、API 路径、权限或响应格式。
- 本地 Agent 只能修改任务文件中列出的允许范围。
- 测试失败时禁止删除测试、降低校验、绕开安全规则或扩大改动范围。
- 执行数据库写操作前必须获得用户确认。
- 生产连接串、密钥、token 和 private key 禁止写入任务文件、日志或示例。
- 自动修复最多 3 轮；超过后停止并交给 Codex 或人工判断。

## 最小任务输入
每个本地 Agent 任务至少包含：

- OpenSpec change id 或任务来源。
- 目标和非目标。
- 已确认业务规则。
- 适用 skill。
- Codex 从 skill 提炼出的关键约束摘要。
- 必读原始规则文件。
- 允许修改文件或目录。
- 禁止修改项。
- 验证命令。
- 最大修复轮数。
- 期望输出：diff、验证结果、失败摘要和未解决风险。

使用 [`templates/local-agent-task.md`](../templates/local-agent-task.md)。

## Skill 传递方式
Codex 原生读取 `.codex/skills/<skill-name>/SKILL.md`。qianwen-coder 只是本地代码模型，不会自动理解 Codex skill 机制。

因此本地 Agent 任务必须采用混合方式：

```text
任务文件写入适用 skill
+ Codex 提炼 skill 约束摘要
+ 列出必读原始规则文件
```

完整 skill 由 Codex 负责理解，任务约束由 OpenCode/qianwen-coder 负责执行。

## 验证要求
统一从 `scripts/run-tests.sh` 进入验证。完整日志落盘，交给模型的内容必须经过 `scripts/summarize-log.sh` 摘要。

目标项目应将 `.agent/` 加入 `.gitignore`，避免测试日志、修复提示和中间摘要进入提交。

本机专用配置写到目标项目：

```text
.agent/local-agent.env
```

可从 [`templates/local-agent.env.example`](../templates/local-agent.env.example) 复制后修改。`scripts/run-tests.sh` 和 `scripts/local-agent-loop-example.sh` 会自动读取该文件。

推荐输出：

```text
TEST_PASSED
```

或：

```text
TEST_FAILED
关键错误摘要
日志文件路径
```

## 适用场景
- 批量 CRUD、DTO/VO、Mapper/XML、表单和字段映射。
- 隐私敏感代码优先在本地模型执行。
- 需要降低远程模型生成代码 token 的重复实现。
- Codex 已完成设计和边界确认，只需要本地执行实现。

## 不适用场景
- 需求、字段、状态流、权限或 API 响应仍不清楚。
- 涉及高风险数据写入且没有确认 SQL 和回滚方案。
- 需要重新设计架构或改变已确认业务规则。
- 没有可运行的本地验证命令。
