---
name: testing
description: Comprehensive testing guidance for writing maintainable, effective tests. Covers pytest (Python), Jest/Vitest (JavaScript/TypeScript), Go testing, and general TDD patterns. Use when writing tests, setting up test infrastructure, reviewing test quality, or improving test coverage.
---

<objective>
Testing guidance for multiple languages and frameworks. Core principles apply universally; language-specific patterns are in `references/` and `languages/` directories.
</objective>

<essential_principles>

**Test Independence**
- Each test must run in isolation — no shared mutable state
- Tests must pass in any execution order
- Use setup/teardown (fixtures) not class-level state

**Naming Conventions**
- Name tests after what they test: `test_user_cannot_login_with_wrong_password`
- Test files co-located or in `tests/` directory
- One logical assertion per test when practical

**Test Pyramid**
- Many unit tests (fast, isolated)
- Some integration tests (services working together)
- Few E2E tests (full user flows, expensive)

**Test Behavior, Not Implementation**
- Test what the code does, not how it does it
- Test public APIs, not private implementation details
- If refactoring breaks tests without changing behavior: tests are testing implementation

**Coverage as a Tool, Not a Goal**
- 80% coverage is a reasonable default
- 100% coverage with meaningless tests is worse than 70% with meaningful ones
- Coverage shows untested paths — not that tests are good

</essential_principles>

<pytest_principles>

**When writing pytest (Python):**
- No fake tests — every assertion must test real behavior (invariants, boundaries, error semantics)
- Mock ONLY at system boundaries: DB, external HTTP, filesystem, clock. Never mock internal logic
- Use existing fixtures from `conftest.py` before creating new ones
- When fixing failing tests: fix test inputs/data to match real behavior — do not add more mocks
- Delete flaky tests outright — do not weaken assertions to make them pass

</pytest_principles>

<quick_reference>
## By Language

**Python (pytest):**
```python
# Fixture pattern
@pytest.fixture
def db_session():
    session = create_test_session()
    yield session
    session.rollback()

# Parametrize pattern
@pytest.mark.parametrize("email,valid", [
    ("user@example.com", True),
    ("not-an-email", False),
])
def test_email_validation(email, valid):
    assert is_valid_email(email) == valid

# Common commands
pytest -v                                         # Verbose
pytest -x                                         # Stop on first failure
pytest --lf                                       # Re-run last failed
pytest -k "pattern"                               # Filter by test name
pytest --cov=src --cov-report=html --cov-fail-under=80
```

**TypeScript/JavaScript (Jest/Vitest):**
```typescript
// Arrange-Act-Assert
describe('UserService', () => {
  it('should return user when id exists', async () => {
    const mockRepo = { findById: jest.fn().mockResolvedValue(mockUser) };
    const service = new UserService(mockRepo);
    const result = await service.getUser('123');
    expect(result).toEqual(mockUser);
  });
});
```

**Go:**
```go
func TestCalculateTotal(t *testing.T) {
    tests := []struct{
        name     string
        items    []Item
        expected float64
    }{
        {"empty cart", []Item{}, 0},
        {"single item", []Item{{Price: 10}}, 10},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got := calculateTotal(tt.items)
            assert.Equal(t, tt.expected, got)
        })
    }
}
```
</quick_reference>

<routing>
| Language/Task | Reference |
|---------------|-----------|
| Python pytest fixtures | `languages/python/testing.md` |
| Python mocking patterns | `languages/python/testing.md` |
| TypeScript/JS testing | `languages/typescript/testing.md` |
| Go testing | `languages/go/testing.md` |
| C++ testing | `languages/cpp/testing.md` |
| TDD workflow | `skills/tdd/SKILL.md` |
</routing>

<language_examples>

### Python (pytest)
```python
# tests/test_user_service.py
import pytest
from app.services.user import UserService
from app.models import User

@pytest.fixture
def user_service(db_session):
    return UserService(db_session)

def test_create_user_returns_user_with_id(user_service):
    user = user_service.create(name="Alice", email="alice@example.com")
    assert user.id is not None
    assert user.name == "Alice"

def test_create_user_fails_with_duplicate_email(user_service, existing_user):
    with pytest.raises(ValueError, match="already exists"):
        user_service.create(name="Bob", email=existing_user.email)

@pytest.mark.parametrize("email,valid", [
    ("alice@example.com", True),
    ("not-an-email", False),
    ("", False),
])
def test_email_validation(email, valid):
    assert UserService.is_valid_email(email) == valid
```

### Node.js (Jest)
```javascript
// tests/userService.test.js
const { UserService } = require('../src/services/userService');
const { createTestDb } = require('./helpers');

describe('UserService', () => {
  let service;
  let db;

  beforeEach(async () => {
    db = await createTestDb();
    service = new UserService(db);
  });

  afterEach(async () => db.close());

  it('creates a user and returns it with an id', async () => {
    const user = await service.create({ name: 'Alice', email: 'alice@example.com' });
    expect(user.id).toBeDefined();
    expect(user.name).toBe('Alice');
  });

  it('throws when email already exists', async () => {
    await service.create({ name: 'Alice', email: 'alice@example.com' });
    await expect(
      service.create({ name: 'Bob', email: 'alice@example.com' })
    ).rejects.toThrow('already exists');
  });

  it.each([
    ['alice@example.com', true],
    ['not-an-email', false],
    ['', false],
  ])('validates email %s as %s', (email, expected) => {
    expect(UserService.isValidEmail(email)).toBe(expected);
  });
});
```
</language_examples>

<success_criteria>
- Tests run in isolation (no order dependency)
- Tests cover happy path, error paths, and edge cases
- Names describe what is being tested
- Coverage meets project standard (usually 80%)
- Tests pass reliably without flakiness
</success_criteria>

<fixing_tests>

**When invoked to fix failing tests (not write new ones):**
1. NO production code changes — fix tests only (unless explicitly told otherwise)
2. Debug first: print what the function actually returns before asserting
3. Fix test inputs/data to match real behavior — do not add more mocks
4. Use existing conftest fixtures — do not create duplicates
5. Remove any `@pytest.mark.skip` once the test is passing

</fixing_tests>
