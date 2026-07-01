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

### Error translation at the logic-layer boundary

Storage-layer exceptions (`IntegrityError`, `DataError`, deadlock, serialization failures) get translated to domain-appropriate errors at the LOGIC layer — not inside CRUD helpers (transaction hasn't committed) and not inside route handlers (workers need the same mapping). Every entry point — API routes, SQS consumers, cron jobs, batch scripts — wraps its unit of work in one shared helper:

```python
# app/logic/util.py
async def with_integrity_translation(work, *, context: str):
    try:
        return await work()
    except IntegrityError as exc:
        code = getattr(exc.orig, "pgcode", None)
        if code == "23505":  # unique_violation
            raise HTTPConflict(f"{context}: unique constraint violation") from exc
        if code == "23503":  # foreign_key_violation
            raise HTTPUnprocessable(f"{context}: referenced entity missing") from exc
        if code == "23502":  # not_null_violation
            raise HTTPUnprocessable(f"{context}: required field missing") from exc
        raise
```

Why here and not elsewhere:
- **Not in CRUD** — the transaction hasn't committed yet; CRUD helpers should stay session-agnostic and let integrity errors bubble.
- **Not in routes** — a new consumer (SQS worker, backfill script, cron job) would silently miss the mapping. Logic owns transaction boundaries → logic owns error translation.
- **Not repeated per entry point** — every fresh call site would drift. One helper, `pgcode`-driven mapping, every entry point wraps.

Route handlers only translate HTTP-specific concerns (auth, rate limits); domain errors bubble up already-shaped.
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
Universal DB performance rules (EXPLAIN ANALYZE, index FKs, connection pooling, avoid `SELECT *`, LIMIT on user-facing queries) live in `~/.claude/rules/performance/references/db-performance.md` (summary in `~/.claude/rules/performance/RULE.md`). PostgreSQL-specific patterns (GIN/BRIN, RLS, FOR UPDATE SKIP LOCKED) below.
</performance>

<success_criteria>
- [ ] Foreign keys indexed
- [ ] `EXPLAIN ANALYZE` run on slow queries
- [ ] RLS enabled on multi-tenant tables
- [ ] Connection pooling configured
</success_criteria>
