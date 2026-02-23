---
name: tdd
description: Test-driven development workflow. Red-green-refactor cycle with verification loops. Use when practicing TDD, ensuring test-first development, or setting up a verification loop for complex implementations.
---

<objective>
Test-driven development: write the test first, make it pass, then refactor. The discipline of writing tests before code produces better-designed, more testable software.
</objective>

<tdd_cycle>
## Red-Green-Refactor

**Red:** Write a failing test
```
1. Write the simplest test that describes desired behavior
2. Run test: it MUST fail (if it passes, you haven't written the right test)
3. The error message should be clear about what's missing
```

**Green:** Make it pass
```
1. Write the MINIMUM code to make the test pass
2. Don't optimize yet — just make it pass
3. Run test: it MUST pass now
4. Don't write more code than needed for this test
```

**Refactor:** Improve without breaking
```
1. Clean up the code with confidence (tests guard against regression)
2. Extract duplication, improve names, simplify logic
3. Run tests after every change: all must still pass
4. Don't add new behavior in refactor phase
```
</tdd_cycle>

<verification_loop>
## Verification Loop Pattern

For complex implementations, use a continuous verification loop:

```
Write test → Run test (expect fail) → Implement → Run test (expect pass) → Refactor → Run tests → Next test
```

**At each step:**
```bash
# Python
pytest tests/test_feature.py -v

# TypeScript
npm test -- --watch

# Go
go test ./... -run TestFeature -v
```

Never proceed to the next test until the current one passes.
</verification_loop>

<test_design>
## Designing Good Tests

**Start with acceptance criteria:**
```
Feature: User login
Given: A registered user
When: They provide correct credentials
Then: They receive a valid JWT token

Given: A registered user
When: They provide incorrect password
Then: They receive a 401 with "Invalid credentials"
```

**Map to tests:**
```python
def test_login_succeeds_with_correct_credentials():
def test_login_fails_with_wrong_password():
def test_login_fails_with_nonexistent_user():
def test_login_returns_jwt_token_on_success():
```

**Test structure (Arrange-Act-Assert):**
```python
def test_login_succeeds_with_correct_credentials(client, test_user):
    # Arrange
    credentials = {"email": test_user.email, "password": "correct-password"}
    
    # Act
    response = client.post("/auth/login", json=credentials)
    
    # Assert
    assert response.status_code == 200
    assert "access_token" in response.json()
```
</test_design>

<success_criteria>
- Tests written BEFORE implementation
- Each test fails first (validates the test)
- Minimum code written to pass
- Refactoring done with test safety net
- All tests passing after each change
</success_criteria>
