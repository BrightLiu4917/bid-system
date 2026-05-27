## ADDED Requirements

### Requirement: Supplier Onboarding Application
The system SHALL allow a supplier user to submit onboarding materials for platform manager review.

#### Scenario: Supplier submits application
- GIVEN supplier onboarding fields and validation rules are confirmed
- WHEN the supplier submits valid materials
- THEN the system SHALL create or update the supplier onboarding application according to confirmed status rules.

### Requirement: Platform Review
The system SHALL allow platform managers to review supplier onboarding applications.

#### Scenario: Platform manager approves application
- GIVEN an application is in a confirmed reviewable status
- WHEN a platform manager approves it
- THEN the system SHALL persist the approval decision
- AND SHALL update supplier profile state according to confirmed transaction rules.

#### Scenario: Platform manager rejects application
- GIVEN an application is in a confirmed reviewable status
- WHEN a platform manager rejects it with a confirmed reason field
- THEN the system SHALL persist the rejection decision
- AND SHALL make the result visible to the supplier according to confirmed visibility rules.
