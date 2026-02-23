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
pytest -v -x --lf --cov=src
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

<success_criteria>
- Tests run in isolation (no order dependency)
- Tests cover happy path, error paths, and edge cases
- Names describe what is being tested
- Coverage meets project standard (usually 80%)
- Tests pass reliably without flakiness
</success_criteria>
