# Async Python Patterns

Guide for implementing async Python applications using asyncio, concurrent patterns, and async/await for high-performance, non-blocking systems.

## Core Patterns

### Task Creation
```python
# Run multiple I/O operations concurrently
results = await asyncio.gather(
    fetch_user(user_id),
    fetch_orders(user_id),
    fetch_preferences(user_id),
)
```

### Async Context Manager
```python
async with httpx.AsyncClient(timeout=10.0) as client:
    response = await client.get(url)
```

### Async Generator
```python
async def stream_data(url: str):
    async with httpx.AsyncClient() as client:
        async with client.stream("GET", url) as response:
            async for chunk in response.aiter_bytes():
                yield chunk
```

### Semaphore for Rate Limiting
```python
sem = asyncio.Semaphore(10)  # max 10 concurrent

async def limited_fetch(url: str):
    async with sem:
        return await client.get(url)
```

## Common Bugs

### Blocking Call in Async Code
```python
# BAD: blocks the event loop
async def fetch():
    time.sleep(1)        # BLOCKS
    requests.get(url)    # BLOCKS

# GOOD: use async equivalents
async def fetch():
    await asyncio.sleep(1)
    async with httpx.AsyncClient() as client:
        await client.get(url)
```

### Fire-and-Forget Tasks
```python
# BAD: exception silently swallowed
asyncio.create_task(background_job())

# GOOD: handle task exceptions
task = asyncio.create_task(background_job())
task.add_done_callback(
    lambda t: t.exception() and logger.error(t.exception())
)
```

## Testing Async Code

```python
import pytest

@pytest.mark.asyncio
async def test_async_endpoint(async_client):
    response = await async_client.get("/api/users")
    assert response.status_code == 200
```

## Decision Guide

| Situation | Pattern |
|-----------|---------|
| Multiple independent I/O calls | `asyncio.gather()` |
| Rate-limited external API | `asyncio.Semaphore` |
| Streaming data | Async generator |
| Background processing | `asyncio.create_task()` with error callback |
| CPU-bound work in async app | `loop.run_in_executor()` |
| Timeout protection | `asyncio.wait_for(coro, timeout=5)` |

## Checklist

- No blocking calls in async code paths
- Timeouts on all external calls
- Task exceptions handled (not silently swallowed)
- Semaphores for rate-limited resources
