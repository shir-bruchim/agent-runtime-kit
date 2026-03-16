# LocalStack Integration Testing

> Core patterns for integration test infrastructure management using LocalStack and related services.

## Objective

Comprehensive integration test management for integration test folders (commonly `local_stack/`, `integration_tests/`, `tests/integration/`, etc.). Handles the full lifecycle: improving existing tests, debugging failures, adding coverage, refactoring, and managing infrastructure.

**Universal Applicability**:
- Works with any integration test framework (pytest, unittest, jest, mocha, JUnit, etc.)
- Supports any infrastructure (LocalStack, databases, Redis, Kafka, Elasticsearch, mock HTTP services, etc.)
- Adapts to any project structure and naming conventions

## Discovery Workflow (Mandatory First Step)

Before making ANY changes, perform a full repository scan:

1. **Discover Integration Test Location**
   - Find integration test folder: `local_stack/`, `integration_tests/`, `tests/integration/`, `e2e/`, etc.
   - Use Glob to find all test files: `**/*test*.py`, `**/*spec*.js`, `**/test_*.py`, etc.
   - Identify test framework: pytest, unittest, jest, mocha, JUnit, etc.

2. **Scan Infrastructure Configuration**
   - Find Docker Compose file: `docker-compose.yaml`, `docker-compose.yml`, `compose.yaml`
   - Read all services, networks, volumes, health checks, environment variables
   - Find initialization scripts: `run.sh`, `init.sh`, `setup.sql`, `seed.js`, etc.
   - Map current infrastructure (AWS services via LocalStack, databases, message queues, mock services)

3. **Scan Integration Tests**
   - Read ALL test files in integration test folder
   - Identify test configuration: `conftest.py`, `jest.config.js`, `setupTests.js`, etc.
   - Understand fixtures, assertion helpers, cleanup strategies, data seeding

4. **Scan Application Code**
   - Find client/service code that interacts with infrastructure
   - Understand connection patterns (ORMs, SDK clients, HTTP clients)
   - Check for environment variable usage

5. **Build Service Behavior Map**
   - Document: "behavior -> services -> tests -> gaps"
   - Identify integration test coverage gaps
   - Map service dependencies and initialization order

## Test Improvement Operations

### Debugging Failing Tests

1. **Reproduce**: Run in isolation, run multiple times to check for flakiness
2. **Gather Evidence**: Read test code, check error/stack trace, add debug logging, inspect DB state
3. **Identify Root Cause**: Assertion mismatch, exception, timeout, race condition, environment issue
4. **Fix**: Update test logic, fix app code, add proper waits, improve isolation
5. **Verify**: Run fixed test 20+ times to confirm stability

### Fixing Flaky Tests

Common causes and fixes:

- **Race conditions**: Add proper waits for async operations (poll with timeout instead of fixed sleep)
- **Shared state**: Use unique identifiers per test (timestamp, UUID)
- **Test order dependency**: Each test creates its own data
- **Insufficient cleanup**: Add cleanup fixtures with `yield` and teardown

```python
# Replace fixed sleeps with polling
def wait_for_resource(check_fn, timeout=10):
    start = time.time()
    while time.time() - start < timeout:
        if check_fn():
            return True
        time.sleep(0.1)
    return False

# Use unique identifiers
test_key = f"test/{uuid.uuid4()}/file.txt"

# Proper cleanup fixture
@pytest.fixture(scope="function", autouse=True)
def cleanup_after_test():
    yield
    with session_maker() as session:
        session.query(TestModel).delete()
        session.commit()
```

### Adding Test Coverage

1. Run coverage report, review for untested scenarios
2. Prioritize by risk: core business logic > error handling > edge cases > secondary features
3. Design tests covering end-to-end flows with real services
4. Follow existing test patterns and conventions
5. Verify coverage improvement

### Optimizing Slow Tests

- Reduce test data to minimal needed
- Use session-scoped fixtures for expensive setup
- Replace `time.sleep()` with polling
- Batch database operations (bulk insert instead of one-at-a-time)

### Refactoring Tests

- Extract common setup into fixtures
- Create assertion helpers for complex verifications
- Break large tests into smaller focused tests
- Replace magic numbers with named constants

## Test Fixture Patterns

**Session-Scoped** (runs once for all tests):
```python
@pytest.fixture(scope="session", autouse=True)
def init_db():
    """Initialize database schema once per test session"""
    yield
```

**Function-Scoped** (runs per test for isolation):
```python
@pytest.fixture(scope="function")
def clean_bucket():
    bucket = 'test-bucket'
    yield bucket
    s3_client.delete_all_objects(bucket)
```

## Test Patterns

**Environment-based configuration** (no hardcoded values):
```python
HOST = os.getenv("HOST", "http://service:10000")
AWS_ENDPOINT = os.getenv("AWS_ENDPOINT_URL", "http://localstack:4566")
```

**Real services, not mocks** (the point of integration tests):
```python
# Good - real LocalStack service
secrets_client = boto3.client('secretsmanager', endpoint_url='http://localstack:4566')

# Bad - mocking defeats the purpose
with mock.patch('boto3.client'):  # Don't do this in integration tests
```

**Retry logic for eventually consistent operations**:
```python
def wait_for_resource(check_fn, timeout=30, interval=1):
    start = time.time()
    while time.time() - start < timeout:
        try:
            result = check_fn()
            if result:
                return result
        except Exception:
            pass
        time.sleep(interval)
    raise TimeoutError(f"Resource not ready within {timeout}s")
```

**Comprehensive cleanup in finally blocks**:
```python
@pytest.mark.asyncio
async def test_with_cleanup():
    resource_name = None
    try:
        resource_name = "test-resource"
        # ... test logic ...
    finally:
        if resource_name:
            try:
                delete_resource(resource_name)
            except:
                pass
```

**DB state verification (before and after)**:
```python
def test_action_modifies_db(db_session):
    # Verify BEFORE
    records_before = db_session.query(Model).filter_by(id=test_id).all()
    assert len(records_before) == 0

    # Perform action
    response = client.patch(f"/resource/{id}", json={"enabled": True})
    assert response.status_code == 200

    # Verify AFTER
    records_after = db_session.query(Model).filter_by(id=test_id).all()
    assert len(records_after) > 0
```

## Quality Standards

- Every integration test must assert REAL observable behavior
- Use real services (real DB, real cache, real LocalStack -- only mock external APIs outside your control)
- Tests must be deterministic and properly isolated
- No flaky tests -- use proper waits/retries for async operations
- Follow existing codebase patterns and conventions
- Include cleanup logic (fixtures or finally blocks)
- Test both happy path and error scenarios

## Troubleshooting

### LocalStack Service Fails to Start
- Check logs: `docker compose logs localstack`
- Check health: `curl http://localhost:4566/_localstack/health`
- Common: invalid auth token, insufficient memory, invalid SERVICES config, port conflict

### Flaky Integration Tests
- Add retry logic for async operations
- Use unique identifiers per test (timestamp, UUID)
- Add cleanup fixtures
- Check for shared state between tests

### Service Cannot Connect to LocalStack
- Use `http://localstack:4566` (not localhost) for container-to-container communication
- Ensure services are on the same Docker network
- Add `depends_on` with `condition: service_healthy`
- Set AWS credentials (any value works for LocalStack)

### Tests Pass Locally but Fail in CI
- Increase timeouts (CI is slower)
- Ensure all required env vars are set in CI
- Use unique identifiers to avoid parallel test conflicts
- Optimize resource usage for CI resource limits
