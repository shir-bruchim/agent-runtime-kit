# Workflow: Testing for Jira Ticket Implementation

<required_reading>
Read the `test_discipline` principle in SKILL.md before starting.
</required_reading>

<process>

## Step 1: Run Existing Tests First

Always run the full test suite BEFORE making any changes:

```bash
pytest --tb=short -q
```

Record the baseline: which tests pass, which fail. Failures before your changes indicate pre-existing issues (do not fix them unless your ticket requires it).

## Step 2: Run Tests After Implementation

After completing implementation, run again:

```bash
pytest --tb=short -v
```

If tests fail:
1. **Run pip install first** — a package update in the ticket may cause import failures
2. Read the failure output carefully — understand what actually failed
3. **Debug before fixing** — print actual return values before assuming the fix
4. Fix test **inputs/data**, not production code (unless production code is genuinely wrong)
5. Use **existing fixtures** from conftest — do not create new ones
6. Use **real objects** (metadata, models) — do not manually create values
7. Re-run and repeat until all pass

**Never:**
- Change production code just to make a test pass
- Create new fixtures if existing ones cover the need
- Mock more things to hide failures

## Step 3: Write Unit Tests for New Functions

For every new function or method created:

1. Create or locate `tests/test_{module}.py`
2. Write tests covering:
   - Happy path (expected input → expected output)
   - Edge cases: empty inputs, boundary values, None/null
   - Error conditions (invalid input raises correct exception)
3. Mock only at **system boundaries**: DB calls, HTTP requests, AWS SDK
4. Use real objects for all business logic

Follow the existing test patterns in the repo exactly.

## Step 4: Evaluate Integration Tests

Integration tests are needed when the implementation:
- Changes API endpoint behavior
- Modifies data flow between layers
- Affects external integrations (queues, events, webhooks)
- Changes user-facing behavior
- Modifies DB state

**Integration test requirements:**
- Verify DB state BEFORE the action (e.g., table is empty, record has status X)
- Perform the action
- Verify DB state AFTER the action (e.g., correct records inserted, status changed)

Before creating integration tests: get user approval (see SKILL.md approval gates).
Use `/localstack-integration` skill for implementation.

## Step 5: Final Full Run

```bash
pytest --tb=short -v
```

All tests must pass before declaring implementation complete.

</process>

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

# Check installed package version
pip show <package-name>

# Re-install dependencies (after package update)
pip install -r requirements.txt
pip install -r requirements-dev.txt
```

</quick_reference>