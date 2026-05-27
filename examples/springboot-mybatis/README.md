# Spring Boot + MyBatis 示例

本示例展示一个 Java Spring Boot + MyBatis/MyBatis-Plus 后端项目如何接入控制系统。示例只描述目录、流程和文档，不代表真实业务规则。

## 推荐安装

```text
your-project/
├── AGENTS.md
├── openspec/
├── docs/
├── .codex/
├── scripts/
├── tools/
├── pom.xml
└── src/
```

```bash
bash scripts/install-to-project.sh --dry-run --profile minimal /path/to/your-project
bash scripts/install-to-project.sh --backup --profile minimal /path/to/your-project
```

## 后端任务流程

后端任务默认流程：

```text
workflow-openspec-propose
-> workflow-openspec-grill，如字段含义或历史数据不清
-> dba-mysql，如涉及表结构、SQL、索引或数据兼容
-> backend-common-api-contract-review，如涉及接口
-> codegen-java-springboot-crud，如涉及 CRUD 脚手架，先识别 adapter
-> codegen-java-springboot-gupo-crud，如明确为 gupo 项目
-> backend-java-springboot
-> method-tdd
-> release-production-review
```

## 示例文件

- `openspec/changes/add-admin-audit-log/`：后端审计日志能力的 OpenSpec change 示例。
- `api-contracts/admin-audit-log-list.md`：API 契约示例。
- `review-report.md`：发布前审查报告示例。
