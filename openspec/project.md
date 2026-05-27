# zcc-bidding-system

## Purpose
本项目是一个招投标相关业务系统，采用前后端分离结构：

```text
api/  # Spring Boot 后端
vue/  # Vue 管理端前端
```

本文件是项目级事实源，用于记录产品定位、目标用户、核心能力、技术栈、治理规则和待确认问题。未确认内容必须留在“待确认”区，不能直接作为业务规则实现。

## Target Users
已确认系统包含三个业务角色：

- 平台管理：负责审核专家和供应商入驻资料，发布招标公告，审核供应商对招标公告的申请。
- 专家：通过注册、资料提交进入入驻流程，由平台管理审核。
- 供应商：通过注册、资料提交进入入驻流程，由平台管理审核；可查看平台发布的招标公告并发起申请，申请由平台管理审核。

## Core Capabilities
已确认的高层业务能力：

- 专家注册、资料提交和入驻审核。
- 供应商注册、资料提交和入驻审核。
- 公告通知。
- 招标公告发布。
- 供应商查看招标公告。
- 供应商发起招标申请。
- 平台管理审核供应商招标申请。

以下能力仍为待确认候选，后续必须通过 `openspec/changes/<change-id>/` 确认后才能实现：

- 用户与权限管理细则。
- 招标项目管理和招标公告之间的边界。
- 专家参与招标、评审或其他业务流程的具体规则。
- 中标结果管理。
- 数据字典和基础配置。

## Tech Stack
- Backend: Java 17, Spring Boot 4, Maven Wrapper, MySQL Connector, Redis starter.
- Frontend: Vue 3, Element Plus, pnpm, Rspack.
- Repository layout: monorepo root with `api/` and `vue/`.
- Local Agent: OpenCode + qwen3-coder through `.agent/local-agent.env`.
- Verification entry: `bash scripts/run-tests.sh`.

## Scope
当前已确认范围：

- 根目录承载 AI 控制系统、OpenSpec、Codex skills、脚本和模板。
- `api/` 承载后端服务。
- `vue/` 承载前端管理端。

业务细则仍待确认。任何涉及字段、状态、权限、租户、删除、通知、支付、套餐扣减、评审规则或 API 响应格式的需求，必须先创建 OpenSpec change 并等待确认。

## Governance
- 非简单任务必须先创建或读取 `openspec/changes/<change-id>/`。
- 已确认业务规则必须沉淀到 `openspec/specs/<capability>/spec.md`。
- 设计决策和风险必须记录到对应 change 的 `design.md`。
- 实施任务必须记录到对应 change 的 `tasks.md`。
- 实现完成后必须归档已确认规格。
- OpenCode/qwen 只能执行已确认任务文件，不能自行决定业务规则。
- 测试从根目录统一执行 `bash scripts/run-tests.sh`。

## Open Questions
- 平台管理、专家、供应商的账号字段、登录方式、菜单权限和数据权限是什么。
- 专家和供应商入驻审核需要提交哪些资料，审核通过/驳回后是否允许重新提交。
- 专家入驻后参与哪些业务流程，是否参与评审。
- 招标公告和招标项目是否是同一对象，还是公告只是项目的发布展示。
- 供应商申请招标公告后，平台管理审核的通过/驳回规则是什么。
- 招标公告完整状态流是什么。
- 申请、投标、开标、评审、中标、公示、废标的时间规则是什么。
- 是否需要投标材料、电子标书、附件上传、文件预览、签章或加密。
- 如存在评审，评审是评分制、投票制、人工录入结果，还是多阶段评审。
- 通知方式是否包含站内信、短信、邮件或企业微信。
- 是否涉及保证金、支付、套餐扣减或其他资金规则。
- 删除行为是软删除、撤回、作废还是物理删除。
- API 统一响应格式、分页格式、错误码和鉴权方式是什么。
