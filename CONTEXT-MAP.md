# 上下文地图

默认使用根目录 `CONTEXT.md` 作为 AI 全栈控制系统的统一术语表。

复制到具体业务项目后，如果业务上下文复杂，可以拆分为多上下文结构：

```text
CONTEXT-MAP.md
docs/adr/
apps/admin/CONTEXT.md
services/billing/CONTEXT.md
services/appointment/CONTEXT.md
```

## 上下文

- [控制系统上下文](./CONTEXT.md)：OpenSpec、Skill、Skill Route、Profile、Review Gate 等控制系统术语。
- `openspec/project.md`：目标项目的产品、技术栈、范围和治理说明。
- `openspec/specs/`：已确认能力规格。
- `openspec/changes/`：待确认或执行中的变更。
- `docs/`：工程规则和审查标准。
- `.codex/skills/`：角色化执行规则。
- `profiles/`：安装组合。
- `templates/`：标准产物模板。

## 关系

- `AGENTS.md` 负责全局红线和高层入口。
- `docs/SKILL_ROUTING.md` 负责 skill 顺序、并行、循环、回退和冲突处理。
- `CONTEXT.md` 负责共同语言，不承载已确认业务规则。
- `openspec/specs/` 承载已确认规格。
- `docs/adr/` 只记录长期架构决策；普通需求不要写入 ADR。
- `profiles/` 影响安装范围，不改变运行时业务行为。
