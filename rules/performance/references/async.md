# Async and Concurrency

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

## Loop-bound singletons must live on ONE loop for the worker's lifetime

Producers/clients that cache internal state on the loop that constructed them (aiokafka, aiohttp, `httpx.AsyncClient`, SQLAlchemy async engines) break if a *different* loop tries to use them. In a worker binary:

- Boot the loop ONCE at the outermost `main()` entry point.
- Keep the same loop alive for every work-item.
- Bridge to sync SDKs / blocking I/O with `asyncio.to_thread(sync_fn, ...)` at the boundary — NOT with `asyncio.run(async_fn())` at the innermost dispatch.

```python
# Bad: every iteration builds a fresh loop and orphans the producer.
for msg in sqs_poll():
    asyncio.run(handle(msg))  # producer started here is unusable next iteration

# Good: the singleton and every dispatch share one loop.
async def main():
    await start_kafka_producer()
    try:
        async for msg in sqs_poll_async():
            await handle(msg)
    finally:
        await stop_kafka_producer()

asyncio.run(main())
```

The failure mode surfaces as `RuntimeError: attached to a different loop` far from the root cause, or (worse) silently — `publish_event` finds the module-level singleton is `None` on a fresh loop and drops the message.