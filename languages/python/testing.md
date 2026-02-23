# Python Testing (pytest)

## Setup

```bash
pip install pytest pytest-asyncio pytest-mock pytest-cov httpx
```

`pyproject.toml`:
```toml
[tool.pytest.ini_options]
asyncio_mode = "auto"
testpaths = ["tests"]

[tool.coverage.run]
source = ["src"]
omit = ["tests/*"]
```

## Directory Structure

```
tests/
├── conftest.py           # Shared fixtures
├── unit/
│   ├── test_service.py
│   └── test_models.py
├── integration/
│   └── test_api.py       # Tests against real DB (test instance)
└── fixtures/
    └── data.json         # Test data files
```

## Fixtures

```python
# conftest.py
import pytest
import pytest_asyncio
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession

TEST_DATABASE_URL = "postgresql+asyncpg://test:test@localhost/testdb"

@pytest_asyncio.fixture
async def db_session():
    engine = create_async_engine(TEST_DATABASE_URL)
    async with AsyncSession(engine) as session:
        yield session
        await session.rollback()  # Clean up after each test

@pytest_asyncio.fixture
async def client(db_session):
    app.dependency_overrides[get_db] = lambda: db_session
    async with AsyncClient(app=app, base_url="http://test") as client:
        yield client
    app.dependency_overrides.clear()
```

## Writing Tests

```python
# Unit test: isolated, no DB
def test_email_validation_rejects_invalid_format():
    assert not is_valid_email("not-an-email")
    assert not is_valid_email("@example.com")
    assert is_valid_email("user@example.com")

# Parametrize: test multiple inputs
@pytest.mark.parametrize("email,expected", [
    ("user@example.com", True),
    ("not-an-email", False),
    ("", False),
    (None, False),
])
def test_email_validation(email, expected):
    assert is_valid_email(email) == expected

# Integration test: with DB
@pytest.mark.asyncio
async def test_create_user_stores_in_db(db_session):
    user = await create_user(db_session, email="test@example.com")
    
    retrieved = await get_user(db_session, user.id)
    assert retrieved.email == "test@example.com"

# API test: end-to-end with HTTP client
@pytest.mark.asyncio
async def test_login_returns_token(client, test_user):
    response = await client.post("/auth/login", json={
        "email": test_user.email,
        "password": "correct-password"
    })
    
    assert response.status_code == 200
    assert "access_token" in response.json()
```

## Mocking

```python
from pytest_mock import MockerFixture

def test_send_email_calls_service(mocker: MockerFixture):
    mock_send = mocker.patch("app.email.service.send_email")
    
    notify_user(user_id=1, message="Hello")
    
    mock_send.assert_called_once_with(
        to="user@example.com",
        subject="Notification",
        body="Hello"
    )

# Mock async functions
async def test_async_mock(mocker: MockerFixture):
    mocker.patch(
        "app.services.external_api.fetch",
        return_value={"status": "ok"}
    )
    ...
```

## Running Tests

```bash
pytest -v                    # Verbose
pytest -x                    # Stop on first failure
pytest --lf                  # Re-run last failed
pytest -k "test_login"       # Filter by name
pytest --cov=src --cov-report=html  # Coverage report
```
