# OpenCode + qianwen-coder 执行约定

## 定位
OpenCode 是本地执行 Agent，qianwen-coder 是代码生成模型。它们负责在已确认任务范围内改代码、运行验证、根据日志修复。

它们不是产品负责人、架构最终决策者或业务规则事实源。

## 推荐调用方式
本仓库不绑定具体 OpenCode 命令。目标项目应在环境变量中提供本地执行命令：

```bash
export LOCAL_AGENT_COMMAND='opencode run'
```

推荐持久写到目标项目的本机配置文件：

```text
.agent/local-agent.env
```

可从 `templates/local-agent.env.example` 复制后修改。`scripts/local-agent-loop-example.sh` 会自动读取该文件。

如果你的 OpenCode 命令不同，在目标项目中覆盖该变量，或复制并改造 `scripts/local-agent-loop-example.sh`。

## 输入文件
优先使用：

```text
templates/local-agent-task.md
```

任务文件必须明确：

- 适用哪些 Codex skill。
- 从这些 skill 提炼出的关键约束摘要。
- 执行前必须读取哪些原始规则文件。
- 允许修改文件。
- 禁止修改文件。
- 运行哪些验证。
- 是否允许新增依赖。
- 是否允许数据库结构变化。
- 最大修复轮数。

## 使用 Codex Skill
qianwen-coder 不会自动识别 Codex 的 skill 系统。Codex skill 的正确传递方式是：

```text
Codex 读取完整 .codex/skills/<skill-name>/SKILL.md
-> Codex 在 local-agent-task.md 中写入适用 skill
-> Codex 提炼本任务必须遵守的 skill 约束摘要
-> OpenCode/qianwen-coder 按任务文件执行
```

不要只让 qianwen-coder 自己搜索 `.codex/skills`。任务文件必须把关键约束写清楚，并列出必要时要读取的原始 skill 文件。

## 输出要求
OpenCode/qianwen-coder 每轮必须输出：

- 本轮修改摘要。
- 执行过的命令。
- 验证是否通过。
- 如失败，保留错误摘要。
- 当前 `git diff --stat`。

最终交付必须包含：

- `git diff`。
- `scripts/run-tests.sh` 结果。
- 未解决问题。
- 是否需要 deepv4 二审。

## 禁止行为
- 禁止在任务范围外改文件。
- 禁止通过删除测试、跳过测试或降低校验来通过验证。
- 禁止新增依赖，除非任务明确批准。
- 禁止修改表结构，除非 OpenSpec change 和 DBA 审查已确认。
- 禁止把生产配置、密钥或真实连接串写入代码、日志或任务文件。

## 与 Codex 分工
Codex 负责确认任务边界、审查 diff、发现风险和最终验收。OpenCode/qianwen-coder 只负责执行型实现。
