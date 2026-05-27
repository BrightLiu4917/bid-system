# Control System Spec Delta

## ADDED Requirements

### Requirement: Project initialization script must draft project context
The control system SHALL provide a script that creates initial project context files from repository structure without inventing business rules.

#### Scenario: Developer initializes a new target project
- GIVEN a target project has installed the control system
- WHEN the developer runs `scripts/init-project.sh`
- THEN the script drafts `openspec/project.md`
- AND drafts `CONTEXT.md`
- AND detected technical stack is recorded as technical context, not business fact.

### Requirement: OpenSpec changes must support structured impact scope
OpenSpec change templates SHALL include structured impact scope fields for affected files, tables, APIs, pages, and skills.

#### Scenario: Developer creates a change proposal
- GIVEN the developer uses `templates/openspec-change/proposal.md`
- WHEN the proposal is filled out
- THEN the proposal contains `affected_files`, `affected_tables`, `affected_apis`, `affected_pages`, and `affected_skills`.

### Requirement: Impact scope must be checkable
The control system SHALL provide a script that validates the presence of impact scope fields in OpenSpec changes.

#### Scenario: Impact scope fields are missing
- GIVEN an OpenSpec change lacks required impact scope fields
- WHEN `scripts/impact-check.sh` runs
- THEN it reports the missing fields.

### Requirement: Concurrent OpenSpec changes should warn on declared conflicts
The control system SHALL provide a script that warns when multiple OpenSpec changes declare the same affected file, table, API, page, or skill.

#### Scenario: Two changes touch the same declared file
- GIVEN two active changes both list `README.md` under `affected_files`
- WHEN `scripts/openspec-conflict-check.sh` runs
- THEN it emits a warning identifying the overlapping changes.

### Requirement: Skill required references must be validated
The control system SHALL validate that local paths listed under a skill's `## 必须读取` section exist.

#### Scenario: Skill references a missing local file
- GIVEN a skill lists a missing local path under `## 必须读取`
- WHEN `scripts/skill-check.sh` runs
- THEN it fails with the missing reference path.
