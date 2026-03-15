---
name: localstack-integration
description: Integration test management for LocalStack and test infrastructure. Use when working with integration tests, LocalStack AWS services, debugging test failures, adding test coverage, managing Docker Compose test infrastructure, or creating deterministic integration tests.
---

# Generic Integration Test Management Skill

> **Prerequisites**: For general test principles (independence, naming, pyramid, behavior-not-implementation), see `skills/testing/SKILL.md`. This skill focuses on integration test **infrastructure** management.

> **UNIVERSAL SKILL** - Use this across ALL your services without modification. Works with any tech stack, test framework, or infrastructure.

## objective

**GENERIC SKILL FOR ALL SERVICES** - This skill works across ANY project with integration tests, regardless of tech stack, domain, or infrastructure.

Comprehensive integration test management for integration test folders (commonly `local_stack/`, `integration_tests/`, `tests/integration/`, etc.). This skill handles the full lifecycle of integration tests: improving existing tests, debugging failures, adding coverage, refactoring, and managing infrastructure (LocalStack AWS services, databases, message queues, external resources, mock services).

**Universal Applicability**:
- Works with any integration test framework (pytest, unittest, jest, mocha, JUnit, etc.)
- Supports any infrastructure (LocalStack, databases, Redis, Kafka, Elasticsearch, mock HTTP services, etc.)
- Adapts to any project structure and naming conventions
- No service-specific assumptions - discovers everything from your codebase
- Use the same skill across all your services without modification

**Core Capabilities**:
- **Improve & Debug**: Fix failing tests, optimize slow tests, make tests more deterministic
- **Add Coverage**: Identify and fill integration test coverage gaps
- **Refactor**: Improve test structure, reduce duplication, enhance maintainability
- **Database Testing**: Enhance database integration tests (any DB: PostgreSQL, MySQL, MongoDB, etc.)
- **AWS Services** (when needed): Add/update/delete LocalStack AWS services (S3, SQS, Secrets Manager, DynamoDB, etc.)
- **External Resources** (when needed): Add/update databases, caches, message queues, mock HTTP services
- **Create Tests**: Design and implement deterministic, wide behavioral integration tests
- **Test Infrastructure**: Maintain Docker Compose, fixtures, helpers, and test utilities

## how_to_use_generically

**This skill is designed to work with ANY service without modification.**

### Key Principles:

1. **No Assumptions**: The skill makes zero assumptions about your project structure, naming conventions, or tech stack
2. **Discovery First**: Always starts by discovering your actual setup (test folder, Docker config, test framework, infrastructure)
3. **Adapts to You**: Works with your existing patterns, doesn't impose new ones
4. **Examples Only**: All examples in this skill (ams2db-lambda, PostgreSQL, etc.) are just illustrations - ignore them if not relevant

### What You Need:

- **Integration test folder**: Any name (`local_stack/`, `tests/integration/`, `e2e/`, etc.)
- **Docker Compose** (optional but common): For running test infrastructure
- **Test files**: Any framework (pytest, jest, unittest, mocha, JUnit, etc.)

### What Gets Discovered Automatically:

- Your test folder location and naming patterns
- Your test framework and conventions
- Your infrastructure (databases, queues, caches, AWS services, mock servers, etc.)
- Your Docker Compose setup (if exists)
- Your test fixtures and helpers
- Your application code that interacts with infrastructure

### How to Invoke:

Simply describe what you want in natural language. The skill will discover your setup and adapt:

```bash
# Works for ANY service
/localstack-integration fix-flaky-test
/localstack-integration add-test-coverage
/localstack-integration optimize-slow-tests
/localstack-integration debug-failing-test

# Infrastructure (if you have Docker Compose)
/localstack-integration add-database --db=redis
/localstack-integration add-aws-service --service=sqs
```

The skill will figure out the rest by reading your code.

## quick_start

**Invoke this skill when**:

**Test Improvement & Debugging**:
- Fixing failing integration tests
- Debugging flaky or intermittent test failures
- Optimizing slow tests
- Adding missing test coverage
- Refactoring test code for better maintainability
- Investigating database test issues (upserts, soft-deletion, queries)

**Infrastructure Management**:
- Adding a new AWS service to LocalStack (e.g., S3, DynamoDB, Lambda, CloudWatch)
- Adding external resources (Redis, Kafka, PostgreSQL, MongoDB)
- Creating integration tests that test cross-service workflows
- Updating LocalStack service configurations
- Debugging LocalStack service initialization issues
- Deleting unused services or resources

**How to invoke**:
```
# Test improvement operations
/localstack-integration improve-tests
/localstack-integration debug-test --test=test_soft_delete_integration.py::test_visits_deleted
/localstack-integration add-coverage --area="caregiver deletion"
/localstack-integration refactor-tests --file=test_localstack.py
/localstack-integration optimize-test --test=test_mix_wellsky_data_resources
/localstack-integration fix-flaky-test --test=test_visits_data_caregiver_unavailable

# Infrastructure operations (existing)
/localstack-integration add-aws-service --service=s3
/localstack-integration add-external-resource --resource=redis
/localstack-integration create-integration-test --flow="lambda-to-sqs"
/localstack-integration update-service --service=eks
/localstack-integration delete-service --service=cloudwatch
```

**Common use cases**:

**Test Improvement**:
1. "Fix the failing test_visits_deleted_when_not_in_scrape_window test"
2. "This test is flaky - make it more deterministic"
3. "Add integration test coverage for the deletion flow"
4. "Refactor test_localstack.py to reduce duplication"
5. "Why is test_mix_wellsky_data_resources so slow? Optimize it"
6. "Debug test_caregiver_unavailability_deletion - it fails intermittently"
7. "Create integration test for client deletion with all child tables"
8. "Add missing tests for edge cases in upsert logic"

**Infrastructure** (existing):
9. "Add S3 bucket support to LocalStack for file storage testing"
10. "Create integration test for end-to-end agency onboarding flow"
11. "Add Redis cache to LocalStack environment"
12. "Update EKS cluster configuration with new namespace"
13. "Delete unused SQS queues and clean up test artifacts"

## workflow

### Phase 0: Discovery & Understanding (MANDATORY)

**Before making ANY changes, always perform full repository scan to understand the project structure**:

1. **Discover Integration Test Location**
   - Find integration test folder: `local_stack/`, `integration_tests/`, `tests/integration/`, `e2e/`, etc.
   - Use Glob to find all test files: `**/*test*.py`, `**/*spec*.js`, `**/test_*.py`, etc.
   - Identify test framework: pytest, unittest, jest, mocha, JUnit, etc.

2. **Scan Infrastructure Configuration**
   - Find Docker Compose file: `docker-compose.yaml`, `docker-compose.yml`, `compose.yaml`, etc.
   - Read all services, networks, volumes, health checks, environment variables
   - Find initialization scripts: `run.sh`, `init.sh`, `setup.sql`, `seed.js`, etc.
   - Identify external config files: `.env`, `config/*.env`, `*.config.js`, etc.
   - Map current infrastructure:
     - **AWS services** (if using LocalStack): Check SERVICES environment variable
     - **Databases**: PostgreSQL, MySQL, MongoDB, Redis, Elasticsearch, etc.
     - **Message queues**: Kafka, RabbitMQ, SQS, etc.
     - **Mock services**: Mock HTTP servers, test doubles, stubs
     - **Other services**: Search engines, caches, file storage, etc.

3. **Scan Integration Tests**
   - Read ALL test files in integration test folder
   - Identify test configuration: `conftest.py`, `jest.config.js`, `setupTests.js`, etc.
   - Understand test patterns:
     - Fixtures/setup methods
     - Assertion helpers
     - Cleanup strategies
     - Test isolation mechanisms
     - Data seeding approaches
   - Map test coverage: what's tested, what's missing

4. **Scan Application Code**
   - Find client/service code that interacts with infrastructure
   - Common locations: `app/clients/`, `src/services/`, `lib/`, `pkg/`, etc.
   - Understand how application connects to:
     - Databases (connection strings, ORMs, query builders)
     - External services (HTTP clients, SDK clients)
     - Message queues (producers, consumers)
     - Caches (Redis, Memcached)
   - Check for environment variable usage and configuration patterns

5. **Build Service Behavior Map**
   - Document: "behavior → services → tests → gaps"
   - Identify integration test coverage gaps
   - Find conditionally untestable unit code that needs integration coverage
   - Map service dependencies and initialization order
   - Understand data flow through the system

6. **Fetch Latest Documentation** (if adding new infrastructure)
   - For LocalStack AWS services: https://docs.localstack.cloud/aws/{service}/
   - For databases: Official docs for PostgreSQL, MySQL, MongoDB, etc.
   - For message queues: Kafka, RabbitMQ, SQS docs
   - For Docker: https://docs.docker.com/compose/
   - For test frameworks: pytest, jest, unittest, etc.

### Phase 1: Single Clarifying Round (MAX ONCE)

After full scan, if needed, ask up to 10 blocking questions with:

**Question Format**:
- **Evidence**: File paths + code snippets showing what you found
- **Why it matters**: What decision this changes or blocks
- **Hypothesis**: Your default assumption if no answer provided

**Example Questions**:
1. **Evidence**: `docker-compose.yaml:15` shows `postgres:14` but application code imports `pymongo`
   **Why it matters**: Need to understand if MongoDB is needed for integration tests or if it's for different service
   **Hypothesis**: Will check if MongoDB is production-only or needs test infrastructure

2. **Evidence**: Test file `test_orders.py:45` creates 1000 test records but test only checks 3
   **Why it matters**: Determines if large dataset is necessary (performance test?) or can be reduced (speed up test)
   **Hypothesis**: Will reduce to minimal dataset unless explicitly testing scale

3. **Evidence**: Three test files use different database seeding approaches (SQL scripts, ORM fixtures, raw inserts)
   **Why it matters**: Inconsistency makes tests harder to maintain and understand
   **Hypothesis**: Will standardize on most common/appropriate approach for this project

**If no blocking questions**: Proceed immediately to implementation.

### Phase 2: Implementation

---

## TEST IMPROVEMENT OPERATIONS

### Operation: improve_existing_tests

**When to use**: General test improvement - fixing failures, adding coverage, refactoring, or optimizing

> **Note**: These steps work for ANY project. Command examples use `pytest` and `docker-compose`, but the approach applies to jest/mocha/JUnit and any container orchestration.

**Steps**:

1. **Analyze Current Test State**
   - Run all tests in your test runner:
     - `docker compose exec test pytest integration_tests/ -v` (Python/pytest)
     - `docker compose exec test npm test` (Node/jest)
     - `docker compose exec test mvn test` (Java/JUnit)
     - Or whatever test command your project uses
   - Identify failures, warnings, slow tests, flaky tests
   - Check test coverage (if applicable):
     - `pytest --cov=app --cov-report=html` (Python)
     - `npm test -- --coverage` (Node)
     - `mvn test jacoco:report` (Java)
   - Review test execution time to find slow tests

2. **Categorize Issues**
   - **Failures**: Tests that consistently fail
   - **Flaky**: Tests that pass/fail intermittently
   - **Slow**: Tests taking >5 seconds
   - **Coverage gaps**: Missing test scenarios
   - **Code quality**: Duplicated code, unclear assertions, poor structure

3. **Prioritize Improvements**
   - Fix failures first (blocking)
   - Fix flaky tests second (reliability)
   - Add critical missing coverage third (risk)
   - Refactor for maintainability fourth (quality)
   - Optimize slow tests fifth (performance)

4. **Apply Improvements Systematically**
   - Fix one category at a time
   - Run tests after each change to verify
   - Document what was fixed and why

**Example workflow**:
```bash
# Step 1: Run tests and identify issues
docker compose exec test pytest local_stack/ -v --tb=short

# Step 2: Fix identified issues
# (edit test files)

# Step 3: Verify fixes
docker compose exec test pytest local_stack/ -v

# Step 4: Check coverage
docker compose exec test pytest local_stack/ --cov=app --cov-report=term-missing
```

### Operation: debug_failing_test

**When to use**: A specific test is failing and needs investigation

**Steps**:

1. **Reproduce the Failure**
   - Run the failing test in isolation: `pytest local_stack/test_file.py::test_name -v -s`
   - Run multiple times to check if it's flaky: `pytest --count=10`
   - Check if it fails in CI but passes locally (environment differences)

2. **Gather Evidence**
   - Read test code and understand what it's testing
   - Check error message and stack trace
   - Add debug logging: `logger.debug()` statements
   - Inspect database state before/after test
   - Check Docker logs: `docker compose logs postgres`

3. **Identify Root Cause**
   - **Assertion failure**: Expected vs actual mismatch
   - **Exception**: Code bug, missing data, wrong assumptions
   - **Timeout**: Slow operations, missing waits for async ops
   - **Race condition**: Test order dependency, shared state
   - **Environment issue**: Missing data, wrong configuration

4. **Fix the Issue**
   - Update test logic if test is wrong
   - Fix application code if code is wrong
   - Add proper waits if timing issue
   - Improve test isolation if race condition
   - Update test data/fixtures if data issue

5. **Verify Fix**
   - Run fixed test multiple times: `pytest --count=20`
   - Run all related tests to ensure no regression
   - Check test in CI environment

**Example: Debugging soft-deletion test**:
```python
# Problem: test_visits_deleted_when_not_in_scrape_window fails intermittently

# Step 1: Add debug logging
import logging
logger = logging.getLogger(__name__)

def test_visits_deleted_when_not_in_scrape_window():
    # ... setup ...

    logger.debug(f"Before processing: visits in DB = {count_visits()}")
    handler.handle()
    logger.debug(f"After processing: visits in DB = {count_visits()}")

    # ... assertions ...

# Step 2: Run with debug output
# pytest local_stack/test_soft_delete_integration.py::test_visits_deleted -v -s

# Step 3: Identify issue - timing problem with fetch_timestamp
# Fix: Ensure fetch_timestamp is set AFTER inserting test data
scrape_timestamp = datetime.now(timezone.utc).replace(tzinfo=None)
# Insert test visits with older updated_at
# Then process with scrape_timestamp
```

### Operation: add_test_coverage

**When to use**: Identifying and filling integration test coverage gaps

**Steps**:

1. **Identify Coverage Gaps**
   - Run coverage report: `pytest --cov=app --cov-report=html`
   - Review CLAUDE.md for untested scenarios
   - Check application code for conditionally untestable unit code paths
   - Review recent code changes for new features without tests

2. **Prioritize Gaps by Risk**
   - **Critical**: Core business logic (upserts, soft-deletion, validation)
   - **High**: Error handling paths, edge cases
   - **Medium**: Secondary features, less common paths
   - **Low**: Trivial code, already covered by unit tests

3. **Design Integration Tests**
   - Identify the end-to-end flow to test
   - Determine necessary test data and fixtures
   - Plan assertions that verify observable behavior
   - Consider both happy path and error scenarios

4. **Implement Tests**
   - Follow existing test patterns and conventions
   - Use real services (PostgreSQL, not mocked)
   - Ensure proper test isolation
   - Add cleanup logic

5. **Verify Coverage Improvement**
   - Run coverage again to verify increase
   - Ensure new tests pass consistently

**Example: Adding coverage for double night shift scenario**:
```python
# Gap identified: No test for visits spanning midnight with same shift
# Risk: High - complex visit_date calculation logic

def test_double_night_shift_check_in():
    """
    Test visits spanning midnight with same shift.

    Scenario:
    - Shift spans 2025-11-15 20:00 to 2025-11-16 08:00
    - Two check-ins: one before midnight, one after midnight
    - Both should update same visit (same shift_id, same visit_date)
    """
    fill_tables("double_night_shift_check_in_db.sql")

    # Process visits data with two visits for same shift
    client_ref_id = load_message_data_and_process('double_night_shift_check_in_data.json')
    assert client_ref_id is not None

    with postgres.PostgresSessionMaker() as session:
        # Should have only 1 visit (second updated first)
        visits = session.query(db_models.AmsVisit).filter_by(
            shift_id=50323,
            visit_date=date(2025, 11, 15)  # Date from start_time
        ).all()
        assert len(visits) == 1

        # Verify it has latest data
        visit = visits[0]
        assert visit.end_time == datetime(2025, 11, 16, 8, 0)
        assert visit.status == 1
```

### Operation: refactor_tests

**When to use**: Test code has duplication, unclear structure, or maintainability issues

**Steps**:

1. **Identify Refactoring Opportunities**
   - Duplicated test setup code
   - Repeated assertion patterns
   - Long, complex test functions
   - Magic numbers or hardcoded values
   - Unclear test names or purposes

2. **Plan Refactoring**
   - Extract common setup into fixtures
   - Create assertion helpers for complex verifications
   - Break large tests into smaller, focused tests
   - Use constants for magic values
   - Improve test names to describe behavior

3. **Refactor Incrementally**
   - Make one change at a time
   - Run tests after each change
   - Ensure behavior doesn't change (tests still pass)

4. **Common Refactoring Patterns**:

   **Pattern 1: Extract fixture for common setup**
   ```python
   # Before: Duplicated in every test
   def test_one():
       fill_tables("fill_tables.sql")
       caregiver = load_message_data_and_process('caregiver_data1.json')
       # ... test logic ...

   def test_two():
       fill_tables("fill_tables.sql")
       caregiver = load_message_data_and_process('caregiver_data1.json')
       # ... test logic ...

   # After: Extract to fixture
   @pytest.fixture(scope="function")
   def base_test_data():
       fill_tables("fill_tables.sql")
       return load_message_data_and_process('caregiver_data1.json')

   def test_one(base_test_data):
       caregiver = base_test_data
       # ... test logic ...

   def test_two(base_test_data):
       caregiver = base_test_data
       # ... test logic ...
   ```

   **Pattern 2: Create assertion helper**
   ```python
   # Before: Repeated complex assertions
   def test_one():
       assert visit.status == 1
       assert visit.client_id == client_id
       assert visit.caregiver_id == caregiver_id
       assert visit.start_time == expected_start
       assert visit.end_time == expected_end

   # After: Assertion helper
   def assert_visit_matches(visit, expected):
       """Helper to verify visit matches expected values"""
       assert visit.status == 1, f"Expected status 1, got {visit.status}"
       assert visit.client_id == expected.client_id
       assert visit.caregiver_id == expected.caregiver_id
       assert visit.start_time == expected.start_time
       assert visit.end_time == expected.end_time

   def test_one():
       assert_visit_matches(visit, expected_values)
   ```

   **Pattern 3: Break large test into focused tests**
   ```python
   # Before: One large test testing multiple things
   def test_process_message():
       # Add caregiver
       caregiver_id = load_message_data_and_process('caregiver_data1.json')
       assert caregiver_id is not None

       # Add client
       client_id = load_message_data_and_process('client_data1.json')
       assert client_id is not None

       # Update caregiver
       caregiver_id2 = load_message_data_and_process('caregiver_data2.json')
       # ... many more operations ...

   # After: Separate focused tests
   def test_process_caregiver_message():
       caregiver_id = load_message_data_and_process('caregiver_data1.json')
       assert_reference_id_in_db(caregiver_id, db_models.AmsCaregiver, 54, 987)

   def test_process_client_message():
       client_id = load_message_data_and_process('client_data1.json')
       assert_reference_id_in_db(client_id, db_models.AmsClient, 1, 987)

   def test_upsert_existing_caregiver():
       load_message_data_and_process('caregiver_data1.json')  # Initial
       caregiver_id = load_message_data_and_process('caregiver_data2.json')  # Update
       # Verify update worked
   ```

### Operation: optimize_slow_test

**When to use**: A test takes too long to execute (>5 seconds)

**Steps**:

1. **Profile the Test**
   - Run with timing: `pytest --durations=10`
   - Add timing statements in test code
   - Identify bottlenecks: database queries, API calls, sleep statements

2. **Common Slow Test Causes**:
   - **Unnecessary data**: Loading too much test data
   - **Excessive queries**: N+1 query problems
   - **Synchronous sleeps**: `time.sleep()` waiting for async operations
   - **Large data processing**: Processing large datasets
   - **Repeated setup**: Setup that could be session-scoped

3. **Optimization Strategies**:

   **Strategy 1: Reduce test data**
   ```python
   # Before: Loading 100 visits for test that only needs 3
   fill_tables("fill_tables_with_100_visits.sql")

   # After: Load minimal data
   fill_tables("fill_tables_with_3_visits.sql")
   ```

   **Strategy 2: Use session-scoped fixtures**
   ```python
   # Before: Function-scoped (runs for EVERY test)
   @pytest.fixture(scope="function")
   def database_setup():
       fill_tables("large_dataset.sql")
       yield

   # After: Session-scoped (runs ONCE for all tests)
   @pytest.fixture(scope="session")
   def database_setup():
       fill_tables("large_dataset.sql")
       yield
   ```

   **Strategy 3: Replace sleep with polling**
   ```python
   # Before: Fixed sleep (worst case: 10s, best case: still 10s)
   time.sleep(10)  # Wait for resource to be ready

   # After: Poll with timeout (worst case: 10s, best case: <1s)
   def wait_for_resource(check_fn, timeout=10):
       start = time.time()
       while time.time() - start < timeout:
           if check_fn():
               return True
           time.sleep(0.1)
       return False

   wait_for_resource(lambda: resource.is_ready())
   ```

   **Strategy 4: Batch database operations**
   ```python
   # Before: Inserting one at a time (slow)
   for item in items:
       session.add(db_models.AmsVisit(**item))
       session.commit()  # Commit each one

   # After: Bulk insert (fast)
   session.bulk_insert_mappings(db_models.AmsVisit, items)
   session.commit()  # Commit once
   ```

4. **Verify Optimization**
   - Run test before and after with `--durations=1`
   - Ensure test still passes with same coverage
   - Verify performance improvement (target: <2 seconds for most tests)

### Operation: fix_flaky_test

**When to use**: A test passes and fails intermittently (non-deterministic)

**Steps**:

1. **Confirm Flakiness**
   - Run test 20+ times: `pytest --count=20`
   - Note failure rate and failure patterns
   - Check if failures cluster (e.g., fail first 3, pass rest)

2. **Identify Flakiness Causes**:
   - **Race conditions**: Tests run in parallel, shared state
   - **Timing issues**: Async operations without proper waits
   - **Test order dependency**: Test relies on state from previous test
   - **External service timing**: Database, network calls with variable latency
   - **Random data**: Using random values that occasionally cause failures
   - **Resource cleanup**: Previous test didn't clean up properly

3. **Fix Strategies**:

   **Fix 1: Add proper waits for async operations**
   ```python
   # Before: Assumes instant
   handler.handle()
   visit = session.query(AmsVisit).first()  # Might not exist yet

   # After: Poll for readiness
   handler.handle()
   visit = None
   for _ in range(50):  # Retry up to 5 seconds
       visit = session.query(AmsVisit).first()
       if visit:
           break
       time.sleep(0.1)
   assert visit is not None, "Visit not created within 5 seconds"
   ```

   **Fix 2: Use unique identifiers**
   ```python
   # Before: Hardcoded IDs (conflict when tests run in parallel)
   customer_id = 9999

   # After: Unique per test run
   import time
   customer_id = int(time.time()) % 100000

   # Or use UUID
   import uuid
   test_key = f"test/{uuid.uuid4()}/file.txt"
   ```

   **Fix 3: Improve test isolation**
   ```python
   # Before: Tests share database state
   def test_one():
       caregiver = create_caregiver(id=1)
       # ... test ...

   def test_two():
       caregiver = get_caregiver(id=1)  # Assumes test_one ran first!
       # ... test ...

   # After: Each test creates its own data
   def test_one():
       caregiver = create_caregiver(id=generate_unique_id())
       # ... test with this caregiver ...

   def test_two():
       caregiver = create_caregiver(id=generate_unique_id())
       # ... test with this caregiver ...
   ```

   **Fix 4: Add proper cleanup**
   ```python
   # Before: No cleanup (affects next test)
   def test_one():
       create_many_records()
       # Test doesn't clean up

   # After: Cleanup in fixture
   @pytest.fixture(scope="function", autouse=True)
   def cleanup_after_test():
       yield
       # Clean up after each test
       with session_maker() as session:
           session.query(TestModel).delete()
           session.commit()
   ```

4. **Verify Fix**
   - Run test 50+ times: `pytest --count=50`
   - Should pass 100% of the time
   - Check test time doesn't increase significantly

---

## INFRASTRUCTURE OPERATIONS (EXISTING)

#### Operation: add_aws_service

**When to use**: Adding new AWS service to LocalStack (S3, SQS, SNS, Lambda, DynamoDB, CloudWatch, RDS, etc.)

> **Note**: This operation is ONLY for LocalStack AWS services. If your service doesn't use LocalStack, skip this section.
> For other infrastructure (Redis, Kafka, PostgreSQL, etc.), use `add_external_resource` instead.

**Steps**:

1. **Fetch Latest Documentation** (MANDATORY FIRST STEP)
   ```
   ALWAYS use WebFetch tool to fetch the LATEST LocalStack Pro documentation:
   - Main docs: https://docs.localstack.cloud/aws/{service}/
   - Feature coverage: https://docs.localstack.cloud/getting-started/feature-coverage/

   CRITICAL: Always fetch fresh - LocalStack Pro updates frequently!

   Extract:
   - Pro vs Community features
   - Service-specific environment variables
   - Initialization requirements
   - Known limitations
   - Example configuration
   - Latest API changes and deprecations
   ```

2. **Update docker-compose.yaml**
   - Add service name to `SERVICES` environment variable (line 8)
   - Add any service-specific environment variables required
   - Example:
     ```yaml
     environment:
       - SERVICES=secretsmanager,eks,s3,sqs
       - S3_SKIP_SIGNATURE_VALIDATION=1  # S3-specific
     ```

3. **Create Initialization Script** (if needed)
   - Create `local_stack/init-scripts/{service}.sh` or add to `local_stack/run.sh`
   - Use `awslocal` CLI for service initialization
   - Handle idempotency (script should work on restart with persistence)
   - Example S3 initialization:
     ```bash
     awslocal s3api create-bucket \
       --bucket test-bucket \
       --region us-east-1 || true
     ```

4. **Update Health Check** (if critical for startup)
   - Add service verification to docker-compose.yaml healthcheck (lines 30-38)
   - Example:
     ```yaml
     healthcheck:
       test: >
         bash -c '
         awslocal s3api head-bucket --bucket test-bucket &&
         awslocal secretsmanager describe-secret --secret-id test/ams/...
         '
     ```

5. **Create Service Client** (if needed)
   - Add client in `app/clients/{service}_client.py`
   - Use boto3 with endpoint_url from AWS_ENDPOINT_URL environment variable
   - Example:
     ```python
     import boto3
     import os

     s3_client = boto3.client(
         's3',
         endpoint_url=os.getenv('AWS_ENDPOINT_URL', 'http://localhost:4566'),
         region_name='us-east-1'
     )
     ```

6. **Create Integration Test**
   - Create `local_stack/test_{service}.py` following existing patterns
   - Use real LocalStack service (not mocked)
   - Test service behavior and cross-service interactions
   - Include cleanup in fixtures or test teardown
   - Example test structure:
     ```python
     @pytest.mark.asyncio
     async def test_s3_upload_and_retrieval():
         # Test actual S3 behavior with LocalStack
         s3_client.put_object(Bucket='test-bucket', Key='test.txt', Body=b'content')
         response = s3_client.get_object(Bucket='test-bucket', Key='test.txt')
         assert response['Body'].read() == b'content'
     ```

7. **Update Documentation**
   - Add service to relevant documentation files
   - Include LocalStack docs URL in comments: `# https://docs.localstack.cloud/aws/{service}/`

**Example: Adding S3 Service**
```yaml
# local_stack/docker-compose.yaml
environment:
  - SERVICES=secretsmanager,eks,s3
  - S3_SKIP_SIGNATURE_VALIDATION=1  # Allow unsigned requests for testing
```

```bash
# local_stack/run.sh (append)
echo "Creating S3 test bucket..."
awslocal s3api create-bucket \
  --bucket test-agency-files \
  --region us-east-1 || true
```

```python
# local_stack/test_s3_integration.py
import pytest
import boto3
import os

@pytest.fixture(scope="session")
def s3_client():
    return boto3.client(
        's3',
        endpoint_url=os.getenv('AWS_ENDPOINT_URL', 'http://localstack:4566'),
        region_name='us-east-1'
    )

@pytest.mark.asyncio
async def test_s3_file_upload_and_download(s3_client):
    """Test S3 file upload and download workflow"""
    bucket = 'test-agency-files'
    key = 'test/document.txt'
    content = b'Test document content'

    # Upload file
    s3_client.put_object(Bucket=bucket, Key=key, Body=content)

    # Download and verify
    response = s3_client.get_object(Bucket=bucket, Key=key)
    assert response['Body'].read() == content

    # Cleanup
    s3_client.delete_object(Bucket=bucket, Key=key)
```

#### Operation: add_external_resource

**When to use**: Adding external services like Redis, Kafka, MongoDB, Elasticsearch, RabbitMQ, mock HTTP services, or ANY other infrastructure your tests need

> **Universal Operation**: This works for ANY external service. Examples show Redis, but apply same approach for:
> - Databases: PostgreSQL, MySQL, MongoDB, Cassandra, etc.
> - Caches: Redis, Memcached
> - Message queues: Kafka, RabbitMQ, ActiveMQ, SQS (real, not LocalStack)
> - Search: Elasticsearch, Solr
> - Mock services: WireMock, MockServer, custom HTTP mocks
> - Any other Docker-compatible service

**Steps**:

1. **Add Service to docker-compose.yaml**
   - Create new service definition with proper image and configuration
   - Configure networking (use `localstack_nw` network)
   - Set up volume mounts for persistence or initialization scripts
   - Example Redis:
     ```yaml
     redis:
       image: redis:7-alpine
       ports:
         - "6379:6379"
       networks:
         - localstack_nw
       healthcheck:
         test: ["CMD", "redis-cli", "ping"]
         interval: 10s
         timeout: 5s
         retries: 5
     ```

2. **Create Initialization Script** (if needed)
   - For databases: create schema SQL files in `local_stack/config/`
   - For message queues: create topics/queues setup script
   - Mount initialization scripts via volumes
   - Example PostgreSQL init:
     ```yaml
     volumes:
       - ./config/01_create_redis_config.sql:/docker-entrypoint-initdb.d/01_init.sql
     ```

3. **Configure Service Discovery**
   - Use Docker Compose service names for DNS resolution
   - Add environment variables to dependent services
   - Example:
     ```yaml
     ams-api-service:
       environment:
         - REDIS_HOST=redis
         - REDIS_PORT=6379
     ```

4. **Add Health Check**
   - Ensure service is healthy before dependent services start
   - Use `depends_on` with `condition: service_healthy`
   - Example:
     ```yaml
     ams-api-service:
       depends_on:
         redis:
           condition: service_healthy
     ```

5. **Create Resource Client/Connection**
   - Add client library to requirements
   - Create connection in application code or test fixtures
   - Example Redis fixture:
     ```python
     @pytest.fixture(scope="session")
     def redis_client():
         import redis
         client = redis.Redis(host='redis', port=6379, decode_responses=True)
         yield client
         client.flushall()  # Cleanup
     ```

6. **Create Integration Test**
   - Test resource behavior and interaction with application
   - Ensure proper cleanup between tests
   - Example:
     ```python
     @pytest.mark.asyncio
     async def test_redis_caching(redis_client):
         redis_client.set('test_key', 'test_value', ex=60)
         assert redis_client.get('test_key') == 'test_value'
     ```

**Example: Adding Redis Cache**
```yaml
# local_stack/docker-compose.yaml
redis:
  image: redis:7-alpine
  ports:
    - "6379:6379"
  networks:
    - localstack_nw
  healthcheck:
    test: ["CMD", "redis-cli", "ping"]
    interval: 10s
    timeout: 5s
    retries: 5
    start_period: 5s

ams-api-service:
  environment:
    - REDIS_HOST=redis
    - REDIS_PORT=6379
  depends_on:
    redis:
      condition: service_healthy
```

```python
# local_stack/conftest.py (add fixture)
@pytest.fixture(scope="session")
def redis_client():
    import redis
    client = redis.Redis(host='redis', port=6379, decode_responses=True)
    yield client
    client.flushall()
```

```python
# local_stack/test_cache_integration.py
@pytest.mark.asyncio
async def test_agency_caching_flow(redis_client, api_client):
    """Test that agency data is properly cached in Redis"""
    # First call - should hit API and cache
    agency = api_client.get_agency_by_id(agency_id=1, customer_id=987)
    cache_key = f"agency:1:987"

    # Verify cached in Redis
    cached_data = redis_client.get(cache_key)
    assert cached_data is not None

    # Second call - should hit cache (verify by checking mock call counts)
    agency2 = api_client.get_agency_by_id(agency_id=1, customer_id=987)
    assert agency.id == agency2.id
```

#### Operation: create_integration_test

**When to use**: Creating wide behavioral tests that test cross-service interactions and end-to-end workflows

**Steps**:

1. **Identify Test Scenario**
   - Define the behavioral flow to test (e.g., "Agency onboarding creates secrets, updates DB, creates cronjob")
   - Identify all services involved in the flow
   - Determine assertions that verify real observable behavior
   - Map conditionally untestable unit code paths that need coverage

2. **Understand Service Interactions**
   - Read application code to understand service call chains
   - Identify data flow between services (e.g., API → DB → K8s → Secrets Manager)
   - Check for async operations or eventual consistency
   - Plan for proper waiting/polling mechanisms

3. **Create Test File**
   - Follow naming convention: `local_stack/test_{domain}.py`
   - Import existing fixtures from conftest.py
   - Use pytest.mark.asyncio for async tests
   - Structure:
     ```python
     import pytest
     from sensi_ams_api_client import Configuration, ApiClient, AgenciesApi

     @pytest.mark.asyncio
     async def test_end_to_end_flow():
         # Setup
         # Execute flow
         # Assert real behavior
         # Cleanup
     ```

4. **Use Real LocalStack Services**
   - NO MOCKING of LocalStack services (use real S3, SQS, Secrets Manager, etc.)
   - Only mock external HTTP APIs outside LocalStack
   - Use real boto3 clients pointing to LocalStack endpoint
   - Example:
     ```python
     # Good - Real LocalStack service
     secrets_client = boto3.client('secretsmanager', endpoint_url='http://localstack:4566')

     # Bad - Mocking LocalStack
     with mock.patch('boto3.client'):  # Don't do this
     ```

5. **Ensure Test Isolation**
   - Clean up resources created during test
   - Use unique identifiers for test data (e.g., timestamp, UUID)
   - Reset state between tests using fixtures
   - Example cleanup:
     ```python
     @pytest.fixture
     def cleanup_s3_bucket(s3_client):
         yield
         # Cleanup after test
         response = s3_client.list_objects_v2(Bucket='test-bucket')
         for obj in response.get('Contents', []):
             s3_client.delete_object(Bucket='test-bucket', Key=obj['Key'])
     ```

6. **Test Happy Path and Error Scenarios**
   - Test successful flow (happy path)
   - Test error conditions (network failures, invalid data, permission errors)
   - Test edge cases (empty data, large payloads, concurrent operations)
   - Example:
     ```python
     @pytest.mark.asyncio
     async def test_agency_creation_with_invalid_config():
         """Test error handling when agency config is invalid"""
         with pytest.raises(ValidationException):
             api_instance.create_agency(agency_create=invalid_agency_data)
     ```

7. **Handle Async Operations**
   - Use proper waiting mechanisms for eventually consistent operations
   - Implement retry logic with timeout
   - Example:
     ```python
     import time

     def wait_for_cronjob_creation(k8s_client, name, timeout=30):
         start = time.time()
         while time.time() - start < timeout:
             try:
                 cronjob = k8s_client.batch.read_namespaced_cron_job(name, 'default')
                 return cronjob
             except ApiException as e:
                 if e.status == 404:
                     time.sleep(1)
                     continue
                 raise
         raise TimeoutError(f"CronJob {name} not created within {timeout}s")
     ```

8. **Write Clear Assertions**
   - Assert observable behavior, not implementation details
   - Use descriptive assertion messages
   - Example:
     ```python
     # Good - Observable behavior
     assert result.status == "ok", "Health check should return ok status"

     # Bad - Implementation detail
     assert result._internal_state == "ready"  # Don't assert private attributes
     ```

**Example: End-to-End Agency Onboarding Integration Test**
```python
# local_stack/test_agency_onboarding_e2e.py
import pytest
import boto3
import os
from kubernetes import client
from sensi_ams_api_client import Configuration, ApiClient, AgenciesApi

HOST = os.getenv("HOST", "http://ams-api-service:10000")
API_KEY = os.getenv("API_KEY")

@pytest.fixture(scope="function")
def secrets_manager_client():
    return boto3.client(
        'secretsmanager',
        endpoint_url=os.getenv('AWS_ENDPOINT_URL', 'http://localstack:4566'),
        region_name='us-east-1'
    )

@pytest.fixture(scope="function")
def k8s_client():
    from kubernetes import config
    config.load_kube_config(config_file=os.getenv("KUBECONFIG"))
    return client.BatchV1Api()

@pytest.mark.asyncio
async def test_agency_onboarding_creates_secrets_and_cronjob(
    secrets_manager_client,
    k8s_client
):
    """
    Test end-to-end agency onboarding flow:
    1. Create agency via API
    2. Update agency with config (should create secret in AWS Secrets Manager)
    3. Enable data fetch (should create K8s CronJob)
    4. Verify all resources created correctly
    """
    configuration = Configuration(host=HOST, access_token=API_KEY)

    # Step 1: Create agency
    with ApiClient(configuration) as api_client:
        api_instance = AgenciesApi(api_client)
        new_agency = api_instance.create_agency(
            agency_create={
                "customer_id": 9999,
                "data_fetch_enabled": False,
            },
            x_user_id=55555,
            x_request_id="test-e2e-onboarding",
            x_client_name="integration-test"
        )

    assert new_agency.id is not None
    agency_id = new_agency.id
    customer_id = new_agency.customer_id

    # Step 2: Update agency with WellSky config
    with ApiClient(configuration) as api_client:
        api_instance = AgenciesApi(api_client)
        updated_agency = api_instance.update_agency(
            agency_id=agency_id,
            customer_id=customer_id,
            agency_update={
                "company": 2,  # WellSky
                "data_source": 2,  # Scrapper
                "config": {
                    "base_url": "http://mock-wellsky:10010/9999/",
                    "username": "test_user_9999",
                    "password": "test_pass_9999"
                }
            },
            x_user_id=55555,
            x_request_id="test-e2e-onboarding",
            x_client_name="integration-test"
        )

    assert updated_agency.ams_id is not None
    ams_id = updated_agency.ams_id

    # Verify secret created in Secrets Manager
    secret_name = f"test/ams/wellsky/scrapper_configs/agency/{ams_id}"
    try:
        secret = secrets_manager_client.describe_secret(SecretId=secret_name)
        assert secret['Name'] == secret_name

        # Verify secret content
        secret_value = secrets_manager_client.get_secret_value(SecretId=secret_name)
        import json
        secret_data = json.loads(secret_value['SecretString'])
        assert secret_data['base_url'] == "http://mock-wellsky:10010/9999/"
        assert secret_data['username'] == "test_user_9999"
        assert 'password' in secret_data
    except Exception as e:
        pytest.fail(f"Secret not found or invalid: {e}")

    # Step 3: Enable data fetch (should create cronjob)
    with ApiClient(configuration) as api_client:
        api_instance = AgenciesApi(api_client)
        enabled_agency = api_instance.update_agency(
            agency_id=agency_id,
            customer_id=customer_id,
            agency_update={"data_fetch_enabled": True},
            x_user_id=55555,
            x_request_id="test-e2e-onboarding",
            x_client_name="integration-test"
        )

    assert enabled_agency.data_fetch_enabled is True

    # Verify K8s CronJob created
    cronjob_name = f"wellsky-scrapper-deep-{ams_id}"
    try:
        cronjob = k8s_client.read_namespaced_cron_job(
            name=cronjob_name,
            namespace='default'
        )
        assert cronjob.metadata.name == cronjob_name
        assert cronjob.spec.suspend is False  # Should be active

        # Verify cronjob has correct environment variables
        containers = cronjob.spec.job_template.spec.template.spec.containers
        assert len(containers) > 0
        env_vars = {env.name: env.value for env in containers[0].env}
        assert 'CRON_JOB_NAME' in env_vars
        assert env_vars['CRON_JOB_NAME'] == cronjob_name
    except client.exceptions.ApiException as e:
        if e.status == 404:
            pytest.fail(f"CronJob {cronjob_name} not found in K8s cluster")
        raise

    # Cleanup: Delete cronjob and secret
    try:
        k8s_client.delete_namespaced_cron_job(
            name=cronjob_name,
            namespace='default',
            body=client.V1DeleteOptions(propagation_policy="Background")
        )
    except:
        pass

    try:
        secrets_manager_client.delete_secret(
            SecretId=secret_name,
            ForceDeleteWithoutRecovery=True
        )
    except:
        pass
```

#### Operation: update_configuration

**When to use**: Updating existing LocalStack service configurations or fixing issues

**Steps**:

1. **Read Current Configuration**
   - Read `local_stack/docker-compose.yaml` to understand current state
   - Read `local_stack/run.sh` to understand initialization logic
   - Identify what needs to change and why

2. **Fetch Latest Documentation** (if changing service behavior)
   - Verify changes against latest LocalStack docs
   - Check for breaking changes or deprecated features
   - URL: https://docs.localstack.cloud/aws/{service}/

3. **Make Configuration Changes**
   - Update docker-compose.yaml (environment variables, volumes, ports)
   - Update initialization scripts (run.sh or service-specific scripts)
   - Update health checks if startup verification changes

4. **Test Changes Locally**
   - Run `docker compose down -v` to clean state
   - Run `docker compose up` to verify changes
   - Check service health and logs
   - Run integration tests to verify behavior

5. **Update Tests if Needed**
   - Update test assertions if behavior changed
   - Add new tests for new functionality
   - Update fixtures if service interface changed

**Example: Updating EKS Configuration to Add New Namespace**
```yaml
# local_stack/docker-compose.yaml - Add environment variable
environment:
  - EKS_NAMESPACES=default,test-namespace
```

```bash
# local_stack/run.sh - Add namespace creation
echo "Creating test namespace in EKS cluster..."
kubectl create namespace test-namespace --kubeconfig /tmp/config/kubeconfig || true
```

#### Operation: delete_service_resource

**When to use**: Removing unused AWS services or external resources from LocalStack

**Steps**:

1. **Identify Dependencies**
   - Search codebase for service usage (Grep tool)
   - Check all integration tests for service dependencies
   - Identify downstream services that depend on the service to be deleted

2. **Remove from docker-compose.yaml**
   - Remove service from SERVICES environment variable
   - Remove service-specific environment variables
   - Remove external service definition (if external resource)
   - Update depends_on in dependent services

3. **Remove Initialization Scripts**
   - Delete or comment out initialization code in run.sh
   - Remove service-specific init script files

4. **Update Health Checks**
   - Remove service verification from healthcheck if present
   - Ensure remaining services can still pass health checks

5. **Clean Up Application Code**
   - Remove service clients if no longer needed
   - Update imports and dependencies
   - Remove service-related environment variables from application

6. **Clean Up Tests**
   - Delete service-specific test files
   - Remove service fixtures from conftest.py
   - Update tests that used the service

7. **Clean Up Volumes and Data**
   - Run `docker compose down -v` to remove volumes
   - Delete persisted data directories

**Example: Removing SQS Service**
```yaml
# local_stack/docker-compose.yaml - Remove from SERVICES
environment:
  - SERVICES=secretsmanager,eks  # Removed 'sqs'
```

```bash
# local_stack/run.sh - Remove SQS initialization
# DELETE these lines:
# awslocal sqs create-queue --queue-name test-queue || true
```

```python
# Remove app/clients/sqs_client.py if exists
# Remove local_stack/test_sqs_integration.py if exists
```

## tools

This skill leverages the following Claude Code tools:

**Discovery & Reading**:
- `Read` - Read configuration files, test files, application code
- `Glob` - Find all files matching patterns (e.g., `local_stack/**/*.py`, `app/clients/*.py`)
- `Grep` - Search for service usage across codebase

**Modification**:
- `Edit` - Modify existing files (docker-compose.yaml, run.sh, test files)
- `Write` - Create new files (new test files, init scripts, client code)

**Documentation**:
- `WebFetch` - Fetch latest LocalStack documentation from https://docs.localstack.cloud/
- `WebSearch` - Search for LocalStack best practices and troubleshooting

**Execution & Verification**:
- `Bash` - Run docker compose commands, test LocalStack services, verify configuration
  - `docker compose up -d` - Start services
  - `docker compose logs -f {service}` - Check service logs
  - `docker compose ps` - Check service status
  - `awslocal {service} {command}` - Test AWS service directly

## examples

---

> **IMPORTANT**: All examples below are from a specific service (ams2db-lambda - a healthcare data processing Lambda).
>
> **These are JUST EXAMPLES** showing how the skill works. Your service will have:
> - Different domain (not healthcare)
> - Different tech stack (not Python/pytest)
> - Different infrastructure (not PostgreSQL/LocalStack)
> - Different test patterns
>
> **The skill will adapt to YOUR service** by discovering your actual setup. Don't try to match these examples.

---

## TEST IMPROVEMENT EXAMPLES

### Example 0: Fix Failing Soft-Delete Integration Test

> **Example Context**: This is from a healthcare Lambda service with PostgreSQL soft-deletion logic.
> Your service might test order processing, user management, payment flows, etc. The debugging approach is the same.

**Scenario**: `test_visits_deleted_when_not_in_scrape_window` fails intermittently - sometimes passes, sometimes fails with wrong visit count

**Invocation**: `/localstack-integration debug-failing-test --test=test_soft_delete_integration.py::test_visits_deleted_when_not_in_scrape_window`

**Execution Flow**:

1. **Reproduce & Analyze**:
   ```bash
   # Run test multiple times to confirm flakiness
   docker compose exec test pytest local_stack/test_soft_delete_integration.py::test_visits_deleted_when_not_in_scrape_window -v --count=10
   # Result: 3 passed, 7 failed (70% failure rate - definitely flaky)
   ```

2. **Read Test Code**:
   ```python
   # Found in test_soft_delete_integration.py:
   def test_visits_deleted_when_not_in_scrape_window():
       """Test that visits outside scrape window are preserved"""
       fill_tables("double_night_shift_check_in_db.sql")

       # Load visits for 2026-01-15 only
       metadata = Metadata(
           fetch_timestamp=datetime.now(timezone.utc),
           time_window=TimeWindow(
               start_date=date(2026, 1, 15),
               end_date=date(2026, 1, 15)
           )
       )

       process_message(visits_data, metadata)

       # Verify: visits outside window should NOT be deleted
       with session() as s:
           visits_outside_window = s.query(AmsVisit).filter(
               AmsVisit.visit_date < date(2026, 1, 15)
           ).all()
           assert len(visits_outside_window) == 5  # FAILS sometimes!
   ```

3. **Identify Root Cause**:
   - **Problem**: Race condition with `fetch_timestamp`
   - The test creates visits with `updated_at` set to "now"
   - But `fetch_timestamp` is ALSO set to "now"
   - Depending on timing, visits might have `updated_at >= fetch_timestamp` and get deleted
   - **Evidence**: When test runs fast, timestamps are equal → deletion happens

4. **Apply Fix**:
   ```python
   # BEFORE: fetch_timestamp could equal visit updated_at
   metadata = Metadata(
       fetch_timestamp=datetime.now(timezone.utc),
       time_window=TimeWindow(
           start_date=date(2026, 1, 15),
           end_date=date(2026, 1, 15)
       )
   )

   # AFTER: fetch_timestamp is explicitly AFTER visit creation
   # First: Load test data (visits get updated_at = now)
   fill_tables("double_night_shift_check_in_db.sql")

   # Wait to ensure fetch_timestamp is definitely after insert time
   time.sleep(0.1)

   # Now: Set fetch_timestamp (will be > all visit updated_at times)
   metadata = Metadata(
       fetch_timestamp=datetime.now(timezone.utc),  # Now safely > visit times
       time_window=TimeWindow(
           start_date=date(2026, 1, 15),
           end_date=date(2026, 1, 15)
       )
   )

   process_message(visits_data, metadata)
   ```

5. **Verify Fix**:
   ```bash
   # Run 50 times to confirm stability
   docker compose exec test pytest local_stack/test_soft_delete_integration.py::test_visits_deleted_when_not_in_scrape_window -v --count=50
   # Result: 50 passed, 0 failed (100% pass rate ✓)
   ```

**Result**: Test is now deterministic and passes consistently. The fix ensures fetch_timestamp is always after test data insertion, eliminating the race condition.

---

## INFRASTRUCTURE EXAMPLES

> **Note**: These examples show LocalStack + AWS services. Your service might use:
> - Plain PostgreSQL (no LocalStack)
> - Redis + Kafka + Elasticsearch
> - MongoDB + RabbitMQ
> - Mock HTTP services only
> - Any combination of infrastructure
>
> The skill works the same way - it discovers YOUR infrastructure and helps manage it.

### Example 1: Add S3 Service for File Storage Testing

> **Example Context**: Shows adding LocalStack S3 service. You might be adding Redis, Kafka, mock HTTP server, etc. The process is identical.

**Scenario**: Need to test file upload/download functionality with S3

**Invocation**: `/localstack-integration add-aws-service --service=s3`

**Execution Flow**:

1. **Discovery Phase**:
   - Read `local_stack/docker-compose.yaml` - found SERVICES=secretsmanager,eks
   - Read `local_stack/run.sh` - found EKS and Secrets Manager init
   - Read application code - no existing S3 client found
   - Identified need for S3 bucket initialization

2. **Fetch Documentation**:
   ```
   WebFetch: https://docs.localstack.cloud/aws/s3/
   Found: S3 fully supported in Pro, supports multipart uploads, versioning, event notifications
   Note: Set S3_SKIP_SIGNATURE_VALIDATION=1 for easier testing
   ```

3. **Implementation**:

   a. Update docker-compose.yaml:
   ```yaml
   # Line 8
   - SERVICES=secretsmanager,eks,s3
   # Add after line 16
   - S3_SKIP_SIGNATURE_VALIDATION=1
   ```

   b. Update run.sh:
   ```bash
   # Append to end of file
   echo "Creating S3 test buckets..."
   awslocal s3api create-bucket \
     --bucket test-agency-files \
     --region us-east-1 || true

   awslocal s3api create-bucket \
     --bucket test-visit-documents \
     --region us-east-1 || true

   echo "S3 buckets created successfully."
   ```

   c. Create app/clients/s3_client.py:
   ```python
   import boto3
   import os
   from sensi_logger.log import logger

   # S3 client for file operations
   # Documentation: https://docs.localstack.cloud/aws/s3/

   class S3Client:
       def __init__(self):
           self.client = boto3.client(
               's3',
               endpoint_url=os.getenv('AWS_ENDPOINT_URL', 'http://localhost:4566'),
               region_name=os.getenv('AWS_REGION', 'us-east-1'),
               aws_access_key_id=os.getenv('AWS_ACCESS_KEY_ID', '123'),
               aws_secret_access_key=os.getenv('AWS_SECRET_ACCESS_KEY', '123')
           )

       def upload_file(self, bucket, key, body, content_type=None):
           logger.info(f"Uploading file to S3: s3://{bucket}/{key}")
           kwargs = {'Bucket': bucket, 'Key': key, 'Body': body}
           if content_type:
               kwargs['ContentType'] = content_type
           return self.client.put_object(**kwargs)

       def download_file(self, bucket, key):
           logger.info(f"Downloading file from S3: s3://{bucket}/{key}")
           response = self.client.get_object(Bucket=bucket, Key=key)
           return response['Body'].read()

       def delete_file(self, bucket, key):
           logger.info(f"Deleting file from S3: s3://{bucket}/{key}")
           return self.client.delete_object(Bucket=bucket, Key=key)

       def list_files(self, bucket, prefix=''):
           logger.info(f"Listing files in S3: s3://{bucket}/{prefix}")
           response = self.client.list_objects_v2(Bucket=bucket, Prefix=prefix)
           return response.get('Contents', [])

   s3_client = S3Client()
   ```

   d. Create local_stack/test_s3_integration.py:
   ```python
   import pytest
   import os
   from app.clients.s3_client import s3_client

   @pytest.mark.asyncio
   async def test_s3_upload_download_delete_flow():
       """Test complete S3 file lifecycle: upload -> download -> delete"""
       bucket = 'test-agency-files'
       key = f'test/{os.getpid()}/document.pdf'
       content = b'This is a test PDF document content'

       # Upload
       upload_response = s3_client.upload_file(
           bucket=bucket,
           key=key,
           body=content,
           content_type='application/pdf'
       )
       assert upload_response['ResponseMetadata']['HTTPStatusCode'] == 200

       # Download
       downloaded_content = s3_client.download_file(bucket=bucket, key=key)
       assert downloaded_content == content

       # List files
       files = s3_client.list_files(bucket=bucket, prefix='test/')
       assert any(f['Key'] == key for f in files)

       # Delete
       delete_response = s3_client.delete_file(bucket=bucket, key=key)
       assert delete_response['ResponseMetadata']['HTTPStatusCode'] == 204

       # Verify deleted
       files_after = s3_client.list_files(bucket=bucket, prefix=key)
       assert len(files_after) == 0

   @pytest.mark.asyncio
   async def test_s3_multipart_upload_large_file():
       """Test S3 multipart upload for large files (>5MB)"""
       bucket = 'test-agency-files'
       key = f'test/{os.getpid()}/large_file.bin'

       # Create 10MB file
       large_content = b'X' * (10 * 1024 * 1024)

       # Upload large file
       s3_client.upload_file(bucket=bucket, key=key, body=large_content)

       # Verify upload
       downloaded = s3_client.download_file(bucket=bucket, key=key)
       assert len(downloaded) == len(large_content)

       # Cleanup
       s3_client.delete_file(bucket=bucket, key=key)
   ```

4. **Verification**:
   ```bash
   docker compose down
   docker compose up -d
   docker compose exec test pytest local_stack/test_s3_integration.py -v
   ```

**Result**: S3 service added successfully, integration tests passing, ready for use in application.

### Example 2: Add Redis for Caching Layer

**Scenario**: Application needs Redis for caching API responses

**Invocation**: `/localstack-integration add-external-resource --resource=redis`

**Execution Flow**:

1. **Discovery Phase**:
   - Read docker-compose.yaml - no Redis service found
   - Check application requirements - redis-py not in requirements.txt
   - Identified need for cache layer between API and database

2. **Implementation**:

   a. Update docker-compose.yaml:
   ```yaml
   # Add new service after postgres
   redis:
     image: redis:7-alpine
     command: redis-server --maxmemory 256mb --maxmemory-policy allkeys-lru
     ports:
       - "6379:6379"
     networks:
       - localstack_nw
     healthcheck:
       test: ["CMD", "redis-cli", "ping"]
       interval: 10s
       timeout: 5s
       retries: 5
       start_period: 5s
     volumes:
       - redis_data:/data

   # Update ams-api-service
   ams-api-service:
     environment:
       - REDIS_HOST=redis
       - REDIS_PORT=6379
       - CACHE_TTL=300
     depends_on:
       redis:
         condition: service_healthy

   # Update test service
   test:
     environment:
       - REDIS_HOST=redis
       - REDIS_PORT=6379
     depends_on:
       redis:
         condition: service_healthy

   # Add volume
   volumes:
     redis_data:
   ```

   b. Update requirements.txt:
   ```txt
   redis==5.0.0
   ```

   c. Create app/clients/cache_client.py:
   ```python
   import redis
   import json
   import os
   from typing import Optional, Any
   from sensi_logger.log import logger

   class CacheClient:
       def __init__(self):
           self.client = redis.Redis(
               host=os.getenv('REDIS_HOST', 'localhost'),
               port=int(os.getenv('REDIS_PORT', 6379)),
               decode_responses=True
           )
           self.default_ttl = int(os.getenv('CACHE_TTL', 300))

       def get(self, key: str) -> Optional[Any]:
           """Get value from cache"""
           try:
               value = self.client.get(key)
               if value:
                   logger.debug(f"Cache hit: {key}")
                   return json.loads(value)
               logger.debug(f"Cache miss: {key}")
               return None
           except Exception as e:
               logger.error(f"Cache get error: {e}")
               return None

       def set(self, key: str, value: Any, ttl: Optional[int] = None) -> bool:
           """Set value in cache with TTL"""
           try:
               ttl = ttl or self.default_ttl
               self.client.setex(key, ttl, json.dumps(value))
               logger.debug(f"Cache set: {key} (TTL: {ttl}s)")
               return True
           except Exception as e:
               logger.error(f"Cache set error: {e}")
               return False

       def delete(self, key: str) -> bool:
           """Delete key from cache"""
           try:
               self.client.delete(key)
               logger.debug(f"Cache delete: {key}")
               return True
           except Exception as e:
               logger.error(f"Cache delete error: {e}")
               return False

       def clear_pattern(self, pattern: str) -> int:
           """Delete all keys matching pattern"""
           try:
               keys = self.client.keys(pattern)
               if keys:
                   deleted = self.client.delete(*keys)
                   logger.info(f"Cache cleared: {deleted} keys matching {pattern}")
                   return deleted
               return 0
           except Exception as e:
               logger.error(f"Cache clear pattern error: {e}")
               return 0

   cache_client = CacheClient()
   ```

   d. Add Redis fixture to conftest.py:
   ```python
   @pytest.fixture(scope="session")
   def redis_client():
       import redis
       client = redis.Redis(
           host=os.getenv('REDIS_HOST', 'redis'),
           port=int(os.getenv('REDIS_PORT', 6379)),
           decode_responses=True
       )
       # Test connection
       client.ping()
       yield client
       # Cleanup all test keys
       client.flushdb()
   ```

   e. Create local_stack/test_cache_integration.py:
   ```python
   import pytest
   import time
   from app.clients.cache_client import cache_client

   @pytest.mark.asyncio
   async def test_redis_basic_operations(redis_client):
       """Test basic Redis cache operations"""
       # Set
       redis_client.set('test_key', 'test_value')

       # Get
       value = redis_client.get('test_key')
       assert value == 'test_value'

       # Delete
       redis_client.delete('test_key')
       assert redis_client.get('test_key') is None

   @pytest.mark.asyncio
   async def test_cache_ttl_expiration(redis_client):
       """Test that cache entries expire after TTL"""
       # Set with 2 second TTL
       redis_client.setex('ttl_test', 2, 'value')

       # Should exist immediately
       assert redis_client.get('ttl_test') == 'value'

       # Wait for expiration
       time.sleep(3)

       # Should be expired
       assert redis_client.get('ttl_test') is None

   @pytest.mark.asyncio
   async def test_cache_client_json_serialization():
       """Test CacheClient handles complex objects"""
       test_data = {
           'id': 123,
           'name': 'Test Agency',
           'config': {'url': 'http://test.com'},
           'enabled': True
       }

       # Store complex object
       cache_client.set('agency:123', test_data, ttl=60)

       # Retrieve and verify
       cached = cache_client.get('agency:123')
       assert cached == test_data
       assert isinstance(cached, dict)

       # Cleanup
       cache_client.delete('agency:123')

   @pytest.mark.asyncio
   async def test_cache_pattern_deletion():
       """Test clearing cache by pattern"""
       # Create multiple keys
       cache_client.set('agency:1:data', {'id': 1}, ttl=60)
       cache_client.set('agency:2:data', {'id': 2}, ttl=60)
       cache_client.set('agency:3:data', {'id': 3}, ttl=60)
       cache_client.set('user:1:data', {'id': 1}, ttl=60)

       # Clear only agency keys
       deleted = cache_client.clear_pattern('agency:*')
       assert deleted == 3

       # Verify user key still exists
       assert cache_client.get('user:1:data') is not None

       # Cleanup
       cache_client.delete('user:1:data')
   ```

3. **Verification**:
   ```bash
   docker compose down -v
   docker compose up -d
   docker compose exec test pytest local_stack/test_cache_integration.py -v
   ```

**Result**: Redis cache successfully integrated, tests passing, ready for application-level caching.

### Example 3: Create End-to-End Agency Cronjob Integration Test

**Scenario**: Need to test complete flow from agency update → secret creation → cronjob creation

**Invocation**: `/localstack-integration create-integration-test --flow="agency-cronjob-e2e"`

**Execution Flow**:

1. **Discovery Phase**:
   - Read `local_stack/test_agencies.py` - found existing agency tests
   - Read `app/clients/secrets_client.py` - found secret creation logic
   - Read `app/clients/k8s_cronjob_client.py` - found cronjob creation logic
   - Identified flow: API update → Secrets Manager → K8s CronJob
   - Found gap: no test covering complete cross-service flow

2. **Map Service Interactions**:
   ```
   User -> API (POST /agencies/{id})
       -> Logic Layer (validate config)
       -> Secrets Manager (create/update secret)
       -> K8s Client (create/update cronjob)
       -> Database (update agency record)
       <- Response (agency with cronjob info)
   ```

3. **Implementation**:

   Create local_stack/test_cronjob_lifecycle_e2e.py:
   ```python
   import pytest
   import boto3
   import os
   import time
   from kubernetes import client, config as k8s_config
   from sensi_ams_api_client import Configuration, ApiClient, AgenciesApi, AgencyInclude

   HOST = os.getenv("HOST", "http://ams-api-service:10000")
   API_KEY = os.getenv("API_KEY")

   @pytest.fixture(scope="function")
   def aws_clients():
       """Provide AWS service clients for testing"""
       return {
           'secrets': boto3.client(
               'secretsmanager',
               endpoint_url=os.getenv('AWS_ENDPOINT_URL', 'http://localstack:4566'),
               region_name='us-east-1'
           )
       }

   @pytest.fixture(scope="function")
   def k8s_batch_client():
       """Provide K8s batch API client"""
       k8s_config.load_kube_config(config_file=os.getenv("KUBECONFIG"))
       return client.BatchV1Api()

   @pytest.mark.asyncio
   async def test_agency_enable_creates_secret_and_cronjob(aws_clients, k8s_batch_client):
       """
       Test complete agency data fetch enablement flow:
       1. Create agency (disabled)
       2. Add config (should create secret)
       3. Enable data fetch (should create cronjob)
       4. Verify secret exists with correct data
       5. Verify cronjob exists with correct configuration
       6. Disable data fetch (should suspend cronjob)
       7. Cleanup
       """
       configuration = Configuration(host=HOST, access_token=API_KEY)
       secrets_client = aws_clients['secrets']

       # Use unique ID for test isolation
       test_customer_id = int(time.time()) % 100000

       # Step 1: Create agency
       with ApiClient(configuration) as api_client:
           api_instance = AgenciesApi(api_client)
           new_agency = api_instance.create_agency(
               agency_create={
                   "customer_id": test_customer_id,
                   "data_fetch_enabled": False,
               },
               x_user_id=55555,
               x_request_id=f"test-cronjob-e2e-{test_customer_id}",
               x_client_name="integration-test"
           )

       assert new_agency.id is not None
       assert new_agency.data_fetch_enabled is False
       agency_id = new_agency.id

       # Step 2: Add WellSky configuration
       with ApiClient(configuration) as api_client:
           api_instance = AgenciesApi(api_client)
           configured_agency = api_instance.update_agency(
               agency_id=agency_id,
               customer_id=test_customer_id,
               agency_update={
                   "company": 2,  # WellSky
                   "data_source": 2,  # Scrapper
                   "config": {
                       "base_url": f"http://mock-wellsky:10010/{test_customer_id}/",
                       "username": f"test_user_{test_customer_id}",
                       "password": f"test_pass_{test_customer_id}"
                   }
               },
               x_user_id=55555,
               x_request_id=f"test-cronjob-e2e-{test_customer_id}",
               x_client_name="integration-test"
           )

       assert configured_agency.ams_id is not None
       ams_id = configured_agency.ams_id

       # Verify secret created
       secret_name = f"test/ams/wellsky/scrapper_configs/agency/{ams_id}"
       secret = None
       for attempt in range(5):  # Retry for eventual consistency
           try:
               secret = secrets_client.describe_secret(SecretId=secret_name)
               break
           except secrets_client.exceptions.ResourceNotFoundException:
               if attempt < 4:
                   time.sleep(1)
                   continue
               pytest.fail(f"Secret {secret_name} not created after agency config update")

       assert secret is not None
       assert secret['Name'] == secret_name

       # Verify secret content
       secret_value = secrets_client.get_secret_value(SecretId=secret_name)
       import json
       secret_data = json.loads(secret_value['SecretString'])
       assert secret_data['base_url'] == f"http://mock-wellsky:10010/{test_customer_id}/"
       assert secret_data['username'] == f"test_user_{test_customer_id}"
       assert secret_data['password'] == f"test_pass_{test_customer_id}"
       assert secret_data['ams_customer_id'] == ams_id

       # Step 3: Enable data fetch
       with ApiClient(configuration) as api_client:
           api_instance = AgenciesApi(api_client)
           enabled_agency = api_instance.update_agency(
               agency_id=agency_id,
               customer_id=test_customer_id,
               agency_update={"data_fetch_enabled": True},
               x_user_id=55555,
               x_request_id=f"test-cronjob-e2e-{test_customer_id}",
               x_client_name="integration-test"
           )

       assert enabled_agency.data_fetch_enabled is True

       # Verify cronjob created
       cronjob_name = f"wellsky-scrapper-deep-{ams_id}"
       cronjob = None
       for attempt in range(10):  # K8s might take a moment
           try:
               cronjob = k8s_batch_client.read_namespaced_cron_job(
                   name=cronjob_name,
                   namespace='default'
               )
               break
           except client.exceptions.ApiException as e:
               if e.status == 404 and attempt < 9:
                   time.sleep(1)
                   continue
               pytest.fail(f"CronJob {cronjob_name} not created after enabling data fetch")

       assert cronjob is not None
       assert cronjob.metadata.name == cronjob_name
       assert cronjob.spec.suspend is False  # Should be active

       # Verify cronjob configuration
       containers = cronjob.spec.job_template.spec.template.spec.containers
       assert len(containers) > 0

       # Check environment variables
       env_vars = {env.name: env.value for env in containers[0].env}
       assert 'CRON_JOB_NAME' in env_vars
       assert env_vars['CRON_JOB_NAME'] == cronjob_name

       # Check schedule (should be valid cron expression)
       assert cronjob.spec.schedule is not None
       assert len(cronjob.spec.schedule.split()) == 5  # Valid cron: 5 fields

       # Step 4: Test disable data fetch (should suspend cronjob)
       with ApiClient(configuration) as api_client:
           api_instance = AgenciesApi(api_client)
           disabled_agency = api_instance.update_agency(
               agency_id=agency_id,
               customer_id=test_customer_id,
               agency_update={"data_fetch_enabled": False},
               x_user_id=55555,
               x_request_id=f"test-cronjob-e2e-{test_customer_id}",
               x_client_name="integration-test"
           )

       assert disabled_agency.data_fetch_enabled is False

       # Verify cronjob suspended
       time.sleep(2)  # Wait for update propagation
       suspended_cronjob = k8s_batch_client.read_namespaced_cron_job(
           name=cronjob_name,
           namespace='default'
       )
       assert suspended_cronjob.spec.suspend is True

       # Cleanup: Delete cronjob and secret
       try:
           k8s_batch_client.delete_namespaced_cron_job(
               name=cronjob_name,
               namespace='default',
               body=client.V1DeleteOptions(propagation_policy="Background")
           )
       except Exception as e:
           print(f"Cleanup warning: Failed to delete cronjob: {e}")

       try:
           secrets_client.delete_secret(
               SecretId=secret_name,
               ForceDeleteWithoutRecovery=True
           )
       except Exception as e:
           print(f"Cleanup warning: Failed to delete secret: {e}")

   @pytest.mark.asyncio
   async def test_agency_config_update_updates_secret(aws_clients):
       """
       Test that updating agency config updates the secret:
       1. Create agency with config
       2. Update config (change password)
       3. Verify secret updated with new values
       """
       configuration = Configuration(host=HOST, access_token=API_KEY)
       secrets_client = aws_clients['secrets']

       test_customer_id = int(time.time()) % 100000 + 50000

       # Create agency with initial config
       with ApiClient(configuration) as api_client:
           api_instance = AgenciesApi(api_client)
           agency = api_instance.create_agency(
               agency_create={
                   "customer_id": test_customer_id,
                   "company": 2,
                   "data_source": 2,
                   "data_fetch_enabled": False,
                   "config": {
                       "base_url": f"http://mock-wellsky:10010/{test_customer_id}/",
                       "username": "initial_user",
                       "password": "initial_password"
                   }
               },
               x_user_id=55555,
               x_request_id=f"test-secret-update-{test_customer_id}",
               x_client_name="integration-test"
           )

       ams_id = agency.ams_id
       secret_name = f"test/ams/wellsky/scrapper_configs/agency/{ams_id}"

       # Wait for initial secret creation
       time.sleep(2)

       # Update config
       with ApiClient(configuration) as api_client:
           api_instance = AgenciesApi(api_client)
           updated_agency = api_instance.update_agency(
               agency_id=agency.id,
               customer_id=test_customer_id,
               agency_update={
                   "config": {
                       "password": "updated_password"  # Only update password
                   }
               },
               x_user_id=55555,
               x_request_id=f"test-secret-update-{test_customer_id}",
               x_client_name="integration-test"
           )

       # Wait for secret update
       time.sleep(2)

       # Verify secret updated
       secret_value = secrets_client.get_secret_value(SecretId=secret_name)
       import json
       secret_data = json.loads(secret_value['SecretString'])

       # Password should be updated
       assert secret_data['password'] == "updated_password"
       # Other fields should remain
       assert secret_data['username'] == "initial_user"
       assert secret_data['base_url'] == f"http://mock-wellsky:10010/{test_customer_id}/"

       # Cleanup
       try:
           secrets_client.delete_secret(
               SecretId=secret_name,
               ForceDeleteWithoutRecovery=True
           )
       except:
           pass
   ```

4. **Verification**:
   ```bash
   docker compose exec test pytest local_stack/test_cronjob_lifecycle_e2e.py -v -s
   ```

**Result**: End-to-end integration test created that verifies complete flow across API → Secrets Manager → K8s. Test is deterministic, properly isolated, and tests real observable behavior.

## patterns

### docker_compose_patterns

**Pattern 1: Service Health Checks with Proper Timing**
```yaml
healthcheck:
  test: ["CMD", "service-specific-health-check"]
  interval: 10s      # How often to check
  timeout: 5s        # Max time for health check to complete
  retries: 5         # Number of failures before unhealthy
  start_period: 30s  # Grace period before checking (important for slow-starting services)
```

**Why**: Prevents race conditions during startup. `start_period` is critical for services like LocalStack that take time to initialize.

**Pattern 2: Proper Service Dependencies**
```yaml
service-a:
  depends_on:
    service-b:
      condition: service_healthy  # Wait for health check to pass
    service-c:
      condition: service_started  # Just wait for start (no health check)
```

**Why**: Ensures correct startup order and prevents failures from services starting before dependencies are ready.

**Pattern 3: Shared Networks for Inter-Service Communication**
```yaml
services:
  localstack:
    networks:
      - localstack_nw

  app:
    networks:
      - localstack_nw

networks:
  localstack_nw:
    external: false
    driver: bridge
```

**Why**: All services on same network can communicate using service names as DNS hostnames (e.g., `http://localstack:4566`).

**Pattern 4: Volume Mounts for Configuration and Persistence**
```yaml
localstack:
  volumes:
    - "./localstack_data:/var/lib/localstack"  # Persistence
    - "./run.sh:/etc/localstack/init/ready.d/run.sh"  # Init script
    - "./config:/tmp/config"  # Shared config between services
```

**Why**:
- Persistence volume preserves state across restarts
- Init scripts in `/etc/localstack/init/ready.d/` run when LocalStack is ready
- Shared config volumes allow multiple services to access same files

**Pattern 5: Environment Variable Files for Clean Configuration**
```yaml
env_file:
  - ./config/local_stack_env
environment:
  - SPECIFIC_VAR=value  # Service-specific overrides
```

**Why**: Keeps docker-compose.yaml clean and allows sharing common environment variables across services.

**Pattern 6: Platform-Specific Images**
```yaml
platform: linux/arm64  # For M1/M2 Macs
build:
  context: ../
  dockerfile: Dockerfile
```

**Why**: Ensures compatibility across different architectures (Intel vs ARM).

### init_script_patterns

**Pattern 1: Idempotent AWS Resource Creation**
```bash
# Always use || true for create operations
awslocal s3api create-bucket --bucket test-bucket || true
awslocal secretsmanager create-secret --name test-secret --secret-string '{}' || true
```

**Why**: Scripts should work on restart when LocalStack has PERSISTENCE=1. The `|| true` prevents script failure if resource already exists.

**Pattern 2: Wait for Service Readiness**
```bash
# Wait for cluster to be active before continuing
awslocal eks wait cluster-active --name test-cluster

# Or poll until resource exists
until awslocal s3api head-bucket --bucket test-bucket 2>/dev/null; do
  echo "Waiting for bucket..."
  sleep 1
done
```

**Why**: Ensures resources are fully initialized before dependent operations run.

**Pattern 3: Shared Configuration Between Containers**
```bash
# Generate kubeconfig and make it available to other containers
awslocal eks update-kubeconfig --name test-cluster --kubeconfig /tmp/config/kubeconfig

# Patch for internal container networking
sed -i 's/localhost/localstack/g' /tmp/config/kubeconfig
```

**Why**: Multiple containers need access to kubeconfig. By mounting `/tmp/config` as shared volume, all containers can access it.

**Pattern 4: Structured Secret Data**
```bash
awslocal secretsmanager create-secret \
  --name test/ams/service/configs/resource/123 \
  --secret-string '{"key": "value", "nested": {"data": "here"}}' \
  --region us-east-1 || true
```

**Why**: Use JSON for structured data. Makes it easy to parse in application code and add new fields.

**Pattern 5: Clear Progress Logging**
```bash
set -x  # Enable command echoing for debugging

echo "Creating EKS Cluster..."
awslocal eks create-cluster --name test-cluster || true

echo "Waiting for cluster to be ACTIVE..."
awslocal eks wait cluster-active --name test-cluster

echo "LocalStack Initialization Complete."
```

**Why**: Clear logging helps debug initialization issues. The `set -x` shows exactly which commands are running.

### test_patterns

**Pattern 1: Repo-Agnostic Test Structure**
```python
# Discover configuration from environment
HOST = os.getenv("HOST", "http://ams-api-service:10000")
API_KEY = os.getenv("API_KEY")
AWS_ENDPOINT = os.getenv("AWS_ENDPOINT_URL", "http://localstack:4566")

# Use environment-based configuration
configuration = Configuration(host=HOST, access_token=API_KEY)
```

**Why**: Tests work in any environment (local, CI, different projects) without hardcoding values.

**Pattern 2: Session-Scoped Fixtures for Shared Setup**
```python
@pytest.fixture(scope="session", autouse=True)
def init_db():
    """Initialize database schema once per test session"""
    # Setup database schema
    yield
    # Optional cleanup after all tests
```

**Why**: Expensive setup (database initialization, schema creation) runs once for all tests, not once per test.

**Pattern 3: Function-Scoped Fixtures for Test Isolation**
```python
@pytest.fixture(scope="function")
def clean_s3_bucket():
    """Provide clean S3 bucket for each test"""
    bucket = 'test-bucket'
    # Pre-test: ensure bucket is empty
    yield bucket
    # Post-test: cleanup
    s3_client.delete_all_objects(bucket)
```

**Why**: Each test gets clean state, preventing test interdependencies and flakiness.

**Pattern 4: Async Test with Real Service Clients**
```python
@pytest.mark.asyncio
async def test_integration_flow():
    """Test flow using real LocalStack services"""
    # Use real boto3 clients (not mocked)
    s3_client = boto3.client('s3', endpoint_url='http://localstack:4566')

    # Test real behavior
    s3_client.put_object(Bucket='test', Key='file', Body=b'data')
    result = s3_client.get_object(Bucket='test', Key='file')

    # Assert observable behavior
    assert result['Body'].read() == b'data'
```

**Why**: Integration tests should use real services. Mocking defeats the purpose of integration testing.

**Pattern 5: Retry Logic for Eventually Consistent Operations**
```python
def wait_for_resource(check_fn, timeout=30, interval=1):
    """Wait for resource to exist or reach desired state"""
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

# Usage
cronjob = wait_for_resource(
    lambda: k8s_client.read_namespaced_cron_job('test-job', 'default')
)
```

**Why**: Some operations (K8s resource creation, secret propagation) are eventually consistent. Retries prevent flaky tests.

**Pattern 6: Test Data with Unique Identifiers**
```python
import time

# Use timestamp or UUID for uniqueness
test_customer_id = int(time.time()) % 100000

# Or
import uuid
test_key = f"test/{uuid.uuid4()}/file.txt"
```

**Why**: Prevents test conflicts when running in parallel or when cleanup fails. Each test uses unique identifiers.

**Pattern 7: Comprehensive Cleanup in Finally Blocks**
```python
@pytest.mark.asyncio
async def test_with_cleanup():
    cronjob_name = None
    secret_name = None

    try:
        # Test operations that create resources
        cronjob_name = "test-job"
        secret_name = "test/secret/123"
        # ... test logic ...
    finally:
        # Cleanup regardless of test outcome
        if cronjob_name:
            try:
                k8s_client.delete_namespaced_cron_job(cronjob_name, 'default')
            except:
                pass  # Already deleted or never created

        if secret_name:
            try:
                secrets_client.delete_secret(
                    SecretId=secret_name,
                    ForceDeleteWithoutRecovery=True
                )
            except:
                pass
```

**Why**: Ensures cleanup happens even if test fails. Prevents resource leaks between test runs.

**Pattern 8: Assertion Helpers for Complex Verification**
```python
async def assert_agency_config(agency, expected_config, with_secrets=False):
    """Helper to verify agency configuration"""
    assert agency.config.base_url == expected_config['base_url']
    assert agency.config.username == expected_config['username']

    if with_secrets:
        # Don't assert actual password value (masked)
        assert agency.config.password.get_secret_value() == '**********'

    # More assertions...

# Usage in tests
await assert_agency_config(result, expected_config, with_secrets=True)
```

**Why**: Reduces duplication, makes tests more readable, and centralizes verification logic for reuse.

**Pattern 9: Testing Both Happy Path and Error Cases**
```python
@pytest.mark.asyncio
async def test_create_agency_success():
    """Test successful agency creation"""
    # Happy path test
    agency = create_agency(valid_data)
    assert agency.id is not None

@pytest.mark.asyncio
async def test_create_agency_invalid_config():
    """Test agency creation with invalid config fails properly"""
    # Error case test
    with pytest.raises(ValidationException) as exc:
        create_agency(invalid_data)

    assert "Invalid configuration" in str(exc.value)
```

**Why**: Integration tests should verify both success and failure paths. Error handling is critical behavior to test.

### test_execution_patterns

**Pattern 1: Complete Docker Environment Reset (CRITICAL)**
```bash
# ALWAYS do this before running full test suite
# This ensures absolutely clean environment with no stale data, images, or containers

docker compose down --rmi all --volumes --remove-orphans
docker compose up -v --force-recreate --build --remove-orphans
```

**Why**:
- `--rmi all`: Removes ALL images (forces rebuild from scratch)
- `--volumes`: Removes all volumes (clears database state, cache, etc.)
- `--remove-orphans`: Removes containers not defined in current docker-compose.yaml
- `--force-recreate`: Forces recreation even if configuration/image hasn't changed
- `--build`: Rebuilds images from Dockerfile
- This is THE canonical way to ensure a completely clean testing environment

**When to use**:
- Before running full integration test suite
- When tests fail mysteriously and you suspect stale state
- After changing Dockerfile or docker-compose.yaml
- When switching branches with different database schemas
- Before debugging flaky tests

**Pattern 2: Quick Test Run (Clean Environment)**
```bash
# Full cleanup and run tests
docker compose down --rmi all --volumes --remove-orphans
docker compose up -v --force-recreate --build --remove-orphans

# Once services are up, run tests
docker compose exec test pytest local_stack/ -v
```

**Pattern 3: Run Specific Test with Clean Environment**
```bash
# Full cleanup first
docker compose down --rmi all --volumes --remove-orphans
docker compose up -v --force-recreate --build --remove-orphans

# Run specific test
docker compose exec test pytest local_stack/test_file.py::test_name -v -s
```

### cleanup_patterns

**Pattern 1: Docker Compose Full Reset (Legacy - Use test_execution_patterns Pattern 1 instead)**
```bash
# Complete cleanup including volumes
docker compose down -v

# Rebuild and start fresh
docker compose up --build -d
```

**Why**: Removes all containers, networks, and volumes. Ensures completely clean state.

**Note**: This is the old way. For integration tests, ALWAYS use the complete reset command from test_execution_patterns Pattern 1.

**Pattern 2: Selective Service Restart**
```bash
# Restart specific service without affecting others
docker compose restart localstack

# View logs
docker compose logs -f localstack
```

**Why**: Faster than full restart when debugging single service issues.

**Pattern 3: Clean Test Data Between Runs**
```python
@pytest.fixture(scope="function", autouse=True)
def cleanup_test_data(redis_client, s3_client, secrets_client):
    """Auto-cleanup test data after each test"""
    yield

    # Clear Redis test keys
    redis_client.delete(*redis_client.keys('test:*'))

    # Clear S3 test objects
    for obj in s3_client.list_objects_v2(Bucket='test-bucket', Prefix='test/')['Contents']:
        s3_client.delete_object(Bucket='test-bucket', Key=obj['Key'])

    # Delete test secrets
    for secret in secrets_client.list_secrets()['SecretList']:
        if secret['Name'].startswith('test/temp/'):
            secrets_client.delete_secret(
                SecretId=secret['Name'],
                ForceDeleteWithoutRecovery=True
            )
```

**Why**: Ensures clean state between tests without full Docker restart. Faster test iterations.

**Pattern 4: Remove Orphaned K8s Resources**
```bash
# List all cronjobs
kubectl get cronjobs --kubeconfig=/tmp/config/kubeconfig

# Delete test cronjobs
kubectl delete cronjobs -l test=true --kubeconfig=/tmp/config/kubeconfig

# Delete all jobs created by cronjobs
kubectl delete jobs -l test=true --kubeconfig=/tmp/config/kubeconfig
```

**Why**: K8s resources can accumulate during testing. Clean them up to prevent resource exhaustion.

**Pattern 5: Prune Docker Resources**
```bash
# Remove stopped containers
docker container prune -f

# Remove unused volumes
docker volume prune -f

# Remove unused images
docker image prune -f

# Remove everything unused (careful!)
docker system prune -a -f --volumes
```

**Why**: Frees disk space from accumulated test artifacts.

## documentation_sources

**Primary LocalStack Pro Documentation** (⚠️ ALWAYS FETCH LATEST):
- **Main docs**: https://docs.localstack.cloud/
- **AWS Service Coverage**: https://docs.localstack.cloud/aws/
- **Pro Feature Coverage**: https://docs.localstack.cloud/getting-started/feature-coverage/
- **Configuration**: https://docs.localstack.cloud/references/configuration/
- **What's New**: https://docs.localstack.cloud/references/changelog/

> **CRITICAL**: LocalStack Pro updates frequently. NEVER rely on cached or old documentation.
> ALWAYS use WebFetch to get the latest docs before adding/modifying services.

**Service-Specific Documentation** (⚠️ Always fetch latest with WebFetch):
- S3: https://docs.localstack.cloud/aws/s3/
- SQS: https://docs.localstack.cloud/aws/sqs/
- SNS: https://docs.localstack.cloud/aws/sns/
- Lambda: https://docs.localstack.cloud/aws/lambda/
- DynamoDB: https://docs.localstack.cloud/aws/dynamodb/
- EKS: https://docs.localstack.cloud/aws/eks/
- Secrets Manager: https://docs.localstack.cloud/aws/secretsmanager/
- RDS: https://docs.localstack.cloud/aws/rds/
- CloudWatch: https://docs.localstack.cloud/aws/cloudwatch/
- ECS: https://docs.localstack.cloud/aws/ecs/
- EventBridge: https://docs.localstack.cloud/aws/eventbridge/
- Step Functions: https://docs.localstack.cloud/aws/stepfunctions/
- API Gateway: https://docs.localstack.cloud/aws/apigateway/
- Kinesis: https://docs.localstack.cloud/aws/kinesis/
- And 90+ more services...

**Docker & Testing Resources**:
- Docker Compose: https://docs.docker.com/compose/
- Pytest Documentation: https://docs.pytest.org/
- Boto3 Documentation: https://boto3.amazonaws.com/v1/documentation/api/latest/index.html
- Kubernetes Python Client: https://github.com/kubernetes-client/python

**Best Practices**:
- LocalStack CI Integration: https://docs.localstack.cloud/user-guide/ci/
- LocalStack Docker Setup: https://docs.localstack.cloud/getting-started/installation/#docker
- LocalStack Persistence: https://docs.localstack.cloud/references/persistence-mechanism/

## quality_standards

**These standards apply universally across all projects, regardless of tech stack or domain:**

**1. Repo-Agnostic Approach**
- Work with ANY repository structure
- Discover configuration from environment variables and existing files
- Don't assume specific project layouts or naming conventions
- Read everything before making assumptions

**2. Minimal Questions**
- At most ONE clarifying round
- Include evidence (file paths + snippets) with every question
- State "why it matters" - what decision it changes
- Provide hypothesis - default assumption if no answer
- If no blocking questions, proceed immediately

**3. High Quality Bar**
- Every integration test must assert REAL observable behavior
- Use REAL services when possible (real database, real cache, etc.)
  - If using LocalStack: Use real LocalStack services (not mocked)
  - If using test containers: Use real Docker containers
  - Only mock external APIs outside your control
- Test cross-service interactions and end-to-end flows
- Cover conditionally untestable unit code paths
- Tests must be deterministic and properly isolated
- No flaky tests - use proper waits/retries for async operations

**4. Clean Code Standards**
- Follow existing codebase patterns and conventions
- Minimal duplication, maximum clarity
- Self-documenting code with strategic comments
- Include LocalStack documentation URLs in comments
- Proper error handling and cleanup

**5. Minimal Docker Configuration**
- Use multi-stage builds where beneficial
- Minimize layers and image size
- Leverage Docker Compose profiles for optional services
- Cache-friendly layer ordering
- Clear healthchecks with appropriate timing

**6. Smooth Integration**
- Zero manual steps after `docker compose up`
- Automatic service initialization via init scripts
- Proper startup ordering with depends_on and healthchecks
- Clear error messages when services fail to start
- Idempotent initialization scripts (work on restart)

**7. Always-Current Documentation**
- ALWAYS fetch latest documentation before modifying infrastructure:
  - LocalStack: https://docs.localstack.cloud/ (if using AWS services)
  - Databases: Official docs for PostgreSQL, MySQL, MongoDB, etc.
  - Message queues: Kafka, RabbitMQ, etc.
  - Test frameworks: pytest, jest, JUnit, etc.
- Check version compatibility and feature availability
- Identify service-specific limitations and requirements
- Include documentation URLs in code comments
- Flag deprecated patterns and suggest modern alternatives

**8. Evidence-Based Decisions**
- Read all related files before making changes
- Build evidence map: "behavior → files → tests → gaps"
- Base decisions on actual code, not assumptions
- Verify changes with real tests, not speculation

**9. Completeness**
- Test both happy paths and error scenarios
- Include cleanup logic (fixtures or finally blocks)
- Handle async operations with proper waiting mechanisms
- Verify all resources created during test
- Clean up resources even if test fails

## success_criteria

**Service Addition Success**:
- ✓ Service added to SERVICES environment variable in docker-compose.yaml
- ✓ Service-specific environment variables configured (if needed)
- ✓ Initialization script created/updated for service setup
- ✓ Healthcheck updated to verify service (if critical)
- ✓ Service client created in application code (if needed)
- ✓ Integration test created covering service behavior
- ✓ Test passes on first run and is deterministic
- ✓ Documentation URLs included in code comments
- ✓ `docker compose up` starts all services successfully

**External Resource Addition Success**:
- ✓ Resource service added to docker-compose.yaml
- ✓ Healthcheck configured for resource
- ✓ Network configuration correct (localstack_nw)
- ✓ Dependent services updated with resource connection info
- ✓ depends_on configured with service_healthy condition
- ✓ Resource client/connection created in fixtures or app code
- ✓ Integration test created covering resource behavior
- ✓ Test passes and properly cleans up resources

**Integration Test Creation Success**:
- ✓ Test file created following naming convention (test_*.py)
- ✓ Test uses real LocalStack services (not mocked)
- ✓ Test covers cross-service interaction or end-to-end flow
- ✓ Test asserts observable behavior (not implementation details)
- ✓ Test is deterministic (passes consistently)
- ✓ Test properly isolated (unique identifiers, cleanup)
- ✓ Test handles async operations with proper waiting
- ✓ Test includes both happy path and error cases (where applicable)
- ✓ Cleanup logic present (fixtures or finally blocks)
- ✓ Test passes in docker compose test environment

**Configuration Update Success**:
- ✓ Changes verified against latest LocalStack documentation
- ✓ docker-compose.yaml updated correctly
- ✓ Initialization scripts updated if needed
- ✓ All services start successfully after changes
- ✓ Existing tests still pass
- ✓ New functionality tested (if added)

**Service/Resource Deletion Success**:
- ✓ Service removed from SERVICES environment variable
- ✓ Service-specific configuration removed
- ✓ Initialization scripts cleaned up
- ✓ Application code updated (removed clients, imports)
- ✓ Test files removed or updated
- ✓ Dependent services updated (removed dependencies)
- ✓ `docker compose up` still works without errors
- ✓ Remaining tests still pass

**Overall Quality Criteria**:
- ✓ Zero manual steps required after `docker compose up`
- ✓ All services pass health checks
- ✓ Integration tests pass consistently
- ✓ Code follows existing patterns and conventions
- ✓ Documentation URLs included where relevant
- ✓ Cleanup logic prevents resource leaks
- ✓ Error messages are clear and actionable

## troubleshooting

### Issue: LocalStack service fails to start

**Symptoms**:
- Container exits immediately
- Healthcheck always failing
- Logs show "service not available"

**Diagnosis**:
```bash
# Check LocalStack container logs
docker compose logs localstack

# Check if LocalStack is running
docker compose ps localstack

# Check LocalStack health
docker compose exec localstack curl -s http://localhost:4566/_localstack/health | jq
```

**Common Causes & Solutions**:

1. **Invalid LOCALSTACK_AUTH_TOKEN**
   - **Symptom**: "License activation failed" in logs
   - **Solution**: Check token validity, update in docker-compose.yaml and config/local_stack_env

2. **Insufficient memory**
   - **Symptom**: Container OOM killed
   - **Solution**: Increase Docker memory limit (Settings → Resources → Memory)

3. **Invalid SERVICES configuration**
   - **Symptom**: "Unknown service: xyz"
   - **Solution**: Check service name spelling, verify Pro vs Community availability

4. **Port conflict**
   - **Symptom**: "Port 4566 already in use"
   - **Solution**: Stop conflicting process or change port mapping in docker-compose.yaml

### Issue: Integration tests are flaky

**Symptoms**:
- Tests pass sometimes, fail other times
- "Resource not found" errors intermittently
- Timing-related failures

**Diagnosis**:
```python
# Add debug logging to tests
import logging
logging.basicConfig(level=logging.DEBUG)

# Check test isolation
# Run test multiple times
pytest local_stack/test_file.py::test_name -v -s --count=10
```

**Common Causes & Solutions**:

1. **No retry logic for async operations**
   - **Cause**: K8s/AWS operations are eventually consistent
   - **Solution**: Add wait_for_resource helper with retries

2. **Shared test data conflicts**
   - **Cause**: Tests using same IDs/keys
   - **Solution**: Use unique identifiers (timestamp, UUID) per test

3. **Insufficient cleanup**
   - **Cause**: Previous test leaves data that affects next test
   - **Solution**: Add cleanup fixtures or finally blocks

4. **Race conditions in parallel tests**
   - **Cause**: Tests running in parallel modify shared resources
   - **Solution**: Use function-scoped fixtures or run sequentially

### Issue: Service can't connect to LocalStack

**Symptoms**:
- Application logs show connection refused
- boto3 endpoint errors
- "Could not connect to endpoint" errors

**Diagnosis**:
```bash
# Check network connectivity
docker compose exec ams-api-service ping localstack

# Check if LocalStack port is accessible
docker compose exec ams-api-service curl http://localstack:4566/_localstack/health

# Verify environment variables
docker compose exec ams-api-service env | grep AWS
```

**Common Causes & Solutions**:

1. **Wrong endpoint URL**
   - **Cause**: Using localhost instead of localstack
   - **Solution**: Use `http://localstack:4566` for container-to-container communication

2. **Service not on same network**
   - **Cause**: Service not connected to localstack_nw
   - **Solution**: Add `networks: - localstack_nw` to service definition

3. **Service started before LocalStack ready**
   - **Cause**: No proper depends_on configuration
   - **Solution**: Add `depends_on: localstack: condition: service_healthy`

4. **AWS credentials not set**
   - **Cause**: boto3 requires credentials even for LocalStack
   - **Solution**: Set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY (any value works)

### Issue: EKS cluster not accessible

**Symptoms**:
- kubectl commands fail
- "kubeconfig not found"
- K8s client can't connect to cluster

**Diagnosis**:
```bash
# Check if kubeconfig exists
docker compose exec ams-api-service ls -la /tmp/config/kubeconfig

# Check kubeconfig content
docker compose exec ams-api-service cat /tmp/config/kubeconfig

# Test K8s connectivity
docker compose exec ams-api-service kubectl --kubeconfig=/tmp/config/kubeconfig get nodes
```

**Common Causes & Solutions**:

1. **Kubeconfig not generated**
   - **Cause**: Initialization script failed
   - **Solution**: Check LocalStack logs, ensure run.sh completed successfully

2. **Kubeconfig references localhost**
   - **Cause**: kubeconfig not patched for container networking
   - **Solution**: Ensure run.sh has sed commands to replace localhost with localstack

3. **Volume mount issues**
   - **Cause**: /tmp/config not mounted properly
   - **Solution**: Verify volumes section in docker-compose.yaml for both LocalStack and application

4. **SSL verification issues**
   - **Cause**: K8s client verifying SSL for LocalStack
   - **Solution**: Disable SSL verification in K8s client configuration

### Issue: Secrets Manager secret not found

**Symptoms**:
- "SecretNotFoundException" errors
- Application can't load configuration
- Secret exists but can't be retrieved

**Diagnosis**:
```bash
# List all secrets
docker compose exec localstack awslocal secretsmanager list-secrets

# Check specific secret
docker compose exec localstack awslocal secretsmanager describe-secret \
  --secret-id test/ams/service/config/123

# Get secret value
docker compose exec localstack awslocal secretsmanager get-secret-value \
  --secret-id test/ams/service/config/123
```

**Common Causes & Solutions**:

1. **Secret not created in initialization**
   - **Cause**: Init script failed or didn't run
   - **Solution**: Check run.sh, ensure create-secret commands present and executed

2. **Wrong secret name/path**
   - **Cause**: Application looking for different path than created
   - **Solution**: Verify secret naming convention matches between init script and app code

3. **Secret created after application starts**
   - **Cause**: Race condition in startup order
   - **Solution**: Add secret creation to healthcheck to ensure it exists before app starts

4. **Persistence issue**
   - **Cause**: LocalStack restarted without persistence
   - **Solution**: Ensure PERSISTENCE=1 and volume mounted correctly

### Issue: Docker Compose build fails

**Symptoms**:
- "Error building image"
- Dependency installation failures
- Context issues

**Diagnosis**:
```bash
# Build with verbose output
docker compose build --no-cache --progress=plain

# Check Dockerfile syntax
docker compose config

# Check build context
ls -la [build-context-directory]
```

**Common Causes & Solutions**:

1. **Build context too large**
   - **Cause**: Including unnecessary files in build context
   - **Solution**: Add .dockerignore file to exclude large directories

2. **Dependency installation fails**
   - **Cause**: Network issues, unavailable packages
   - **Solution**: Check package names, try without cache, verify network connectivity

3. **Multi-stage build issues**
   - **Cause**: Files not copied between stages
   - **Solution**: Ensure COPY commands copy from correct stage

4. **Platform mismatch**
   - **Cause**: Building for wrong architecture
   - **Solution**: Add `platform: linux/arm64` or `linux/amd64` as needed

### Issue: Tests pass locally but fail in CI

**Symptoms**:
- Tests pass on developer machine
- Same tests fail in CI pipeline
- Environment-specific failures

**Diagnosis**:
```bash
# Check CI logs for environment differences
# Compare environment variables
# Check resource limits in CI

# Run tests with CI-like constraints locally
docker compose up --abort-on-container-exit test
```

**Common Causes & Solutions**:

1. **Timing differences (CI slower)**
   - **Cause**: CI has less resources, operations take longer
   - **Solution**: Increase timeouts in retry logic, make tests more resilient

2. **Environment variable differences**
   - **Cause**: CI missing required env vars
   - **Solution**: Ensure CI environment has all required variables configured

3. **Resource limits in CI**
   - **Cause**: CI has memory/CPU limits
   - **Solution**: Optimize test resource usage, increase CI resource limits

4. **Parallel test execution issues**
   - **Cause**: CI runs tests in parallel, causing conflicts
   - **Solution**: Use unique identifiers per test, improve test isolation

### General Debugging Commands

```bash
# Full cleanup and restart
docker compose down -v
docker compose up --build -d
docker compose logs -f

# Check service health
docker compose ps
docker compose exec localstack curl http://localhost:4566/_localstack/health

# Enter container for debugging
docker compose exec ams-api-service bash
docker compose exec localstack bash

# Check LocalStack service status
docker compose exec localstack awslocal eks describe-cluster --name test-cluster
docker compose exec localstack awslocal secretsmanager list-secrets

# Run specific test with verbose output
docker compose exec test pytest local_stack/test_file.py::test_name -v -s

# View test container logs
docker compose logs test

# Check network connectivity
docker compose exec ams-api-service ping localstack
docker compose exec ams-api-service curl http://localstack:4566/_localstack/health

# Check mounted volumes
docker compose exec ams-api-service ls -la /tmp/config
docker compose exec localstack ls -la /var/lib/localstack
```

---

## using_across_services

**This skill requires ZERO configuration or modification to work with different services.**

### How It Works Across Services:

1. **Discovery-Driven**: The skill discovers YOUR setup by reading your code
   - Finds your test folder (whatever it's named)
   - Identifies your test framework automatically
   - Maps your infrastructure from Docker Compose
   - Understands your test patterns by reading test files

2. **No Assumptions**: Doesn't assume:
   - Test folder name (`local_stack/` vs `integration_tests/` vs `e2e/`)
   - Test framework (pytest vs jest vs JUnit vs unittest)
   - Infrastructure (LocalStack vs plain PostgreSQL vs Redis+Kafka)
   - Language (Python vs Node vs Java vs Go)
   - Domain (healthcare vs e-commerce vs finance vs IoT)

3. **Adapts to YOUR Patterns**:
   - Uses YOUR naming conventions
   - Follows YOUR test structure
   - Matches YOUR coding style
   - Respects YOUR infrastructure choices

### Example Services This Works With (No Modification):

| Service Type | Infrastructure | Test Framework | Folder Name |
|--------------|---------------|----------------|-------------|
| Healthcare Data Lambda | PostgreSQL + LocalStack | pytest | `local_stack/` |
| E-commerce API | PostgreSQL + Redis + Kafka | jest | `integration_tests/` |
| Payment Gateway | MySQL + RabbitMQ + Mock HTTP | JUnit | `tests/integration/` |
| IoT Data Pipeline | MongoDB + Elasticsearch | pytest | `e2e_tests/` |
| User Auth Service | Redis + PostgreSQL | unittest | `tests/int/` |
| Order Processing | Kafka + PostgreSQL + S3 (LocalStack) | pytest | `integration/` |

### What You Need To Do:

**NOTHING!** Just invoke the skill:
```bash
/localstack-integration improve-tests
/localstack-integration debug-test
/localstack-integration add-coverage
```

The skill will:
1. Discover your project structure
2. Understand your setup
3. Adapt to your patterns
4. Do the work

**That's it.** Use the same skill across ALL your services.

---

## Related Skills & Integration

### Invoked From

**This skill is invoked by `/implement-jira-ticket`** during Phase 5 (Testing) when:
- Implementation changes API behavior
- Implementation modifies data flow
- Implementation affects DB state
- Unit tests alone cannot verify the behavior

### Related Skills

| Skill | Relationship |
|-------|-------------|
| `/implement-jira-ticket` | Invokes this skill for integration test creation |
| `/pytest-best-practices` | Unit test companion - handles unit tests while this skill handles integration tests |

### DB State Verification Pattern (CRITICAL)

**When invoked from implement-jira-ticket context, ALWAYS verify DB state before AND after the action.**

```python
# Example: Testing that enabling data_fetch creates customer_to_cronjobs records

def test_enable_data_fetch_creates_cronjob_mappings(client, db_session):
    """Test that enabling data_fetch creates the expected DB records."""

    # STEP 1: Verify DB state BEFORE action
    # Query DB the same way other tests do - follow existing patterns!
    customer_cronjobs_before = db_session.query(CustomersToCronjobsConfiguration).filter(
        CustomersToCronjobsConfiguration.customer_id == test_customer_id
    ).all()
    assert len(customer_cronjobs_before) == 0, \
        f"Expected 0 records before action, got {len(customer_cronjobs_before)}"

    # STEP 2: Perform the action being tested
    response = client.patch(
        f"/agencies/{agency_id}",
        json={"data_fetch_enabled": True},
        headers={"X-User-ID": "1"}
    )
    assert response.status_code == 200

    # STEP 3: Verify DB state AFTER action
    customer_cronjobs_after = db_session.query(CustomersToCronjobsConfiguration).filter(
        CustomersToCronjobsConfiguration.customer_id == test_customer_id
    ).all()
    assert len(customer_cronjobs_after) > 0, \
        "Expected cronjob mappings to be created after enabling data_fetch"

    # STEP 4: Verify specific values if needed
    for cronjob in customer_cronjobs_after:
        assert cronjob.customer_id == test_customer_id
        assert cronjob.cronjob_configuration_id is not None
```

**Key Rules:**
1. **Follow existing DB query patterns** - Check how other integration tests query the DB and do the same
2. **Assert empty/initial state BEFORE** - Ensures test isolation
3. **Assert expected state AFTER** - Verifies the behavior worked
4. **Check specific values** - Don't just count records, verify their contents
5. **Use the same session pattern** - Match existing tests' session management

### When to Create Integration Tests

From `/implement-jira-ticket` context, create integration tests when:

| Condition | Integration Test Needed |
|-----------|------------------------|
| New API endpoint | Yes - test full flow |
| Modified DB state | Yes - verify before/after state |
| New external service interaction | Yes - verify with LocalStack |
| Changed business flow | Yes - verify end-to-end |
| Bug fix in data handling | Yes - verify correct behavior |

---

**Skill Version**: 2.0.0 (Generic)
**Last Updated**: 2026-01-27
**Supports**: Any test framework, any infrastructure, any language with integration tests
**Minimum Claude Code Version**: Latest