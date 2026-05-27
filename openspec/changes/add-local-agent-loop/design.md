# Design: Local Agent Execution Loop

## Architecture

```text
OpenSpec confirmed change
-> workflow-openspec-apply
-> workflow-local-agent-loop
-> OpenCode/qianwen-coder execution
-> scripts/run-tests.sh
-> scripts/summarize-log.sh
-> optional deepv4 review
-> release-production-review
```

## Files
- `docs/LOCAL_AGENT_WORKFLOW.md`: end-to-end process and guardrails.
- `docs/OPENCODE_QWEN_RUNNER.md`: OpenCode/qianwen-coder execution contract.
- `docs/DEEPV4_REVIEW.md`: deepv4 review contract and placeholder command.
- `.codex/skills/workflow-local-agent-loop/SKILL.md`: Codex skill entry.
- `templates/local-agent-task.md`: task handoff template.
- `templates/local-agent-review.md`: review handoff template.
- `scripts/run-tests.sh`: project test entrypoint.
- `scripts/summarize-log.sh`: token-conscious log summary.
- `scripts/local-agent-loop-example.sh`: adaptable loop example.
- `profiles/local-agent/profile.toml`: install profile.

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

## Execution Commands
The default local Agent command is configurable:

```bash
LOCAL_AGENT_COMMAND='opencode run'
```

Project validation can be overridden:

```bash
PROJECT_TEST_COMMAND='mvn test' bash scripts/run-tests.sh
```

deepv4 is intentionally left as a placeholder:

```bash
DEEPV4_REVIEW_COMMAND='your-deepv4-review-command'
```

## Safety Rules
- Only confirmed OpenSpec tasks can enter the local Agent loop.
- The task file must list allowed and forbidden paths.
- Automatic repair is capped at 3 rounds.
- Full logs are saved locally; only summaries should be passed to models.
- deepv4 suggestions must return to OpenSpec or user confirmation if they change business behavior.
