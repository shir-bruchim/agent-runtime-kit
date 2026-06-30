---
name: testing
description: Universal testing standards — what to test, naming, AAA structure, three-level pyramid, edge-case coverage, and the 80% coverage default.
---

# Testing Standards

## Test What Matters

Test: business logic, edge cases, error conditions, integration points
Don't test: getters/setters, framework code, language built-ins, generated code

## Test Pyramid (Summary)

- **Unit tests** (most): fast, isolated, one scenario each
- **Integration tests** (some): real DB, mocked external APIs
- **E2E tests** (few): real browser, real services — critical paths only

For details on each level, see [references/three-level-strategy.md](references/three-level-strategy.md).

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

## Edge Cases

Always consider: empty inputs, boundary values, invalid types, concurrent access, idempotency. For the full list with examples, see [references/edge-cases.md](references/edge-cases.md).

## Test Coverage

80% line coverage is a reasonable default. More important than the number:
- Critical paths covered
- Error conditions tested
- No tests that only test trivial code