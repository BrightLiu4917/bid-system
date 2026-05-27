# Proposal: Add Generic Preview Adapter And E2E Example

## Summary
Add a preview-only generic Java Spring Boot CRUD adapter, route compliance checks, CI templates, and a complete end-to-end example for learning the control-system workflow.

## Motivation
The control system already has strong workflow documents, but users still need:
- A concrete non-gupo CRUD preview path that does not pretend to be production-ready codegen.
- A compliance check that ties declared impact scope to required route gates.
- CI templates that make checks easy to copy into real projects.
- A fuller example showing OpenSpec, API contract, tasks, local-agent handoff and review artifacts together.

## Scope
- Add `tools/codegen/java-springboot-crud-adapters/generic/scripts/crud-preview`.
- Add `tools/codegen/java-springboot-crud-adapters/generic/adapter.toml`.
- Update codegen docs and skills to describe generic as preview-only.
- Add `scripts/route-compliance-check.sh` and call it from `scripts/openspec-check.sh`.
- Add GitHub Actions and GitLab CI templates under `templates/ci/`.
- Add `examples/supplier-onboarding/` as a complete learning example.
- Update README command and usage documentation.

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

## Non-goals
- Do not generate production business code directly into `src/main`.
- Do not infer real project fields, statuses, permissions or API response wrappers.
- Do not add npm, Maven or runtime dependencies.
- Do not implement a full workflow engine.

## Risks
- Users may misunderstand preview drafts as production code.
- Route compliance check can only validate declared impact scope, not infer hidden dependencies.

## Mitigation
- Keep generic adapter output under the configured codegen preview directory.
- Make docs and generated `REVIEW.md` state that drafts require confirmation.
- Keep compliance check lightweight and explicit.
