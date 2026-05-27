# Tasks

## Product And Domain
- [ ] Confirm supplier material fields.
- [ ] Confirm audit status values and transitions.
- [ ] Confirm supplier and platform manager permission boundaries.

## DBA / Database
- [ ] Design `supplier_onboarding_application` table.
- [ ] Design `supplier_profile` table change or creation plan.
- [ ] Provide forward SQL and rollback SQL.
- [ ] Review indexes, soft delete, tenant isolation and historical data impact.

## API Contract
- [ ] Confirm request and response wrapper.
- [ ] Confirm supplier submit/detail APIs.
- [ ] Confirm platform manager list/review APIs.
- [ ] Confirm error codes and permission failures.

## Backend
- [ ] Implement DTO/VO/entity/mapper/service/controller after DB and API are confirmed.
- [ ] Ensure review operation uses transaction when touching multiple tables.
- [ ] Add backend tests for submit, duplicate submit, approve and reject paths.

## Frontend
- [ ] Implement supplier onboarding submit/detail page.
- [ ] Implement platform manager review list and review action page.
- [ ] Add loading, empty, error and permission states.

## Local Agent
- [ ] Generate `local-agent-task.md` for the smallest confirmed slice.
- [ ] Run OpenCode/qwen3-coder only within allowed files.
- [ ] Run project tests and summarize logs.

## Review And Verification
- [ ] Run `bash scripts/run-tests.sh`.
- [ ] Run release review.
- [ ] Archive confirmed behavior to the target project's supplier onboarding spec file.
