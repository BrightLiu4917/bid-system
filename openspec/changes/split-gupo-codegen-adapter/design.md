# Design

## Adapter Selection
CRUD 脚手架选择分两步：

1. 选择 adapter。
2. 在选定 adapter 内根据 Spring Boot 版本选择脚本。

判定优先级：

1. 用户显式指定 adapter，例如 `gupo`。
2. 目标项目显式配置 `.codex/codegen.toml`。
3. 安装 profile 或 adapter registry 中的项目指纹。
4. 无法高置信识别时停止询问。

只有 Spring Boot、MyBatis 或 MyBatis-Plus 不能作为选择 gupo adapter 的充分条件。

## Directory Layout

```text
tools/codegen/java-springboot-crud-adapters/
├── README.md
├── generic/
│   └── README.md
└── gupo/
    ├── adapter.toml
    ├── README.md
    └── scripts/
        ├── crud-spring-bootv2
        └── crud-spring-bootv34
```

## Skills
- `codegen-java-springboot-crud`：安全路由入口。没有选定 adapter 前禁止生成。
- `codegen-java-springboot-gupo-crud`：gupo adapter 执行入口。只适用于 gupo 项目。
- `codegen-only`：兼容入口，改指向 `codegen-java-springboot-crud` 路由入口。

## Profiles
- `profiles/default`：不带 gupo 专用脚手架，保持通用控制系统资产。
- `profiles/gupo`：包含 gupo adapter skill 和 tools。

## Generic Adapter 缺失
generic adapter 尚未实现时，不使用 gupo adapter 兜底。用户确认允许手写时，按 `allow-manual-springboot-crud-when-generic-adapter-missing` 的规则转入 `backend-java-springboot`。

## Rollback
可恢复旧 skill 名和工具目录。但不建议回滚语义，因为旧语义会误导非 gupo 项目。
