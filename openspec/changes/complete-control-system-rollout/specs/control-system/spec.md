# Control System Spec Delta

## ADDED Requirements

### Requirement: 安装脚本默认不得静默覆盖冲突文件
`scripts/install-to-project.sh` SHALL 在目标路径已存在且未启用 `--force`、`--merge` 或 `--backup` 时报告冲突并退出。

#### Scenario: 目标项目已有同名文件
- GIVEN 目标项目存在 `AGENTS.md`
- WHEN 用户运行默认安装
- THEN 脚本报告冲突
- AND 不覆盖目标文件

### Requirement: 安装脚本必须支持预览和摘要
`scripts/install-to-project.sh` SHALL 支持 `--dry-run` 并在每次执行结束时输出 installed、skipped、backed up、conflicts 摘要。

#### Scenario: 用户预览默认安装
- GIVEN 用户指定一个存在的目标目录
- WHEN 用户运行 `bash scripts/install-to-project.sh --dry-run <target>`
- THEN 脚本输出将安装的条目
- AND 不写入目标目录

### Requirement: profile 必须声明安装条目
`profiles/<name>/profile.toml` SHALL 使用 `items = [...]` 声明安装条目。

#### Scenario: 用户选择 default profile
- GIVEN `profiles/default/profile.toml`
- WHEN 用户运行安装脚本并指定 `--profile default`
- THEN 脚本按该 profile 的 `items` 安装。

### Requirement: skill 创建必须通过模板生成
`scripts/new-skill.sh` SHALL 从 `templates/skill/SKILL.md` 生成 `.codex/skills/<skill-name>/SKILL.md`，并阻止覆盖已有 skill。

#### Scenario: 生成新 skill
- GIVEN skill 名称不存在
- WHEN 用户运行 `bash scripts/new-skill.sh <skill-name> "<description>"`
- THEN 脚本创建 `.codex/skills/<skill-name>/SKILL.md`
- AND frontmatter `name` 与目录名一致。
