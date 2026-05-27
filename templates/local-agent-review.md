# 本地 Agent 变更二审模板

## 审查来源
- OpenSpec change：
- 本地 Agent：
- 模型：
- 分支：

## 需求摘要
填写 OpenSpec 中已确认的目标、范围和非范围。

## 已确认业务规则
1. 

## 变更摘要
填写本地 Agent 输出的变更摘要。

## Diff 摘要
```text
粘贴 git diff --stat 或关键 diff
```

## 验证结果
```text
粘贴 scripts/run-tests.sh 和 scripts/summarize-log.sh 的摘要
```

## 重点审查问题
- 是否猜测业务规则、字段、枚举或响应格式。
- 是否破坏 API 兼容性。
- 是否遗漏权限、租户、软删除或状态流转。
- 是否存在事务、并发、幂等或重复提交风险。
- 是否存在 SQL 安全或性能风险。
- 是否需要补充测试。

## 审查输出格式
1. 阻塞问题
2. 重要风险
3. 待确认问题
4. 建议补充测试
5. 是否建议进入 Codex 最终 Review
