---
name: postgres-patterns
description: "PostgreSQL database patterns for query optimization, schema design, indexing, and security. Use when designing a database schema, writing SQL queries, optimizing slow queries, adding indexes, or asking about database security and migrations."
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
</anti_patterns>

<performance>
- Always `EXPLAIN ANALYZE` before and after optimization
- Index foreign keys (most common miss)
- Use connection pooling in production (PgBouncer)
- Avoid `SELECT *` — specify columns
- Use `LIMIT` on user-facing queries
</performance>

<success_criteria>
- [ ] Foreign keys indexed
- [ ] `EXPLAIN ANALYZE` run on slow queries
- [ ] RLS enabled on multi-tenant tables
- [ ] Connection pooling configured
</success_criteria>
