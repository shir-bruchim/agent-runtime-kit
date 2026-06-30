# Edge Cases to Always Test

- **Empty inputs:** empty string, empty list, `None`
- **Boundary values:** min, max, just over/under limits
- **Invalid types or formats:** wrong type, malformed string, unexpected encoding
- **Concurrent access:** if the code path can run concurrently
- **Already-in-end-state (idempotency):** calling the operation twice produces the same result