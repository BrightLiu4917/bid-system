# 本地 Agent 任务模板

## 任务来源
- OpenSpec change：
- 任务编号：
- 发起人：

## 目标
填写本次要完成的具体结果。

## 非目标
明确本次不做什么，避免本地 Agent 扩大范围。

## 已确认业务规则
1. 

## 适用 Skill
列出 Codex 已判断本任务必须遵守的 skill。qianwen-coder 不会自动发现 Codex skill，必须通过本任务文件接收约束。

```text
例如：
backend-java-springboot
dba-mysql
release-production-review
```

## Skill 约束摘要
由 Codex 从完整 skill 中提炼，只写本任务必须遵守的关键规则。不要把建议补充项写成已确认业务规则。

```text
例如：
- Controller 不写业务逻辑。
- 多表写入必须使用事务。
- Mapper/XML 参数名必须一致。
- 禁止发明字段、枚举、API 路径或响应格式。
- 修改后必须运行 bash scripts/run-tests.sh。
```

## 必读原始规则文件
OpenCode/qianwen-coder 执行前必须读取；如执行工具无法读取文件，Codex 必须把关键约束摘要写完整。

```text
AGENTS.md
docs/SKILL_ROUTING.md
docs/TESTING_RULES.md
.codex/skills/<skill-name>/SKILL.md
```

## 待确认问题
如果这里存在会影响正确性的问题，停止执行，不要交给本地 Agent 猜。

## 允许修改
```text
填写允许修改的文件或目录
```

## 禁止修改
```text
例如：
生产配置
数据库迁移
公共响应结构
无关模块
```

## 依赖和数据库限制
- 是否允许新增依赖：否
- 是否允许修改表结构：否
- 是否允许执行数据库写操作：否

## 验证命令
```bash
bash scripts/run-tests.sh
```

## 最大自动修复轮数
```text
3
```

## 交付要求
- 本轮变更摘要。
- `git diff --stat`。
- 验证命令和结果。
- 失败日志摘要，如有。
- 未完成项和风险。
