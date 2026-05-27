# Proposal: Add Local Agent Execution Loop

## Summary
Add a documented local Agent execution loop for OpenCode + qianwen-coder, optional deepv4 review, unified test execution, and log summarization.

## Motivation
The control system already defines OpenSpec, skill routing, codegen adapters, review rules, and installation profiles. It does not yet define how a confirmed OpenSpec task can be handed to a local coding Agent while preserving scope control, validation, and final review.

## Scope
- Add local Agent workflow documentation.
- Add OpenCode/qianwen-coder execution guidance.
- Add deepv4 review guidance as a placeholder integration.
- Add task and review templates for local Agent execution.
- Add unified test and log summary scripts.
- Add a workflow skill for local Agent loops.
- Add a `local-agent` install profile.

## Impact Scope
```yaml
affected_files:
  - AGENTS.md
  - CODEX_TASK_TEMPLATE.md
  - README.md
  - docs/DEEPV4_REVIEW.md
  - docs/LOCAL_AGENT_WORKFLOW.md
  - docs/OPENCODE_QWEN_RUNNER.md
  - docs/SKILL_ROUTING.md
  - docs/TESTING_RULES.md
  - profiles/local-agent/profile.toml
  - scripts/local-agent-loop-example.sh
  - scripts/prepare-deepv4-review.sh
  - scripts/providers/deepv4-openai-compatible.sh
  - scripts/run-deepv4-review.sh
  - scripts/run-tests.sh
  - scripts/summarize-log.sh
  - templates/deepv4-review-input.md
  - templates/local-agent-review.md
  - templates/local-agent-task.md
  - templates/local-agent.env.example
affected_tables:
  - none
affected_apis:
  - none
affected_pages:
  - none
affected_skills:
  - workflow-local-agent-loop
  - workflow-openspec-apply
```

## Non-goals
- Do not integrate a real deepv4 API.
- Do not hard-code an OpenCode command beyond a configurable default.
- Do not run database writes.
- Do not change business project code.
- Do not replace OpenSpec, Codex review, or release review.

## Risks
- Local Agents may expand scope if task files are vague.
- Test commands may be project-specific and require target project overrides.
- deepv4 output may be mistaken for confirmed business rules.

## Mitigation
- Require explicit allowed and forbidden modification scopes.
- Keep `PROJECT_TEST_COMMAND`, `LOCAL_AGENT_COMMAND`, and `DEEPV4_REVIEW_COMMAND` configurable.
- Route deepv4 output as review input only, never as a fact source.
