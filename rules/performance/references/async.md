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