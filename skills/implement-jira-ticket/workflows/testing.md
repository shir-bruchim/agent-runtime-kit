# Workflow: TDD Testing for Jira Ticket Implementation

<required_reading>
Read the `tdd` and `api_integration_tests` principles in SKILL.md before starting.
</required_reading>

<process>

## Step 1: Run Existing Tests (Baseline)

Always run the full test suite BEFORE making any changes:

```bash
pytest --tb=short -q
```

Record the baseline: which tests pass, which fail. Failures before your changes indicate pre-existing issues (do not fix them unless your ticket requires it).

## Step 2: Write Unit Tests FIRST (Red Phase)

**Before writing any production code**, create tests for all planned functions:

1. Create or locate `tests/test_{module}.py`
2. Write test cases covering:
   - Happy path (expected input → expected output)
   - Edge cases: empty inputs, boundary values, None/null
   - Error conditions (invalid input raises correct exception)
3. Mock only at **system boundaries**: DB calls, HTTP requests, AWS SDK
4. Use real objects for all business logic
5. Follow the existing test patterns in the repo exactly

Run them — they must **FAIL**:

```bash
pytest tests/test_{module}.py -v
```

If any test passes, the assertion is wrong — fix it so it tests the actual new behavior.

## Step 3: Write Integration/Localstack Tests FIRST If API Changes (MANDATORY)

If the ticket changes ANY of these, writing integration tests is **required, not optional**:
- API endpoint behavior (new endpoints, changed responses, changed request schemas)
- Data flow between layers
- External integrations (queues, events, webhooks)
- DB state (new tables, changed records, new queries)

**Integration test requirements:**
- Verify DB state BEFORE the action (e.g., table is empty, record has status X)
- Perform the action
- Verify DB state AFTER the action (e.g., correct records inserted, status changed)
- Follow existing integration test patterns in the repo
- Use `/localstack-integration` skill for localstack-specific patterns

Run them — they must also **FAIL** at this point:

```bash
pytest tests/integration/ -v
```

## Step 4: Implement Production Code (Green Phase)

Now write the production code to make the failing tests pass. See `workflows/implement-ticket.md` Phase 5 for implementation details.

```bash
pytest --tb=short -v
```

If tests still fail:
1. **Run pip install first** — a package update in the ticket may cause import failures
2. Read the failure output carefully — understand what actually failed
3. Fix the **production code** to satisfy the tests (TDD contract)
4. If test expectation was genuinely wrong, fix the test — but prefer fixing code first
5. Use **existing fixtures** from conftest — do not create new ones
6. Use **real objects** (metadata, models) — do not manually create values
7. Re-run and repeat until all pass

**Never:**
- Skip the Red phase
- Change test expectations just to make them pass (unless the expectation was wrong)
- Create new fixtures if existing ones cover the need
- Mock more things to hide failures

## Step 5: Refactor (Refactor Phase)

With all tests green, improve code quality without changing behavior:
- Extract duplicated logic
- Improve naming
- Simplify complex expressions

Re-run tests after each refactor:

```bash
pytest --tb=short -v
```

All tests must stay green throughout refactoring.

## Step 6: Final Full Run

```bash
pytest --tb=short -v
```

All tests must pass before declaring implementation complete.

</process>

<tdd_summary>

**TDD flow in this skill:**
1. **Red** — Write tests first. They fail. Get user approval on test stubs.
2. **Green** — Implement production code. Tests pass. Get user approval on implementation.
3. **Refactor** — Clean up code. Tests still pass.

**API changes make integration tests mandatory:**
- Changed endpoint → update integration tests
- Changed response schema → update integration tests
- Changed request schema → update integration tests
- New endpoint → add integration tests
- Changed DB state → update integration tests

</tdd_summary>

<quick_reference>

```bash
# Run all tests
pytest

# Run with output on failures
pytest --tb=short -v

# Run specific module
pytest tests/test_mymodule.py -v

# Run specific test
pytest tests/test_mymodule.py::test_function_name -v

# Run integration tests only
pytest tests/integration/ -v

# Check installed package version
pip show <package-name>

# Re-install dependencies (after package update)
pip install -r requirements.txt
pip install -r requirements-dev.txt
```

</quick_reference>