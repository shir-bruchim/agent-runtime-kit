---
paths: ["**/*.py", "**/*.ts", "**/*.js"]
---

# Common Design Patterns

## Repository Pattern

Encapsulate data access behind a consistent interface:
- Define standard operations: findAll, findById, create, update, delete
- Business logic depends on the abstract interface, not storage details
- Enables easy swapping of data sources and simplifies testing with mocks

## API Response Envelope

Use a consistent format for all API responses:
```json
{
  "success": true,
  "data": { ... },
  "error": null,
  "meta": { "total": 100, "page": 1, "limit": 20 }
}
```
- `success` — boolean status indicator
- `data` — payload (nullable on error)
- `error` — error message (nullable on success)
- `meta` — pagination metadata (when applicable)

## Skeleton Project Approach

When implementing new functionality:
1. Search for battle-tested skeleton/template projects
2. Evaluate options (security, extensibility, relevance)
3. Clone best match as foundation
4. Iterate within the proven structure

Avoid building from scratch when good templates exist.

## Event-Driven Patterns

For agent coordination and complex workflows:

### Orchestrator-Worker
- Central orchestrator delegates to specialized workers
- Workers report back; orchestrator decides next step
- Use when tasks have natural ordering or dependencies

### Blackboard Pattern
- Shared workspace (file, database, or shared state)
- Workers read from and write to the blackboard independently
- Use when workers need to collaborate on a shared artifact

### Guardrails
- Validate inputs before processing
- Validate outputs before returning
- Use safety hooks (PreToolUse) for blocking dangerous operations
- Separate validation from logic
