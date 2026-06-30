---
name: performance
description: Performance principles — measure-first profiling, DB query/index rules, caching strategy, async vs CPU-bound work, and frontend perf.
---

# Performance Guidelines

## Measure First, Optimize Second

**Never optimize without evidence.** Profile before optimizing:
- `cProfile` / `py-spy` (Python)
- `perf` / `flamegraph` (system)
- Browser DevTools Performance tab (frontend)
- `EXPLAIN ANALYZE` (PostgreSQL)

## Core Rules at a Glance

- **Database:** No N+1; index FKs and WHERE/ORDER BY/JOIN columns; use connection pooling. See [references/db-performance.md](references/db-performance.md).
- **Caching:** Cache things that are expensive, read-often, change-rarely. Prefer TTL; pick cache-aside by default. See [references/caching.md](references/caching.md).
- **Async:** Async is for I/O-bound work, not CPU-bound. See [references/async.md](references/async.md).
- **Frontend:** Minimize bundle size; avoid layout thrashing; memoize only when profiling shows need. See [references/frontend.md](references/frontend.md).