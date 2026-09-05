---
name: patterns
description: Design and delegation patterns — repository pattern, API envelope, official-SDK default, parallel-worker coordination, and verifying delegate output.
---

# Patterns

## Design
- **Repository pattern:** data access behind a consistent interface (`findAll/findById/create/update/delete`); business logic depends on the interface, not storage.
- **API response envelope:** `{ success, data, error, meta }` consistently across endpoints.
- **Skeleton-first:** clone a battle-tested template over building from scratch.
- **Official SDK by default.** Use the vendor SDK; if it's sync and you need async, wrap in `asyncio.to_thread(...)` — don't adopt a community fork. **Before pinning any SDK, verify it's compatible with the project's core-framework major** (a pydantic-v1 SDK won't install in a pydantic-v2 service → `ResolutionImpossible`). If the only SDK targets the wrong major, wrap the vendor HTTP API with `httpx` instead.

## Delegation & parallel work (how to use subagents)
- **Shared mutable registries** (`__init__.py`, allowlists, Alembic `down_revision`): don't let N workers race the same file. Prefer an orchestrator-owned cleanup commit, or partition into per-worker files. Serialize if neither is possible.
- **Repeated mistakes are shared-instruction bugs.** If 2+ subagents in a batch make the same error, fix the upstream instruction (workflow/role/rule), not each prompt.
- **Verify delegate output against the tree.** On "already done"/"no change needed", run `git diff`/`git status` before believing it — the summary reports intent, the tree reports outcome.
- **A success claim is not verification.** On "tests pass"/"done", re-run the real check and read the actual exit code + summary. Watch for stubbed runners, partial passes reported as full, and fabricated (not ported) implementations.
- **Reclaim a looping delegate.** If a subagent keeps re-litigating a resolved decision or re-asking after permission denials, stop messaging it and do the work in the main loop.
