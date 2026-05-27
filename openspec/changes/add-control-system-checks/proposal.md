# Proposal: Add Control System Checks

## Summary
Add lightweight scripts for project initialization, OpenSpec impact scope validation, OpenSpec change conflict detection, and stricter skill reference checks.

## Motivation
The control system has strong documentation rules, but several checks are still manual. Project setup, impact range declaration, cross-change conflict detection, and skill reference consistency should be partially verifiable by scripts.

## Scope
- Add `scripts/init-project.sh` to draft project context files from repository structure.
- Add structured `Impact Scope` blocks to OpenSpec change templates.
- Add `scripts/impact-check.sh` to validate impact scope fields.
- Add `scripts/openspec-conflict-check.sh` to warn about overlapping change impacts.
- Enhance `scripts/skill-check.sh` to validate local references in `## 必须读取`.
- Update README command list.

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

## Non-goals
- Do not add a runtime workflow engine.
- Do not implement a generic CRUD generator in this change.
- Do not merge or rename existing skills.

## Risks
- Impact scope remains manually declared and may be incomplete.
- Conflict detection can only warn about declared overlaps, not infer all code dependencies.

## Mitigation
- Keep checks lightweight and explicit.
- Treat warnings as review inputs, not automatic blockers.
