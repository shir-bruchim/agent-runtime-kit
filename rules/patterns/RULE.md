---
name: patterns
description: Common design patterns — repository pattern, API response envelope, skeleton-project bootstrapping, and event-driven coordination patterns.
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

## Event-Driven Patterns (Summary)

For agent coordination and complex workflows, the main shapes are:
- **Orchestrator-Worker** — central orchestrator delegates to specialized workers
- **Blackboard** — shared workspace; workers read/write independently
- **Guardrails** — validate inputs and outputs at the boundary

For details and selection criteria, see [references/event-driven.md](references/event-driven.md).