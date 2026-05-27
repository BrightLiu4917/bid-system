# Design: Generic Preview Adapter And E2E Example

## Approach
The generic adapter is intentionally preview-only. It accepts explicit parameters and can print planned files without writing. With `--write`, it creates review drafts under `.codex/codegen-preview/<EntityName>/`.

The route compliance checker reads the OpenSpec `Impact Scope` block and verifies that `tasks.md` mentions the expected gates:
- tables -> DBA/database/SQL task
- APIs -> API contract task
- pages -> frontend/design/visual task
- files -> review/test/check task

CI templates call existing scripts and do not install new dependencies.

## Impact Scope
```yaml
affected_files:
  - README.md
  - docs/SKILL_ROUTING.md
  - .codex/skills/codegen-java-springboot-crud/SKILL.md
  - .codex/skills/codegen-only/SKILL.md
  - scripts/openspec-check.sh
  - scripts/route-compliance-check.sh
  - templates/ci/github-actions.yml
  - templates/ci/gitlab-ci.yml
  - tools/codegen/java-springboot-crud-adapters/README.md
  - tools/codegen/java-springboot-crud-adapters/generic/README.md
  - tools/codegen/java-springboot-crud-adapters/generic/adapter.toml
  - tools/codegen/java-springboot-crud-adapters/generic/scripts/crud-preview
  - examples/supplier-onboarding
affected_tables:
  - none
affected_apis:
  - none
affected_pages:
  - none
affected_skills:
  - codegen-java-springboot-crud
  - codegen-only
```

## Safety
- The preview script never writes to business source paths.
- Generated draft service methods throw `UnsupportedOperationException` to prevent accidental runtime use.
- Real implementation still requires OpenSpec confirmation, DBA, API contract, tests and review.

## Validation
- Shell syntax checks.
- Skill checks.
- Route checks.
- Docs link checks.
- OpenSpec check for this change.
- Generic preview dry run and write run into a temporary directory.
