# Python Conventions

## Framework Selection

```
Building an API?              → FastAPI (async, modern, fast)
Full-stack with admin?        → Django (batteries included)
Simple script or prototype?   → Flask (minimal, flexible)
Background workers?           → Celery + any framework
```

## Code Style

Follow PEP 8. Use type hints everywhere (Python 3.10+):

```python
# Required: type hints on all function signatures
def process_user(user_id: int, include_deleted: bool = False) -> User | None:
    ...

# Use modern union syntax (3.10+)
def parse(value: str | None) -> int | None:
    ...

# Use dataclasses for data structures
from dataclasses import dataclass

@dataclass
class UserProfile:
    user_id: int
    email: str
    name: str | None = None
```

## Project Structure (FastAPI)

```
src/
├── main.py              # App factory, middleware, router registration
├── config.py            # Settings from environment (pydantic-settings)
├── deps.py              # FastAPI dependencies (db session, current user)
├── users/
│   ├── router.py        # Route definitions
│   ├── service.py       # Business logic
│   ├── models.py        # SQLAlchemy models
│   ├── schemas.py       # Pydantic request/response schemas
│   └── repository.py    # Database queries
└── common/
    ├── exceptions.py    # Custom exception types
    └── middleware.py    # Cross-cutting concerns
```

## Async Patterns

```python
# Use async for I/O-bound work
async def get_user(user_id: int, db: AsyncSession) -> User:
    result = await db.execute(select(User).where(User.id == user_id))
    return result.scalar_one_or_none()

# Don't mix sync and async (avoid asyncio.run() inside async code)
# Don't use sync blocking calls in async functions
# For CPU-bound: use ProcessPoolExecutor, not asyncio
```

## Configuration (pydantic-settings)

```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    database_url: str
    secret_key: str
    debug: bool = False
    max_connections: int = 10

    class Config:
        env_file = ".env"

settings = Settings()
```

## Dependency Management

Use `pyproject.toml` (modern standard):
```toml
[tool.poetry.dependencies]
python = "^3.11"
fastapi = "^0.110"
sqlalchemy = "^2.0"
pydantic-settings = "^2.0"

[tool.poetry.group.dev.dependencies]
pytest = "^8.0"
pytest-asyncio = "^0.23"
httpx = "^0.27"
```

Or `pyproject.toml` with uv:
```bash
uv add fastapi sqlalchemy pydantic-settings
uv add --dev pytest pytest-asyncio httpx
```

## Linting and Formatting

```bash
# Format code
ruff format .

# Lint
ruff check .

# Type checking
mypy src/
```

`pyproject.toml`:
```toml
[tool.ruff]
line-length = 100
select = ["E", "F", "I", "UP"]

[tool.mypy]
strict = true
```
