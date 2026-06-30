---
name: testing
description: Testing guidance for pytest, Jest/Vitest, Go, and TDD. Use when writing tests or improving coverage.
---

<objective>
Testing guidance for multiple languages and frameworks. Core principles apply universally; language-specific patterns and examples are in `languages/<lang>/testing.md`.
</objective>

<essential_principles>
Universal test foundations — test pyramid, AAA structure, naming-as-behavior-sentence, ~80% coverage default, test independence, behavior-not-implementation — live in `~/.claude/rules/testing/RULE.md` (with deep-dives in `~/.claude/rules/testing/references/`). Read those first; the pytest-specific add-ons (real objects for domain types, factories in conftest, headers-asserted-too, module-level mutable state) live in `<pytest_principles>` below.
</essential_principles>

<pytest_principles>

**When writing pytest (Python):**
- No fake tests — every assertion must test real behavior (invariants, boundaries, error semantics)
- Mock ONLY at system boundaries: DB, external HTTP, filesystem, clock. Never mock internal logic
- **Real objects for domain types** — instantiate real pydantic schemas, ORM rows, internal models with real values. `MagicMock` for a domain object silently accepts any attribute access and lets schema breaks pass — production-only failure mode. Mocks remain ok for system boundaries (DB session, HTTP client, scraper, logger).
- **Test factories live in conftest** — when a test needs a real model/schema/ORM object, add a `make_*` factory fixture to `tests/conftest.py`, not a private `_make_*` helper inside a single test file. Use via dependency injection: `def test_x(make_main_table_client): ...`. The factory takes `**overrides` so each test can customize.
- **One test file per production module** — mirror the production layout. Prefer `tests/test_<module>.py` covering everything in `app/.../<module>.py` over splitting by concern (e.g. `test_<module>_report.py` + `test_<module>_schedules.py`). Split files drift apart, duplicate helpers, and hide shared fixtures. Consolidate before adding new tests when a module already has multiple test files.
- **Imports at the top of the file** — never `from foo import Bar` inside a test body.
- Use existing fixtures from `conftest.py` before creating new ones
- When fixing failing tests: fix test inputs/data to match real behavior — do not add more mocks
- Delete flaky tests outright — do not weaken assertions to make them pass
- **HTTP response tests assert status code AND headers, not just body.** When testing a route, assert `response.status_code` AND any contract-meaningful headers (`X-Cache`, `Retry-After`, `WWW-Authenticate`, content-type, etc.) — not just the body shape. Weak assertions like `status != 200` or `X-Cache != "HIT"` miss real bugs (e.g. a `201` flattened to `200` on cache replay, or a header silently dropped). Pin the exact value.
- **Don't hardcode enum/constant copies in fixtures.** When a fixture needs an enum value (status, role, type code), import it from the schema/model module, OR add a one-line **equality** assertion (`assert set(FIXTURE_STATUSES) == {s.value for s in StatusEnum}`) that fails when the schema drifts EITHER WAY. A subset assertion (`<=`) only catches harness-has-invalid-value drift; it silently passes when the schema adds a value the harness doesn't cover (verified: a schema added `UNPLUGGED=13`, the harness still had `[1..12]`, every subset test stayed green, the harness silently stopped covering one production state). A standalone list of "looks right" values is a silent contract test for a contract that doesn't exist — and pydantic / DB constraints will reject the drift in production while every unit test passes.

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
