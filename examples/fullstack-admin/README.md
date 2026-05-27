# 全栈管理端示例

本示例展示前后端同仓管理端如何使用控制系统串联产品、设计、API、DB、前端、后端、QA 和发布审查。示例只描述流程和文档，不代表真实业务规则。

前后端同仓建议：

```text
your-admin/
├── AGENTS.md
├── openspec/
├── docs/
├── .codex/
├── backend/
└── frontend/
```

## 推荐安装

```bash
bash scripts/install-to-project.sh --dry-run --profile default /path/to/your-admin
bash scripts/install-to-project.sh --backup --profile default /path/to/your-admin
```

## 管理端流程

管理端新功能默认流程：

```text
product-discovery
-> workflow-openspec-propose
-> workflow-openspec-grill，如需要追问和术语校准
-> design-ux-review / design-ui-system
-> backend-common-api-contract-review
-> dba-mysql，如涉及数据库
-> frontend-common-implementation / backend-java-springboot，可在 API 契约确认后并行
-> frontend-common-tdd / method-tdd / qa-e2e-test
-> design-visual-qa
-> release-production-review
```

## 示例文件

- `openspec/changes/add-user-status-filter/`：管理端筛选能力 OpenSpec change 示例。
- `api-contracts/user-status-options.md`：前后端 API 契约示例。
- `review-report.md`：发布前审查报告示例。
