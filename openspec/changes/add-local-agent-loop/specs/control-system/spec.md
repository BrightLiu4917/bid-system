# Control System Spec Delta

## ADDED Requirements

### Requirement: Control system must support local Agent execution loop
The control system SHALL provide a documented workflow for handing a confirmed OpenSpec task to a local Agent while preserving scope control, validation, and final review.

#### Scenario: User chooses OpenCode/qianwen-coder for implementation
- GIVEN an OpenSpec change has been confirmed
- WHEN the user chooses local Agent implementation
- THEN the workflow routes through `workflow-local-agent-loop`
- AND the task is constrained by a local Agent task file
- AND implementation must return to release review before completion.

### Requirement: Local Agent task must define allowed scope
Local Agent execution SHALL require a task input that defines allowed modifications, forbidden modifications, validation command, and maximum repair rounds.

#### Scenario: Local Agent receives a task
- GIVEN a task file based on `templates/local-agent-task.md`
- WHEN OpenCode/qianwen-coder executes the task
- THEN it only modifies the allowed scope
- AND it reports validation results and unresolved risks.

### Requirement: Local Agent task must carry Codex skill constraints
The control system SHALL pass Codex skill guidance to qianwen-coder through the local Agent task file, including applicable skills, a task-specific skill summary, and required source rule files.

#### Scenario: Codex delegates a backend task to qianwen-coder
- GIVEN Codex selected `backend-java-springboot` and `release-production-review`
- WHEN Codex creates a local Agent task
- THEN the task lists those applicable skills
- AND it includes a concise summary of the constraints that matter for the task
- AND it lists the original skill files that OpenCode/qianwen-coder should read when needed.

### Requirement: Test output must be summarized before model feedback
The control system SHALL provide a log summarization script so full logs can remain on disk while models receive concise failure summaries.

#### Scenario: Tests fail during local Agent execution
- GIVEN `scripts/run-tests.sh` wrote `.agent/logs/test.log`
- WHEN the log summarization command runs
- THEN it prints key failure lines and a bounded log tail.

### Requirement: Local Agent scripts must support machine-local environment config
The control system SHALL support a project-local `.agent/local-agent.env` file for machine-specific commands such as `LOCAL_AGENT_COMMAND` and `PROJECT_TEST_COMMAND`.

#### Scenario: Developer configures project test command
- GIVEN `.agent/local-agent.env` defines `PROJECT_TEST_COMMAND`
- WHEN `scripts/run-tests.sh` runs
- THEN it loads the local config before selecting the test command.

### Requirement: deepv4 review must not become a fact source
deepv4 review SHALL be treated as a second review input only and must not replace OpenSpec or user confirmation.

#### Scenario: deepv4 suggests a business rule change
- GIVEN deepv4 reviews a local Agent diff
- WHEN it suggests a change to fields, states, permissions, API response, or workflow behavior
- THEN the suggestion is recorded as a review issue
- AND implementation stops until OpenSpec or the user confirms the rule.

### Requirement: deepv4 review must support OpenAI-compatible API
The control system SHALL provide scripts that prepare deepv4 review input and call a configured OpenAI-compatible review provider.

#### Scenario: deepv4 review command is configured
- GIVEN `.agent/local-agent.env` defines `DEEPV4_REVIEW_COMMAND`
- WHEN `scripts/run-deepv4-review.sh` runs
- THEN it sends `.agent/reviews/deepv4-input.md` to the configured command
- AND writes the review result to `.agent/reviews/deepv4-output.md`.

#### Scenario: deepv4 review command is not configured
- GIVEN `DEEPV4_REVIEW_COMMAND` is empty
- WHEN `scripts/run-deepv4-review.sh` runs
- THEN it writes a skipped message
- AND exits successfully without calling an external service.
