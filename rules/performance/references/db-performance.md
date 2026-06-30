# Database Performance

## Avoid N+1 Queries

The most common performance issue:
```python
# BAD: N+1 — 1 query for users + N queries for their posts
users = db.query(User).all()
for user in users:
    print(user.posts)  # Separate query for each user!

# GOOD: Eager loading
users = db.query(User).options(selectinload(User.posts)).all()
```

## Index Rules

- Always index foreign keys
- Index columns frequently used in WHERE, ORDER BY, JOIN
- Check query plans with EXPLAIN ANALYZE
- Composite indexes for multi-column filters

## Connection Pooling

Use connection pooling in production. Don't create a new connection per request.