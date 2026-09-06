---
name: performance
description: Performance principles — measure-first profiling, DB query/index rules, caching, async vs CPU-bound work.
---

# Performance Guardrails

- **Measure first.** Never optimize without evidence — profile with `cProfile`/`py-spy`, `EXPLAIN ANALYZE`, or DevTools before changing anything.
- **DB:** no N+1 (eager-load); index FKs and WHERE/ORDER BY/JOIN columns; use connection pooling.
- **Caching:** cache what's expensive + read-often + changes-rarely; prefer TTL and cache-aside.
- **Async is for I/O-bound work, not CPU-bound** (use processes for CPU). Loop-cached clients (aiokafka, httpx.AsyncClient, async SQLAlchemy engines) must live on ONE loop for the worker's lifetime — boot the loop once at `main()`, bridge to sync SDKs with `asyncio.to_thread(...)`, never `asyncio.run()` per work-item.
- **Frontend:** minimize bundle (code-split, tree-shake); memoize only when profiling shows need.

Deep-dives (DB, caching, async, frontend) live in the lazy `postgres-patterns` and language skills.
