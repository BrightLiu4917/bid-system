# Local Agent Task: Supplier Onboarding Slice

## Goal
Implement only the confirmed smallest supplier onboarding slice.

This file is an example of what Codex gives to OpenCode/qwen3-coder. Do not run it as-is against a real project.

## Source Of Truth
- `openspec/changes/add-supplier-onboarding/proposal.md`
- `openspec/changes/add-supplier-onboarding/design.md`
- `openspec/changes/add-supplier-onboarding/tasks.md`
- `api-contracts/supplier-onboarding.md`

## Applicable Skills
- `dba-mysql`
- `backend-common-api-contract-review`
- `backend-java-springboot`
- `frontend-common-implementation`
- `method-tdd`

## Allowed Changes
- Backend files explicitly confirmed by Codex after DB and API review.
- Frontend files explicitly confirmed by Codex after API contract review.
- Tests for the confirmed slice.

## Forbidden Changes
- Do not invent fields, statuses, enum values, API paths or response wrappers.
- Do not alter unrelated modules.
- Do not write migration SQL without DBA confirmation.
- Do not bypass authentication or permission checks.

## Validation Command

```bash
bash scripts/run-tests.sh
```

## Stop Conditions
- Required field meaning is unclear.
- Status transition is unclear.
- Permission rule is unclear.
- API wrapper is unclear.
- Test command fails after the configured repair limit.
