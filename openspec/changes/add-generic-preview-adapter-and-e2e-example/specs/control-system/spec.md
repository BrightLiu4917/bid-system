## ADDED Requirements

### Requirement: Generic CRUD Preview Adapter
The control system SHALL provide a generic Java Spring Boot CRUD preview adapter that creates review drafts only and SHALL NOT write directly to business source directories.

#### Scenario: Preview without writing files
- GIVEN a user provides project root, package, entity, table, route, display name and fields
- WHEN the generic preview adapter runs without `--write`
- THEN it SHALL print planned draft files
- AND it SHALL write no files.

#### Scenario: Write review drafts only
- GIVEN a user provides confirmed preview parameters
- WHEN the generic preview adapter runs with `--write`
- THEN it SHALL create files under `.codex/codegen-preview/<EntityName>/`
- AND it SHALL NOT modify `src/main`.

### Requirement: Route Compliance Check
The control system SHALL provide a lightweight route compliance check that compares declared OpenSpec impact scope with expected task gates.

#### Scenario: Database impact requires DBA task
- GIVEN an OpenSpec change declares `affected_tables` with values other than `none`
- WHEN the route compliance check runs
- THEN `tasks.md` SHALL mention a DBA, database or SQL review task.

#### Scenario: API impact requires contract task
- GIVEN an OpenSpec change declares `affected_apis` with values other than `none`
- WHEN the route compliance check runs
- THEN `tasks.md` SHALL mention an API contract task.

### Requirement: CI Templates
The control system SHALL provide copyable CI templates that run the standard local checks.

#### Scenario: GitHub Actions template
- GIVEN a project uses GitHub Actions
- WHEN it copies `templates/ci/github-actions.yml`
- THEN the workflow SHALL run shell syntax, skill, route, docs link and OpenSpec conflict checks.

### Requirement: End-To-End Learning Example
The control system SHALL include a complete example that demonstrates OpenSpec, API contract, task slicing, local-agent handoff and review outputs.

#### Scenario: User studies supplier onboarding example
- GIVEN a user opens `examples/supplier-onboarding`
- WHEN they read the example
- THEN they SHALL see the relationship between OpenSpec files, API contract, task file, local-agent task and review report.
