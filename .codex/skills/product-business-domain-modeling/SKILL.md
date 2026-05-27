---
name: product-business-domain-modeling
description: 建模领域对象、状态枚举、权限、租户、删除、通知、时间冲突、支付和套餐扣减规则。用于业务规则梳理、OpenSpec specs 沉淀和复杂流程设计。
---

# 业务领域建模

## 必须读取
- `AGENTS.md`
- `docs/BUSINESS_RULES.md`
- 相关 `openspec/specs/`

## 流程
1. 识别领域对象和对象关系。
2. 明确字段含义、枚举值和状态流转。
3. 明确权限、租户、删除、通知和支付规则。
4. 明确历史数据和兼容性影响。
5. 将已确认规则沉淀到 OpenSpec specs。

## 停止并询问
- 字段含义不清。
- 枚举值或状态流转不清。
- 权限、租户、删除、通知、支付规则不清。
- 规则会影响数据库、API 或前端契约但未确认。

## 输出
- 领域对象
- 状态流转
- 权限和租户规则
- 数据规则
- 待确认业务问题
- OpenSpec spec 建议
