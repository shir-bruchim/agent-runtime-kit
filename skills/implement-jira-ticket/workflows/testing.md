# Workflow: TDD Testing for Jira Ticket Implementation

<required_reading>
Read the `tdd` and `api_integration_tests` principles in SKILL.md before starting.
For naming, env-var, and pagination patterns, also read `references/coding-conventions.md`.
</required_reading>

<process>

## Step 1: Run Existing Tests (Baseline)

Always run the full test suite BEFORE making any changes:

```bash
pytest --tb=short -q
```

Record the baseline: which tests pass, which fail. Failures before your changes indicate pre-existing issues (do not fix them unless your ticket requires it).

## Step 2: Set Up Test Env Vars in pytest.ini (NEVER in test files)

If your ticket adds new env vars (typically because `Settings` in `app/core/config.py` got new fields), add them to `pytest.ini`:

```ini
[pytest]
testpaths = ./tests
env =
    DB_SERVICE=test
    ...
    CUSTOMERS_DB_SERVICE=test
    CUSTOMERS_DB_NAME=test
```

**Rules:**
- `testpaths = ./tests` — point at the folder, never enumerate individual files.
- Never use `os.environ.setdefault(...)` at the top of test files — it's a code smell that signals env-var setup is in the wrong place.
- All-caps env names matching the `Settings` fields exactly (`case_sensitive = True`).

## Step 3: Write Unit Tests FIRST (Red Phase)

**Before writing any production code**, create tests for all planned functions:

1. Create or locate `tests/test_{module}.py`
2. Write test cases covering:
   - Happy path (expected input → expected output)
   - Edge cases: empty inputs, boundary values, None/null
   - Error conditions (invalid input raises correct exception)
3. Mock only at **system boundaries**: DB calls, HTTP requests, AWS SDK
4. Use real objects for all business logic
5. Follow the existing test patterns in the repo exactly

**For repos with chainable SQLAlchemy queries**, use a `_make_query_mock(...)` helper that records `.filter`, `.order_by`, `.offset`, `.limit` calls so tests can assert filter wiring:

```python
def _make_query_mock(returned_rows):
    query = MagicMock(name="query")
    query.filter.return_value = query
    query.order_by.return_value = query
    query.offset.return_value = query
    query.limit.return_value = query
    query.all.return_value = returned_rows
    query.first.return_value = returned_rows[0] if returned_rows else None
    return query
```

Run them — they must **FAIL**:

```bash
pytest tests/test_{module}.py -v
```

If any test passes, the assertion is wrong — fix it so it tests the actual new behavior.

## Step 4: Wire Localstack Integration Infrastructure (MANDATORY for API changes)

If the ticket changes ANY of these, integration test wiring is **required, not optional**:
- API endpoint behavior (new endpoints, changed responses, changed request schemas)
- Data flow between layers
- External integrations (queues, events, webhooks)
- DB state (new tables, changed records, new queries)

**The test file alone is not enough.** Wire the full stack — mirror what your sister service does (e.g., `ams-api-service/local_stack/`):

### 4a. New service in `local_stack/docker-compose.yml`

If the ticket touches a new DB, add the service:
```yaml
customers_postgres:
  image: 443793523615.dkr.ecr.eu-west-1.amazonaws.com/postgres:15-alpine
  environment:
    - POSTGRES_USER=postgres
    - POSTGRES_PASSWORD=postgres
    - POSTGRES_DB=customers_db
  ...
  healthcheck:
    test: [ "CMD-SHELL", "pg_isready -U postgres -d customers_db" ]
```

Add `CUSTOMERS_DB_*` env vars to BOTH the `web` and `test` services. Add a named volume.

### 4b. Add the schema package to test requirements

```text
# local_stack/config/requirements-test.txt
ams-db-schema==0.300.0
sensi-ams-db-python==0.300.0
sensi-postgres==0.63.0
sqlalchemy<2.0
```

The schema package ships DDL files; conftest reads them.

### 4c. `local_stack/conftest.py` — initializes schema, runs seed SQL

Mirror the sister-service pattern:

```python
from importlib.resources import files
import pytest
from sqlalchemy import create_engine, inspect, text
from sqlalchemy.orm import sessionmaker

schema_sql_root = files("ams_db_schema").joinpath("db")
seed_sql_path = Path(__file__).parent / "config" / "customers_fill_tables.sql"

@pytest.fixture(scope="session", autouse=True)
def init_customers_db():
    inspector = inspect(engine)
    if "devices" not in inspector.get_table_names(schema="public"):
        with session_maker() as session:
            for sql_path in sorted(schema_sql_root.rglob("*.sql")):
                _execute_sql_file(session, sql_path)
            session.commit()
    with session_maker() as session:
        _execute_sql_file(session, seed_sql_path)
        session.commit()
    yield
```

### 4d. Seed data goes in a separate SQL file

Don't embed INSERTs inside conftest. `local_stack/config/customers_fill_tables.sql`:
```sql
DELETE FROM devices WHERE customer_id IN (987, 42);
INSERT INTO devices (...) VALUES (...);
```

### 4e. Update `local_stack/config/Dockerfile-test`

Copy the new test files, conftest, and seed SQL:
```dockerfile
COPY ./local_stack/test_localstack_v2_devices.py .
COPY ./local_stack/conftest.py .
COPY ./local_stack/config/customers_fill_tables.sql ./config/customers_fill_tables.sql
```

### 4f. Update the test command

```yaml
command: sh -xc "./wait-for-port.sh -t 60 web:80 && pytest test_localstack.py test_localstack_v2_devices.py"
```

### 4g. Write the integration test

HTTP-level test against the running `web` container. Cover:
- Happy path
- Pagination round-trip via `next_page_token`
- Filter pass-through
- Each missing mandatory header → 422
- Missing `customer_id` → 422
- 404 on unknown / other-customer (IDOR)

These tests must **FAIL** at this point because production code doesn't exist yet.

## Step 5: Implement Production Code (Green Phase)

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
- Set up env vars in test files (use `pytest.ini`)
- Embed seed data inside conftest (use a separate `*_fill_tables.sql`)
- Change test expectations just to make them pass (unless the expectation was wrong)
- Create new fixtures if existing ones cover the need
- Mock more things to hide failures

## Step 6: Refactor (Refactor Phase)

With all tests green, improve code quality without changing behavior:
- Extract duplicated logic — especially page-token / filter resolution into a shared `pagination.py`
- Drop redundant qualifiers from method names if the module is already context-scoped
- Improve naming
- Simplify complex expressions

Re-run tests after each refactor:

```bash
pytest --tb=short -v
```

All tests must stay green throughout refactoring.

## Step 7: Final Full Run

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

**API changes make integration test infrastructure mandatory:**
- Changed endpoint → update integration tests
- Changed response schema → update integration tests
- Changed request schema → update integration tests
- New endpoint → add integration tests + compose service + conftest + seed SQL + Dockerfile-test
- Changed DB state → update integration tests
- New DB → new compose service, conftest schema init, seed SQL, env vars on web+test, schema package in requirements-test.txt

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

# Run localstack stack
cd local_stack && docker-compose up --build --abort-on-container-exit --exit-code-from test

# Check installed package version
pip show <package-name>

# Re-install dependencies (after package update)
pip install -r requirements.txt
pip install -r requirements-dev.txt
```

</quick_reference>