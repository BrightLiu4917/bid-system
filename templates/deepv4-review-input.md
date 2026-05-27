# deepv4 Review Input

## Review Goal
Review the current change for business logic, data safety, security, API compatibility, SQL risk, transaction boundaries, and missing tests. Do not rewrite code.

## OpenSpec Summary
Paste confirmed proposal/design/task summary here.

## Confirmed Business Rules
1. 

## Test Summary
```text
Paste scripts/summarize-log.sh output here.
```

## Git Diff
```diff
Paste focused git diff here.
```

## Review Questions
- Did the change guess business rules, fields, enums, API paths, permissions, status flows, or response formats?
- Are there tenant, permission, soft-delete, or data visibility gaps?
- Are transaction boundaries, concurrency, idempotency, and repeated-submit behavior safe?
- Are SQL and database changes safe, indexed, rollbackable, and compatible with existing data?
- Are API contracts and frontend expectations compatible?
- Are tests or verification steps missing for high-risk behavior?

## Required Output Format
1. Blocking issues
2. Important risks
3. Questions needing user confirmation
4. Suggested tests
5. Whether this is ready for Codex final review
