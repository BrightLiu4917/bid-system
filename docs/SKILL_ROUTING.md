# Skill 路由规则

## 目标
让 AI 像一个专业全栈团队一样按角色协作：产品、设计、前端、后端、DBA、QA、安全、性能和发布审查按需出现。

本文件负责路由、顺序、并行、循环、回退和冲突处理；`AGENTS.md` 只保留全局红线和高层入口。

## 分层

```text
workflow-*      # OpenSpec / 流程编排
method-*        # Matt Pocock 工程方法
product-*       # 产品经理
design-*        # UI/交互设计师
frontend-*      # 前端工程师
backend-*       # 后端工程师
codegen-*       # 代码生成器
dba-*           # DBA
qa-*            # 测试工程师
security-*      # 安全工程师
performance-*   # 性能工程师
release-*       # 发布/上线审查
```

Codex 发现结构必须保持一层：

```text
.codex/skills/<skill-name>/SKILL.md
```

## OpenSpec 与 method 边界

| 场景 | 使用 | 文件边界 |
|------|------|----------|
| 需求模糊，只讨论不进入规格 | `method-grill-with-docs` | 不操作 `openspec/`，可建议更新 `CONTEXT.md` 或 ADR |
| 已有 change，规格细节需要追问校准 | `workflow-openspec-grill` | 必须读写 `openspec/changes/<change-id>/` |
| 需要创建新 change 提案 | `workflow-openspec-propose` | 必须创建或完善 `openspec/changes/<change-id>/` |
| change 已确认，需要按任务执行 | `workflow-openspec-apply` | 读取 `tasks.md` 并调度角色 skill |
| change 已确认，选择本地 Agent 执行 | `workflow-local-agent-loop` | 读取 `tasks.md`，生成本地 Agent 任务并收集验证结果 |
| 实现完成，需要归档规格 | `workflow-openspec-archive` | 将确认行为归档到 `openspec/specs/` |

核心规则：
- `method-*` 不直接操作 OpenSpec 文件。
- `workflow-openspec-*` 必须围绕 `openspec/` 读写。
- `CONTEXT.md` 记录术语和上下文，不替代 OpenSpec 的业务事实。
- ADR 只记录架构和技术取舍，不记录普通需求细节。

## 快速分类

| 任务类型 | 路由 |
|----------|------|
| 简单任务 | 可直接改，仍需说明验证 |
| 低风险批量修改 | 可快速处理，需列范围和验证 |
| 新功能 | OpenSpec first，再按角色执行 |
| Bug 修复 | 先诊断，再修复，再回归 |
| 数据库变更 | OpenSpec -> DBA -> API/后端 -> 审查 |
| API 变更 | OpenSpec -> API contract -> 后端/前端 -> 审查 |
| 前端/设计 | OpenSpec -> UX/UI -> 前端 -> 视觉 QA -> 审查 |
| 解耦/重构 | 架构审查 -> OpenSpec -> 测试保护 -> 分批实现 |
| 发布前 | production review -> readiness review |

## 标准流程

### 新功能

```text
product-discovery
-> product-business-domain-modeling
-> workflow-openspec-propose
-> workflow-openspec-grill，如已有 change 仍需追问
-> method-grill-with-docs，如仅需术语/CONTEXT/ADR 方法补充
-> method-zoom-out，如代码区域陌生或影响范围不清
-> method-architecture-review，如涉及跨模块、解耦或架构变化
-> design-ux-review / design-ui-system，如涉及界面
-> backend-common-api-contract-review，如涉及接口
-> dba-mysql，如涉及数据库
-> codegen-java-springboot-crud，如涉及 Java Spring Boot CRUD 脚手架，先识别 adapter
-> codegen-java-springboot-gupo-crud，如 adapter 确认为 gupo
-> frontend-common-implementation / backend-java-springboot
-> workflow-local-agent-loop，如选择 OpenCode/qianwen-coder 本地执行已确认切片
-> frontend-common-tdd / method-tdd / qa-e2e-test
-> security-review / performance-review，如有风险
-> release-production-review
-> release-readiness-review
```

并行标注：
- `design-ux-review` 与 `dba-mysql` 可在 OpenSpec 确认后并行。
- `frontend-common-implementation` 与 `backend-java-springboot` 可在 API contract 确认后并行。
- `workflow-local-agent-loop` 只能在 OpenSpec change 和任务切片确认后执行，不能与需求澄清并行。
- `security-review`、`performance-review`、`qa-e2e-test` 可在实现后并行。

循环/回退：
- API contract 变化影响前端或数据库时，回到 `workflow-openspec-grill` 更新规格。
- DBA 发现字段含义、索引策略或历史数据处理不清时，回到 `workflow-openspec-grill`。
- QA 或 review 发现业务规则不一致时，回到 OpenSpec；发现实现缺陷时，回到对应实现 skill。
- 本地 Agent 测试失败超过 3 轮时，回到 Codex 诊断或人工判断，不继续自动修复。

### Bug 修复

```text
method-diagnose 或 frontend-common-diagnose
-> method-zoom-out，如代码区域陌生或调用链不清
-> workflow-openspec-grill，如发现业务规则不清
-> dba-mysql，如涉及 SQL、数据或表结构
-> backend-java-springboot / frontend-common-implementation
-> workflow-local-agent-loop，如选择本地 Agent 执行修复
-> method-tdd / frontend-common-tdd / qa-e2e-test
-> release-production-review
```

循环/回退：
- 复现失败时回到诊断，不允许猜修。
- 修复后测试仍失败，回到诊断假设。
- 发现规格缺失时补 OpenSpec，不把聊天结论当事实源。

### 数据库变更

```text
workflow-openspec-propose
-> workflow-openspec-grill，如字段含义/历史数据/回滚不清
-> dba-mysql
-> backend-common-api-contract-review，如影响接口
-> backend-java-springboot
-> method-tdd
-> release-production-review
```

强制点：
- 必须列出表、字段、索引、forward SQL、rollback SQL、历史数据影响。
- 执行数据库写操作前必须获得用户确认。

### API 变更

```text
workflow-openspec-propose
-> backend-common-api-contract-review
-> dba-mysql，如涉及字段或 SQL
-> backend-java-springboot
-> frontend-common-implementation，如影响前端
-> method-tdd / frontend-common-tdd
-> release-production-review
```

强制点：
- 必须明确路径、方法、请求、响应、错误、分页、鉴权、兼容性和敏感字段。

### 前端/设计变更

```text
workflow-openspec-propose
-> design-ux-review
-> design-ui-system
-> backend-common-api-contract-review，如涉及接口
-> frontend-common-implementation
-> frontend-common-tdd
-> design-visual-qa
-> release-production-review
```

强制点：
- 必须覆盖入口、主路径、加载态、空态、错误态、权限态、表单校验和高风险确认。

### 解耦/重构

```text
method-architecture-review
-> method-zoom-out，如需要先建立能力地图
-> workflow-openspec-propose
-> workflow-openspec-grill，如需要追问和术语校准
-> 测试保护
-> 分批最小实现
-> release-production-review
```

强制点：
- 重构必须有切片和回退路径。
- 不允许借重构改变未确认业务行为。
- 每个切片都要能独立验证。

### 本地 Agent 执行

```text
workflow-openspec-apply
-> workflow-local-agent-loop
-> scripts/run-tests.sh
-> scripts/summarize-log.sh
-> deepv4 二审，如涉及复杂业务、DB、权限、状态流或发布风险
-> release-production-review
```

强制点：
- 必须使用 `templates/local-agent-task.md` 明确允许修改范围、禁止修改项、验证命令和最大修复轮数。
- OpenCode/qianwen-coder 只负责本地执行，不负责决定业务规则。
- deepv4 只做二审，不能替代 OpenSpec 或用户确认。
- 自动修复最多 3 轮，失败后停止。

## 冲突处理
- `codegen-java-springboot-crud` 与实现型 skill 冲突时，优先 `codegen-java-springboot-crud` 识别 adapter。
- `codegen-java-springboot-gupo-crud` 只能在 adapter 确认为 gupo 后执行。
- 未确认 adapter 时禁止生成 CRUD 脚手架。
- generic adapter 只允许生成审查预览包；真实落地必须在用户确认后转入 `backend-java-springboot`，并按 API contract、DBA、TDD 和 release review 执行。
- `dba-mysql` 与后端实现同时触发时，先 `dba-mysql`。
- `method-diagnose` 与后端实现同时触发时，先 `method-diagnose`。
- `method-architecture-review` 与实现型 skill 同时触发时，先 `method-architecture-review`，确认切片后再实现。
- `workflow-openspec-grill` 与任何实现型 skill 同时触发时，先 `workflow-openspec-grill`。
- `workflow-local-agent-loop` 与需求澄清、DBA 或 API contract 冲突时，先完成 OpenSpec、DBA 或 API contract。
- `method-grill-with-docs` 不代替 OpenSpec，只负责追问、术语和 ADR/CONTEXT 建议。
- `method-zoom-out` 不代替实现、诊断或审查，只用于建立高层地图。
- `release-production-review` 只做最终审查，不代替实现。

## 兼容入口
以下旧名称只用于迁移期，不能作为新流程主入口：

```text
codegen-only -> codegen-java-springboot-crud
mysql-dba -> dba-mysql
springboot-backend -> backend-java-springboot
reviewer -> release-production-review
```

当文档或任务中出现旧名称，应优先提示替换为新名称。

## Codegen Adapter
Java Spring Boot CRUD 没有默认通用生成器。必须先选择 adapter：

```text
codegen-java-springboot-crud
-> codegen-java-springboot-gupo-crud，如明确为 gupo 项目
-> generic crud preview，如需要通用审查草稿且字段/API/DB 已确认
-> backend-java-springboot，如用户确认生产级手写落地
-> STOP and ASK，如 adapter 不明确、用户未确认手写或关键规则不清
```

仅使用 Spring Boot、MyBatis 或 MyBatis-Plus 不能作为选择 gupo adapter 的充分条件。
