# Skill 命名规则

## 目标
支持多个后端语言、前端框架、数据库和代码生成器并存，避免 skill 名称含糊或职责重叠。

## 命名格式

```text
<domain>-<language/framework/tool>-<purpose>
```

常用前缀：

```text
workflow-*
method-*
product-*
design-*
frontend-<framework>-*
frontend-common-*
backend-common-*
backend-<language>-<framework>
dba-<engine>
codegen-<language>-<framework>-*
qa-*
security-*
performance-*
release-*
```

固定角色前缀：

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

技术名、路径、命令、框架名保留英文；正文说明尽量使用中文。

## 当前生产级主入口

```text
workflow-openspec-propose
workflow-openspec-grill
workflow-openspec-apply
workflow-openspec-archive
method-diagnose
method-tdd
method-grill-with-docs
method-architecture-review
method-zoom-out
codegen-java-springboot-crud
codegen-java-springboot-gupo-crud
backend-java-springboot
dba-mysql
release-production-review
```

新增 skill 必须保持：

```text
.codex/skills/<skill-name>/SKILL.md
```

`SKILL.md` frontmatter 的 `name` 必须与目录名完全一致。

## 兼容入口

以下旧名称只用于兼容，不作为新增能力主入口：

```text
codegen-only -> codegen-java-springboot-crud
mysql-dba -> dba-mysql
springboot-backend -> backend-java-springboot
reviewer -> release-production-review
```

## 后续扩展示例

```text
backend-node-nestjs
backend-python-fastapi
frontend-react-admin
frontend-vue-admin
dba-postgres
codegen-java-springboot-gupo-crud
codegen-node-nestjs-crud
codegen-python-fastapi-crud
```

## Codegen Adapter 命名
项目或公司专用脚手架必须显式写出 adapter 名称：

```text
codegen-java-springboot-gupo-crud
codegen-java-springboot-ruoyi-crud
codegen-java-springboot-jeecg-crud
```

`codegen-java-springboot-crud` 只作为 Java Spring Boot CRUD adapter 路由入口；没有通用生成实现时，禁止描述为通用脚手架。

## 禁止
- 禁止新增含义宽泛的 `backend`、`frontend`、`codegen`、`review` 作为主 skill。
- 禁止让一个 skill 同时负责多个语言或多个框架的实现细节。
- 禁止复制旧 skill 后只改名字但不改 description。
- 禁止把兼容入口写进新的主流程路由。
- 禁止把公司专用 codegen adapter 描述为通用脚手架。
