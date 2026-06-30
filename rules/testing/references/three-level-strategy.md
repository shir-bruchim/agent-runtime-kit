# Three-Level Test Strategy

## Unit tests (most)

Test individual functions/methods in isolation.

- Fast (< 1ms each)
- No external dependencies (mock them)
- Test one scenario per test

## Integration tests (some)

Test services working together.

- Real database (test instance), mocked external APIs
- Test the interactions between components
- Slower, but catch issues unit tests miss

## E2E tests (few)

Test full user workflows.

- Real browser, real services
- Expensive and slow — use for critical paths only