# Proposal: Add Supplier Onboarding

## Summary
Add supplier registration, material submission and platform audit workflow.

## Motivation
Suppliers need a controlled onboarding process before they can participate in bidding activities. Platform managers need a review queue to approve or reject supplier applications.

## Scope
- Supplier submits registration and onboarding materials.
- Platform manager reviews submitted materials.
- Supplier sees onboarding result.
- System records review decision and reason.

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

## Non-goals
- Do not implement expert onboarding in this change.
- Do not implement bidding application in this change.
- Do not define payment, package deduction or notification rules.
- Do not infer tenant rules.

## Open Questions
- Supplier registration identity source and login method are not confirmed.
- Material fields are examples only and must be confirmed before implementation.
- Audit statuses are examples only and must be confirmed before implementation.
- API response wrapper and error code format must follow the target project.
