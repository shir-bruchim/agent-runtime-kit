# Python Database Patterns (SQLAlchemy 2.0 + PostgreSQL)

## SQLAlchemy 2.0 Models

Use modern `Mapped` annotations (NOT the old `Column()` style):

```python
from sqlalchemy import String, Integer, ForeignKey, Text
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship
from datetime import datetime

class Base(DeclarativeBase):
    pass

class User(Base):
    __tablename__ = "users"
    
    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    email: Mapped[str] = mapped_column(String(255), unique=True, nullable=False, index=True)
    hashed_password: Mapped[str] = mapped_column(String(255), nullable=False)
    is_active: Mapped[bool] = mapped_column(default=True)
    created_at: Mapped[datetime] = mapped_column(default=datetime.utcnow)
    
    # Relationships
    posts: Mapped[list["Post"]] = relationship(back_populates="author", lazy="select")

class Post(Base):
    __tablename__ = "posts"
    
    id: Mapped[int] = mapped_column(primary_key=True)
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    body: Mapped[str] = mapped_column(Text)
    author_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)  # Always index FK!
    
    author: Mapped["User"] = relationship(back_populates="posts")
```

## Async Session Setup

```python
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker

engine = create_async_engine(
    settings.database_url,
    echo=settings.debug,
    pool_size=10,
    max_overflow=20,
)

async_session_factory = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
)

async def get_db() -> AsyncSession:
    async with async_session_factory() as session:
        yield session
```

## Query Patterns

```python
from sqlalchemy import select
from sqlalchemy.orm import selectinload

# Get single record
async def get_user(db: AsyncSession, user_id: int) -> User | None:
    result = await db.execute(select(User).where(User.id == user_id))
    return result.scalar_one_or_none()

# Get with relationship (avoid N+1!)
async def get_user_with_posts(db: AsyncSession, user_id: int) -> User | None:
    result = await db.execute(
        select(User)
        .options(selectinload(User.posts))
        .where(User.id == user_id)
    )
    return result.scalar_one_or_none()

# Create
async def create_user(db: AsyncSession, email: str, hashed_password: str) -> User:
    user = User(email=email, hashed_password=hashed_password)
    db.add(user)
    await db.commit()
    await db.refresh(user)
    return user

# Update
async def update_user_email(db: AsyncSession, user_id: int, new_email: str) -> User | None:
    user = await get_user(db, user_id)
    if user is None:
        return None
    user.email = new_email
    await db.commit()
    await db.refresh(user)
    return user
```

## Alembic Migrations

Setup:
```bash
alembic init alembic
# Edit alembic.ini: sqlalchemy.url = ${DATABASE_URL}
# Edit alembic/env.py: target_metadata = Base.metadata
```

Create and run migrations:
```bash
alembic revision --autogenerate -m "add users table"
alembic upgrade head

# Rollback
alembic downgrade -1
```

Migration template:
```python
def upgrade() -> None:
    op.create_table("users",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("email", sa.String(255), nullable=False),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("email"),
    )
    op.create_index("ix_users_email", "users", ["email"])

def downgrade() -> None:
    op.drop_index("ix_users_email", "users")
    op.drop_table("users")
```

## PostgreSQL-Specific Patterns

```sql
-- Row Level Security (RLS) — multi-tenant
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
CREATE POLICY user_isolation ON posts
    FOR ALL TO app_user
    USING (author_id = current_setting('app.user_id')::int);

-- Partial indexes — index only relevant rows
CREATE INDEX idx_active_users_email ON users(email) WHERE is_active = true;

-- JSONB for flexible data
CREATE TABLE events (
    id SERIAL PRIMARY KEY,
    type VARCHAR(50) NOT NULL,
    payload JSONB NOT NULL
);
CREATE INDEX idx_events_payload ON events USING gin(payload);
```
