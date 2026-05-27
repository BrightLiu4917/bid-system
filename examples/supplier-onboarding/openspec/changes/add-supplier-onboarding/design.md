# Design: Supplier Onboarding

## Requirement Understanding
There are three role families in the larger system: platform manager, expert and supplier. This example only covers supplier onboarding.

Supplier submits materials. Platform manager reviews the application. Supplier can see the current result.

## Domain Draft
- Supplier profile: organization identity after onboarding is approved.
- Onboarding application: one submitted review request.
- Review decision: platform manager decision on an application.

## Example Status Candidates
These statuses are not confirmed business rules:
- `DRAFT`
- `SUBMITTED`
- `APPROVED`
- `REJECTED`

## Impact Scope
```yaml
affected_files:
  - api/src/main/java
  - vue/src/views
  - vue/src/api
affected_tables:
  - supplier_onboarding_application
  - supplier_profile
affected_apis:
  - POST /api/supplier/onboarding/applications
  - GET /api/supplier/onboarding/applications/current
  - GET /api/platform/supplier-onboarding/applications
  - POST /api/platform/supplier-onboarding/applications/{id}/review
affected_pages:
  - /supplier/onboarding
  - /platform/supplier-onboarding
affected_skills:
  - product-business-domain-modeling
  - backend-common-api-contract-review
  - dba-mysql
  - backend-java-springboot
  - frontend-common-implementation
  - workflow-local-agent-loop
  - release-production-review
```

## Data Safety
- Do not create or alter tables until DBA review confirms fields, indexes and rollback SQL.
- Review write operation must be transactional if it updates application and supplier profile together.
- Do not use full-table update or delete.

## API Safety
- Response wrapper, pagination and error codes must use target project conventions.
- Sensitive materials must not be returned to unauthorized roles.
- Platform manager endpoints must enforce role permission.

## Implementation Plan
1. Confirm fields, statuses, permissions and response wrapper.
2. DBA designs tables and migration SQL.
3. API contract is reviewed.
4. Backend implements minimal confirmed workflow.
5. Frontend implements supplier submit page and platform review page.
6. Run tests and release review.
