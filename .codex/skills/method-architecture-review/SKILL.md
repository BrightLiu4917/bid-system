---
name: method-architecture-review
description: 结合 Matt Pocock improve-codebase-architecture 思路，寻找模块深化、测试 seam、依赖方向、耦合、重复逻辑和重构切片。用于解耦、重构、跨模块改造和架构优化，默认只分析不直接改代码。
---

# 架构审查

## 必须读取
- `AGENTS.md`
- `CONTEXT.md` 或 `CONTEXT-MAP.md`
- `docs/adr/`，如存在
- `docs/BACKEND_RULES.md`
- `docs/FRONTEND_RULES.md`
- 相关 OpenSpec specs/changes

## 流程
1. 用领域语言理解相关能力和模块。
2. 识别模块、接口、实现、seam、adapter、调用方向。
3. 找出浅模块、传声筒封装、高耦合、重复逻辑、过胖 Service/组件、跨层调用。
4. 做 deletion test：删除该模块后复杂度是消失，还是分散到多个调用者。
5. 找出能提升 locality 和 leverage 的深模块机会。
6. 检查现有 ADR，避免重复提出已被拒绝或受约束的方案。
7. 输出候选改造列表，不直接提出最终接口。
8. 用户选择候选后，再进入追问和设计切片。
9. 每个切片必须可测试、可回滚、可单独审查。

## 输出
- 架构风险
- 耦合点
- 深化机会
- 改造目标
- 分批计划
- 每批影响范围
- 验证方式
