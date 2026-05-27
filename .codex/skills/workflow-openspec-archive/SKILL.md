---
name: workflow-openspec-archive
description: OpenSpec 归档入口。用于实现、验证和审查完成后，将已确认行为归档到 openspec/specs/，并整理变更记录、验证结果和残余风险。
---

# OpenSpec 规格归档

## 适用场景
- change 已实现。
- 验证已完成。
- 上线前或上线后需要沉淀规格。

## 必须读取
- `AGENTS.md`
- `openspec/changes/<change-id>/`
- 当前 `openspec/specs/`
- 验证和审查结果

## 流程
1. 确认实现和验证已完成。
2. 将已确认 specs delta 合并到 `openspec/specs/<capability>/spec.md`。
3. 不把未确认建议归档为事实。
4. 记录验证步骤和残余风险。
5. 如项目使用 archive 目录，将 change 移入归档位置；否则保留 change 并标记状态。

## 输出
- 归档规格
- 已合并行为
- 未归档事项
- 验证结果
- 残余风险
