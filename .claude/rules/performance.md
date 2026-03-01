# Performance Guidelines

## Measure First, Optimize Second

**Never optimize without evidence.** Profile before optimizing:
- `cProfile` / `py-spy` (Python)
- `perf` / `flamegraph` (system)
- Browser DevTools Performance tab (frontend)
- `EXPLAIN ANALYZE` (PostgreSQL)

## Database Performance

**Avoid N+1 queries** — the most common performance issue:
```python
# BAD: N+1 — 1 query for users + N queries for their posts
users = db.query(User).all()
for user in users:
    print(user.posts)  # Separate query for each user!

# GOOD: Eager loading
users = db.query(User).options(selectinload(User.posts)).all()
```

**Index rules:**
- Always index foreign keys
- Index columns frequently used in WHERE, ORDER BY, JOIN
- Check query plans with EXPLAIN ANALYZE
- Composite indexes for multi-column filters

**Connection pooling:** Use connection pooling in production. Don't create a new connection per request.

## Caching Strategy

Cache what's: expensive to compute, read frequently, changed infrequently.

```
L1: In-process memory cache (fastest, not shared across instances)
L2: Redis (shared, survives restarts, pub/sub)
L3: CDN (for public static assets)
```

**Cache invalidation:** The hardest problem. Prefer:
- TTL (time-based expiry) for data with acceptable staleness
- Event-based invalidation for data that must be current
- Cache-aside (lazy loading) over write-through for most cases

## Async and Concurrency

Use async for I/O-bound work, not CPU-bound:
```python
# Good: I/O bound (network call, DB query)
async def get_user(user_id: int):
    return await db.get(User, user_id)

# Not helped by async: CPU-bound work
# For CPU-bound: use multiprocessing, not asyncio
def compute_hash(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()
```

## Frontend Performance

- Minimize bundle size: code splitting, tree shaking, lazy loading
- Avoid layout thrashing (batch DOM reads/writes)
- Use `React.memo` / `useMemo` only when profiling shows need
- Images: proper format (WebP), sizes (srcset), lazy loading
