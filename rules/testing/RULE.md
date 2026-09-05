---
name: testing
description: Universal testing standards — what to test, naming, AAA structure, three-level pyramid, edge-case coverage, and the 80% coverage default.
---

# Testing Standards

## Test What Matters

Test: business logic, edge cases, error conditions, integration points
Don't test: getters/setters, framework code, language built-ins, generated code

## Ordering: Test-First for Non-Trivial Changes

For any change with real logic, write the failing test before the implementation and run it to confirm it fails (red). Then write the minimum production code to make it pass (green). Refactor with the test as safety net. The red step is non-optional — a test that passes before you write the code is testing the wrong thing.

Exceptions worth naming out loud (say so before skipping the red step):
- Pure config or dependency bumps with no behavior change.
- Trivial one-line fixes where the failure mode is caught by the existing suite.
- Exploratory spikes that you'll throw away before shipping.

For the full red-green-refactor loop see `~/.claude/skills/testing/workflows/tdd.md`.

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

**Share setup, don't copy it.** Extract repeated arrange-phase construction into reusable fixtures or factory helpers (e.g. `conftest.py` fixtures taking `**overrides`) so each test declares only what's unique to its scenario. Copy-pasted arrange blocks drift apart and hide what each test actually varies.

## Edge Cases

Always consider: empty inputs, boundary values, invalid types, concurrent access, idempotency. For the full list with examples, see [references/edge-cases.md](references/edge-cases.md).

## Test Coverage

80% line coverage is a reasonable default. More important than the number:
- Critical paths covered
- Error conditions tested
- No tests that only test trivial code