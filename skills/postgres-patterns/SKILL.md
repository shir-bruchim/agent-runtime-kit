---
name: postgres-patterns
description: "PostgreSQL patterns for queries, schema, indexing, security. Use when writing SQL, designing schema, or adding indexes."
---

<objective>
PostgreSQL best practices for schema design, indexing, query optimization, and security. Quick-reference cheat sheets for common patterns.
</objective>

<when_to_activate>
- Designing database schema
- Writing or optimizing SQL queries
- Adding indexes for performance
- Setting up Row Level Security
- Creating migrations
</when_to_activate>

<index_cheat_sheet>

| Index Type | Best For | Example |
|-----------|---------|---------|
| B-tree (default) | Equality, range, sorting | `CREATE INDEX idx_email ON users(email)` |
| GIN | Full-text search, JSONB, arrays | `CREATE INDEX idx_tags ON posts USING gin(tags)` |
| BRIN | Large tables with natural ordering | `CREATE INDEX idx_created ON logs USING brin(created_at)` |
| Composite | Multi-column filters | `CREATE INDEX idx_status_date ON orders(status, created_at)` |
| Partial | Filtered subsets | `CREATE INDEX idx_active ON users(email) WHERE active = true` |
| Covering | Include columns to avoid table lookup | `CREATE INDEX idx_cover ON users(email) INCLUDE (name)` |

**Composite index ordering:** Most selective column first, then range columns.
</index_cheat_sheet>

<common_patterns>

### UPSERT (Insert or Update)
```sql
INSERT INTO users (email, name) VALUES ($1, $2)
ON CONFLICT (email) DO UPDATE SET name = EXCLUDED.name, updated_at = NOW();
```

**Prefer UPSERT over get-before-insert** for idempotent writes: one round-trip, race-free (no TOCTOU gap that a concurrent/redelivered write slips through). Requires a unique **index** (or PK) on the conflict target — `ON CONFLICT (cols)` (and SQLAlchemy `index_elements=[...]`) **infers any** unique index on those columns; you only reference a name with `ON CONFLICT ON CONSTRAINT <name>`. So the uniqueness can be a plain `CREATE UNIQUE INDEX` — including an online `CREATE UNIQUE INDEX CONCURRENTLY` (see partitioned-tables below) instead of a blocking `ADD CONSTRAINT ... UNIQUE`; the upsert works identically. Pick the clause by what you need back:
- `ON CONFLICT DO NOTHING` returns **no row on conflict** → `RETURNING id` yields nothing when the row already existed; add a SELECT-by-natural-key fallback (or `DO UPDATE SET id = id RETURNING id`) when the caller needs the id.
- `ON CONFLICT ... DO UPDATE ... RETURNING` always returns the row but **rewrites** it (bumps `updated_at`, fires triggers, WAL/bloat) even on a no-op — use only when you actually want the write.
- Pre-PG15, `NULL`s are **distinct** in a unique index (rows with a NULL key never conflict); use `NULLS NOT DISTINCT` (PG15+) if a NULL should collide.

### Cursor Pagination (better than OFFSET)
```sql
SELECT * FROM posts WHERE created_at < $1 ORDER BY created_at DESC LIMIT 20;
```

### Row Level Security
```sql
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users see own docs" ON documents
  FOR SELECT USING (auth.uid() = owner_id);
```

### Queue Pattern (FOR UPDATE SKIP LOCKED)
```sql
WITH next_job AS (
  SELECT id FROM jobs WHERE status = 'pending'
  ORDER BY created_at LIMIT 1
  FOR UPDATE SKIP LOCKED
)
UPDATE jobs SET status = 'processing' WHERE id = (SELECT id FROM next_job)
RETURNING *;
```

### Partitioned tables — FKs and concurrent index builds

- **No single-column FK to a partitioned parent with a composite PK.** A partitioned table's unique constraint/PK must include the partition key, so `REFERENCES parent(id)` (id alone) is not creatable — Postgres rejects it. Model the relation with an app-level link table (no DB FK) and enforce integrity in the application.
- **`CREATE INDEX CONCURRENTLY` can't run in a transaction and isn't supported on a partitioned parent.** Build it online per-partition: `CREATE INDEX ... ON ONLY <parent>` (catalog-only, INVALID) → `CREATE INDEX CONCURRENTLY` on each existing partition (generate via psql `\gexec`) → `ALTER INDEX <parent> ATTACH PARTITION <child>` (parent auto-validates once all children attach). Diagnostic: the parent index's `indisvalid = false` (relkind `I`) means a partition is still unattached — check `count(pg_inherits WHERE inhparent = '<parent_index>'::regclass)` equals the partition count.
- **Dropping on a partitioned table:** you canNOT `DROP INDEX CONCURRENTLY` a partitioned (parent) index — use a plain `DROP INDEX <parent>` (it cascades to the attached child indexes). A backing index of a UNIQUE **constraint** can't be dropped directly (`ERROR: cannot drop index ... because constraint ... requires it`) — drop the constraint with `ALTER TABLE ... DROP CONSTRAINT`. On dev, the simplest rebuild of a partitioned unique index is one blocking `CREATE UNIQUE INDEX <parent> (cols)` (no `ON ONLY`) — it recursively builds + attaches every child in one statement.
- **`\gexec` (and every psql `\`-meta-command: `\copy`, `\set`) run ONLY under `psql`.** A migration that generates DDL via `\gexec` and is executed through a non-psql client (JDBC, DataGrip, DBeaver, an ORM driver) silently runs just the plain SQL and skips the generated statements — e.g. it creates the `ON ONLY` parent index but attaches **zero** partitions, leaving it INVALID. Migrations using `\gexec`/`\copy` MUST run via `psql -f`; confirm the deploy runner uses psql (not a driver).

### Async SQLAlchemy 2.x — multi-entity selects preserve Row tuples

`select(A, B)` returns Row objects. Calling `.scalars()` on the result unpacks only the FIRST entity — the rest silently disappear. Pick the API by shape, not by habit:

```python
# Single-entity select → .scalars() collapses Row → entity
rows = (await session.execute(select(A))).scalars().all()
# → list[A]

# Multi-entity select → .all() preserves Row tuples
rows = (await session.execute(select(A, B))).all()
# → list[Row]; unpack: for a, b in rows: ...

# Aggregate/column select → .all() returns Row of scalars
rows = (await session.execute(select(func.count(A.id), A.status))).all()
# → list[Row]; unpack: for count, status in rows: ...
```

**Base-class helper trap.** A generic `execute_row_list_query` that always calls `.scalars().all()` breaks multi-entity callers silently — `select(A, B)` returns `list[A]` with `B` gone. Either name the helpers by shape (`execute_entity_list_query` vs `execute_row_list_query`) or pass a `mode: Literal["scalars", "rows"]` argument.

**AsyncMock test trap.** When mocking `session.execute`, `.scalars().all()` and `.all()` must both return correct shapes. A test that only sets `.scalars.return_value.all.return_value = [...]` passes even when prod is calling `.all()` and getting a MagicMock back. Fixture recipe:

```python
result = MagicMock()
result.scalars.return_value.all.return_value = entity_list  # for single-entity
result.all.return_value = row_tuples                        # for multi-entity
session.execute = AsyncMock(return_value=result)
```

### Error translation at the logic-layer boundary

Storage-layer exceptions (`IntegrityError`, `DataError`, deadlock, serialization failures) get translated to domain-appropriate errors at the LOGIC layer — not inside CRUD helpers (transaction hasn't committed) and not inside route handlers (workers need the same mapping). Every entry point — API routes, SQS consumers, cron jobs, batch scripts — wraps its unit of work in one shared helper:

```python
# app/logic/util.py
async def with_integrity_translation(work, *, context: str):
    try:
        return await work()
    except IntegrityError as exc:
        # Async ORM drivers wrap the driver exception in their own dbapi shim;
        # the real driver exception is at `.orig.__cause__`, not `.orig`.
        # For sync drivers `.__cause__` is None → falls back to `.orig`.
        driver_exc = getattr(exc.orig, "__cause__", None) or exc.orig
        code = getattr(driver_exc, "pgcode", None)
        if code == "23505":  # unique_violation
            raise HTTPConflict(f"{context}: unique constraint violation") from exc
        if code == "23503":  # foreign_key_violation
            raise HTTPUnprocessable(f"{context}: referenced entity missing") from exc
        if code == "23502":  # not_null_violation
            raise HTTPUnprocessable(f"{context}: required field missing") from exc
        raise
```

**Driver-wrapping trap.** Async engines (SQLAlchemy `postgresql+asyncpg`, and equivalents in other stacks) route every raw driver exception through the ORM's own dbapi shim (`raise translated_error from error`), so `exc.orig` is the shim and the real exception is at `exc.orig.__cause__`. A `getattr(exc.orig, "pgcode", …)` typed-dispatch that works on the sync driver returns `None` on async and every branch falls through. Diagnostic tell: the response payload contains `<class 'asyncpg.exceptions.XxxError'>: <message>` — that's the shim's `"%s: %s" % (type, error)` format. Unit-test fakes must mirror the wrapping shape (`dbapi_exc.__cause__ = real_driver_exc`), or CI catches what local tests miss.

Why here and not elsewhere:
- **Not in CRUD** — the transaction hasn't committed yet; CRUD helpers should stay session-agnostic and let integrity errors bubble.
- **Not in routes** — a new consumer (SQS worker, backfill script, cron job) would silently miss the mapping. Logic owns transaction boundaries → logic owns error translation.
- **Not repeated per entry point** — every fresh call site would drift. One helper, `pgcode`-driven mapping, every entry point wraps.

Route handlers only translate HTTP-specific concerns (auth, rate limits); domain errors bubble up already-shaped.

### Two-tier session split — only when composed cross-module

The pattern `foo_in_session(db, ...)` (accepts an existing transaction) + `foo(...)` (opens a session and delegates) is useful when a second logic module wants to call `foo` inside its own transaction. It is NOT useful as a default: adding the split everywhere doubles the module surface, forces callers to pick the right variant, and slows every future rename.

Rule: add the `_in_session` variant only after grepping and confirming an actual cross-module caller needs to compose the work inside its own transaction. Without a caller, keep one function that opens the session. Verified failure mode: adding variants speculatively to N modules forces a full reversal pass when the split turns out unused; the graph of "who needs to reuse whose session" is easier to read from grep than from anticipation.
</common_patterns>

<anti_patterns>
Detect with:
```sql
-- Missing indexes on foreign keys
SELECT c.conname, c.conrelid::regclass, a.attname
FROM pg_constraint c JOIN pg_attribute a ON a.attnum = ANY(c.conkey) AND a.attrelid = c.conrelid
WHERE c.contype = 'f' AND NOT EXISTS (
  SELECT 1 FROM pg_index i WHERE i.indrelid = c.conrelid AND a.attnum = ANY(i.indkey)
);

-- Unused indexes
SELECT indexrelname, idx_scan FROM pg_stat_user_indexes WHERE idx_scan = 0;
```

### ORM query-API selection

- **Match query API to data invariant, not method ergonomics.** "Exactly one" APIs (SQLAlchemy 2.x `scalar_one_or_none`, EF Core `Single()`, Django `.get()`) raise when the result set has 2+ rows — that's correct when uniqueness is enforced at the schema, and the wrong behavior when duplicates are valid data the caller wants any-one-of. Use `.first()` / `LIMIT 1` / `FirstOrDefault()` for the latter. If you're unsure whether duplicates are possible, the schema is your source of truth — check the unique constraints before picking the API. A test against a real DB with duplicates (or a mocked Result that simulates them) catches the wrong choice cheaply.

### ORM-vs-prod-DDL drift

- **The prod DDL is the source of truth; the ORM file is a projection.** When they diverge, the ORM is wrong. Two common drifts that ship silently:
  - **Missing columns.** The ORM doesn't map `tagging_bookmark TIMESTAMP` that exists in prod → inserts/updates silently drop the value (the column is `None`-defaulted client-side, the DB stores NULL or the column's server default). Reads via `Model.dict()` omit the column entirely. The failure mode is silent data loss until a downstream consumer notices a NULL where they expected a value.
  - **Missing `nullable=False` on prod NOT NULL columns.** SQLAlchemy emits CREATE TABLE with NULL-permitting columns for the local test stack, so locally the service can write `NULL` and the test stack accepts it. In prod the same write blows up with `IntegrityError: null value in column "X" violates not-null constraint`. Local tests stayed green; prod broke.
- **Detect by comparing prod DDL to the ORM file column-by-column.** When a column list is handed to you, check name, type, nullability, default. Missing columns get added (`Column(<type>, ...)`); prod NOT NULL columns need `nullable=False` to make the local stack's CREATE TABLE match prod's invariant.
- **Schemas don't need to expose every column.** If `tagging_bookmark` exists in prod but no API touches it, the ORM still maps it (so reads round-trip and inserts don't drop it), but Pydantic schemas can omit it — silent column drops are different from intentional schema exclusion.
</anti_patterns>

<performance>
Universal DB performance guardrails (EXPLAIN ANALYZE, index FKs, connection pooling, no N+1) live in `~/.claude/rules/performance/RULE.md`. PostgreSQL-specific patterns (GIN/BRIN, RLS, FOR UPDATE SKIP LOCKED, avoid `SELECT *`, LIMIT user-facing queries) below.
</performance>

<success_criteria>
- [ ] Foreign keys indexed
- [ ] `EXPLAIN ANALYZE` run on slow queries
- [ ] RLS enabled on multi-tenant tables
- [ ] Connection pooling configured
</success_criteria>
