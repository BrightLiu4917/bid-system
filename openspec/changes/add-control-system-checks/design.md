# Design: Control System Checks

## Overview
This change adds script-level guardrails without turning the framework into a runtime orchestration engine.

## Impact Scope
```yaml
affected_files:
  - README.md
  - scripts/init-project.sh
  - scripts/impact-check.sh
  - scripts/openspec-conflict-check.sh
  - scripts/openspec-check.sh
  - scripts/skill-check.sh
  - templates/openspec-change/proposal.md
  - templates/openspec-change/design.md
affected_tables:
  - none
affected_apis:
  - none
affected_pages:
  - none
affected_skills:
  - none
```

## Scripts
- `init-project.sh`: generates initial `openspec/project.md` and `CONTEXT.md` drafts. It scans common tech stack files but does not invent business rules.
- `impact-check.sh`: validates that `proposal.md` and `design.md` contain structured `Impact Scope` keys.
- `openspec-conflict-check.sh`: scans `openspec/changes/*/proposal.md` impact scopes and warns when multiple changes declare the same affected file, table, API, page, or skill.
- `skill-check.sh`: validates that local paths listed under `## 必须读取` exist.

## Tradeoffs
- The scripts intentionally avoid parsing arbitrary Markdown semantics beyond simple conventions.
- Conflict detection depends on accurate impact scope declarations.
- This is a compliance aid, not a replacement for Codex review or human confirmation.

## Rollback
Remove the new scripts and revert template/check changes. Existing OpenSpec changes remain readable because `Impact Scope` is additive.
