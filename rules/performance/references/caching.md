# Caching Strategy

Cache what's: expensive to compute, read frequently, changed infrequently.

```
L1: In-process memory cache (fastest, not shared across instances)
L2: Redis (shared, survives restarts, pub/sub)
L3: CDN (for public static assets)
```

## Cache Invalidation

The hardest problem. Prefer:
- TTL (time-based expiry) for data with acceptable staleness
- Event-based invalidation for data that must be current
- Cache-aside (lazy loading) over write-through for most cases