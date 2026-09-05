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

## Official SDK by Default

When a vendor ships an official SDK, use it. If the workload needs async and only a sync SDK is shipped, wrap sync calls in a thread executor (e.g. `asyncio.to_thread(client.method, ...)`) instead of adopting a community async fork. Vendor SDKs get first-class CVE fixes and match the vendor's release cadence; community re-implementations don't. Adopt a community port only when the team explicitly greenlights it after weighing maintenance and supply-chain risk.

**Before pinning any SDK/dep, check it's compatible with the project's core-framework major version.** A pydantic-v1-built SDK cannot install in a pydantic-v2 service — pip returns `ResolutionImpossible` and the CI build fails before a single test runs. Reusing an SDK from a sibling repo does NOT mean it fits here: verify the sibling's own core-framework pin (its `pydantic==1.x` vs your `pydantic>=2`) first. If the only SDK is built for the wrong major, wrap the vendor's HTTP API directly (e.g. `httpx`) instead of forcing the incompatible package in.

## Event-Driven Patterns (Summary)

For agent coordination and complex workflows, the main shapes are:
- **Orchestrator-Worker** — central orchestrator delegates to specialized workers
- **Blackboard** — shared workspace; workers read/write independently
- **Guardrails** — validate inputs and outputs at the boundary

**Escalation — take over a looping delegate.** When a delegated subagent stops converging — re-litigating a decision you already resolved, or misreading tool-permission denials as fresh user instructions and re-asking — stop sending it more messages and do the work directly in the main loop. More prompts reinforce the loop; a delegate that can't converge on message N won't on N+1. Relay the resolved decision once; if the next return still loops, reclaim the task.

For details and selection criteria, see [references/event-driven.md](references/event-driven.md).

## Parallel-Worker Coordination — Shared Mutable Registries

When N workers each need to modify their own entry in the same shared enumeration, sequential merges conflict on every worker past the first. The classic culprits:

- Allowlist / registry files (`_ALLOWLIST`, feature-flag registry, plugin index)
- Barrel / re-export files (`__init__.py`, `index.ts`)
- Ordered chains (Alembic `down_revision` pointers, dependency graphs)
- Shared config maps

Three coordination strategies, in order of preference:

1. **Orchestrator-owned cleanup commit.** Workers leave the shared file untouched. After all workers merge, the orchestrator makes ONE commit that updates the registry. Idempotent, no conflicts.
2. **Partition the enumeration.** Split into per-worker files that combine at load time (e.g., `plugins.d/*.yaml` loaded and merged). No shared-file writes, so no conflicts.
3. **Serialize the workers.** If the shared file can't be avoided or partitioned, run those tasks sequentially. The parallelism win was smaller than the merge cost anyway.

Never let two workers race a set literal / index in parallel and "resolve conflicts on merge." That's the pattern; the cost compounds with N.

**Same diagnostic principle:** if 2+ subagents in the same batch make the same mistake, the fix belongs in the shared upstream instruction (orchestrator workflow, subagent-role file, or a rule like this one) — NOT in each subagent's individual prompt. Repeated mistakes are always shared-instruction bugs.

**Verify delegate output against the diff.** When a subagent returns "already done" / "no change needed" / "existing behavior preserved," run `git diff` (or `git status` for parallel worktrees) BEFORE accepting the claim. The agent's summary reports intent; the tree reports outcome. This matters most for: (a) parallel agents whose worktrees may overlap on the same file, (b) refactor agents that describe existing state (they conflate "I added it" with "it was already there"), and (c) any agent whose next hand-off depends on file contents the caller hasn't re-read. One `git diff --stat` per return saves a re-correction cycle.

**A delegate's success claim is not verification — re-run the check.** When a subagent returns `status: "done"`, "tests pass", or "verified", confirm against the ACTUAL run output (exit code, the full test summary, the real command — not a stub), not the agent's prose. Recurring false-greens: a partial pass reported as a full pass, a stubbed/mocked runner that never executed the real thing, an unbound-variable crash masked as success, edits orphaned outside the target, an implementation the delegate fabricated instead of porting from the reference source (invented helpers, guessed signatures, reflection in place of the real API), or a suite run against an environment missing dependencies so collection silently skipped and reported green. One real re-run (or reading the raw output the delegate actually saw) per return beats a re-correction cycle. This is the run-output twin of the git-diff check above.