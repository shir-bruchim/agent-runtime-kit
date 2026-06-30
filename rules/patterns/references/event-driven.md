# Event-Driven Patterns

For agent coordination and complex workflows.

## Orchestrator-Worker

- Central orchestrator delegates to specialized workers
- Workers report back; orchestrator decides next step
- Use when tasks have natural ordering or dependencies

## Blackboard Pattern

- Shared workspace (file, database, or shared state)
- Workers read from and write to the blackboard independently
- Use when workers need to collaborate on a shared artifact

## Guardrails

- Validate inputs before processing
- Validate outputs before returning
- Use safety hooks (PreToolUse) for blocking dangerous operations
- Separate validation from logic