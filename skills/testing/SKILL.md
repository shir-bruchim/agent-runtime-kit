---
name: testing
description: Comprehensive testing guidance for writing maintainable, effective tests. Covers pytest (Python), Jest/Vitest (JavaScript/TypeScript), Go testing, and general TDD patterns. Use when writing tests, setting up test infrastructure, reviewing test quality, or improving test coverage.
---

<objective>
Testing guidance for multiple languages and frameworks. Core principles apply universally; language-specific patterns and examples are in `languages/<lang>/testing.md`.
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
- **Real objects for domain types** — instantiate real pydantic schemas, ORM rows, internal models with real values. `MagicMock` for a domain object silently accepts any attribute access and lets schema breaks pass — production-only failure mode. Mocks remain ok for system boundaries (DB session, HTTP client, scraper, logger).
- **Test factories live in conftest** — when a test needs a real model/schema/ORM object, add a `make_*` factory fixture to `tests/conftest.py`, not a private `_make_*` helper inside a single test file. Use via dependency injection: `def test_x(make_thing): ...`. The factory takes `**overrides` so each test can customize.
- **Imports at the top of the file** — never `from foo import Bar` inside a test body.
- Use existing fixtures from `conftest.py` before creating new ones
- When fixing failing tests: fix test inputs/data to match real behavior — do not add more mocks
- Delete flaky tests outright — do not weaken assertions to make them pass

</pytest_principles>

<routing>
| Language/Task | Reference |
|---------------|-----------|
| Python pytest patterns and examples | `languages/python/testing.md` |
| Python mocking patterns | `languages/python/testing.md` |
| TypeScript/JS testing | `languages/typescript/testing.md` |
| Node.js testing | `languages/nodejs/testing.md` |
| Go testing | `languages/go/testing.md` |
| C++ testing | `languages/cpp/testing.md` |
| Integration test infrastructure (LocalStack, Docker Compose) | `references/localstack-integration.md` |
| LocalStack AWS service configs (S3, SQS, DynamoDB, Secrets Manager) | `references/localstack-aws-services.md` |
| Docker Compose test patterns, container management | `references/docker-compose-testing.md` |
| TDD workflow (red-green-refactor) | `workflows/tdd.md` |
</routing>

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
