# Testing Standards

## Test What Matters

Test: business logic, edge cases, error conditions, integration points
Don't test: getters/setters, framework code, language built-ins, generated code

## Three-Level Strategy

**Unit tests** (most): Test individual functions/methods in isolation
- Fast (< 1ms each)
- No external dependencies (mock them)
- Test one scenario per test

**Integration tests** (some): Test services working together
- Real database (test instance), mocked external APIs
- Test the interactions between components
- Slower, but catch issues unit tests miss

**E2E tests** (few): Test full user workflows
- Real browser, real services
- Expensive and slow — use for critical paths only

## Test Naming

Name tests like sentences describing behavior:
```python
# Good
def test_user_cannot_login_with_expired_token():
def test_cart_total_includes_taxes():
def test_send_email_raises_on_invalid_address():

# Bad
def test_login():
def test_total():
def test_email():
```

## Test Structure (AAA)

```python
def test_apply_discount_reduces_total():
    # Arrange: set up the scenario
    cart = Cart([Item(price=100), Item(price=50)])
    
    # Act: perform the action
    cart.apply_discount(percent=10)
    
    # Assert: verify the outcome
    assert cart.total == 135.0  # 150 * 0.90
```

## Edge Cases to Always Test

- Empty inputs (empty string, empty list, None)
- Boundary values (min, max, just over/under limits)
- Invalid types or formats
- Concurrent access (if relevant)
- Already-in-end-state (idempotency)

## Test Coverage

80% line coverage is a reasonable default. More important than the number:
- Critical paths covered
- Error conditions tested
- No tests that only test trivial code
