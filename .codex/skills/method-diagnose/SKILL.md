---
name: method-diagnose
description: 结合 Matt Pocock diagnose 思路，诊断后端 bug、接口异常、SQL 慢、数据不一致和性能回退。严格执行反馈回路、复现、假设、插桩、修复和回归测试。
---

# 后端诊断

## 必须读取
- `AGENTS.md`
- `CONTEXT.md` 或 `CONTEXT-MAP.md`
- `docs/adr/`，如相关
- `docs/BACKEND_RULES.md`
- `docs/DB_SCHEMA_RULES.md`
- `docs/TESTING_RULES.md`

## 流程
1. 建立反馈回路：测试、curl、CLI、日志回放、最小 harness 或可重复手动步骤。
2. 复现用户描述的同一个问题，不接受“附近的失败”替代。
3. 缩小范围：定位入口 API、Controller、Service、Mapper、XML、数据和外部依赖。
4. 提出 3-5 个可证伪假设，并按可能性排序。
5. 一次只验证一个假设；必要时加带唯一前缀的临时日志，如 `[DEBUG-xxxx]`。
6. 性能问题先建立基线，再改代码。
7. 修复最小根因。
8. 补回归测试或最小验证。
9. 清理临时日志、临时脚本和 throwaway harness。

## 禁止
- 未复现直接猜修。
- 同时做无关重构。
- 隐藏或吞掉异常。
- 无反馈回路时继续空想。
- 未清理 debug instrumentation 就交付。

## 输出
- 反馈回路
- 复现条件
- 假设列表
- 根因分析
- 修复方案
- 回归验证
- 剩余风险
