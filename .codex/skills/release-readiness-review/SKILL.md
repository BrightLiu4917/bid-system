---
name: release-readiness-review
description: 发布前审查变更摘要、影响范围、数据库变更、API/前端兼容、验证结果、回滚方案和已知风险。
---

# 发布审查

## 必须读取
- `AGENTS.md`
- `docs/RELEASE_RULES.md`
- `docs/CODE_REVIEW_RULES.md`

## 流程
1. 汇总变更范围。
2. 检查 DB、API、前端、安全、性能和测试状态。
3. 检查回滚方案。
4. 标记阻塞项。
5. 输出发布建议。

## 输出
- 是否可发布
- 阻塞项
- 验证结果
- 回滚方案
- 风险
