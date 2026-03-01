# Base Coding Conventions

Universal coding standards that apply regardless of language or framework.

## Code Clarity

- **Names must reflect purpose**: `getUserByEmail()` not `getUser()`, `isEmailValid` not `flag`
- **Functions do ONE thing**: If you need "and" to describe it, split it
- **Early returns reduce nesting**: Return early on error/validation before the happy path
- **No magic numbers**: `const MAX_RETRIES = 3` not `if (count > 3)`
- **Avoid abbreviations**: `userId` not `uid`, `configuration` not `cfg`

## Function Design

```
# Good: one responsibility, descriptive name
def validate_email_format(email: str) -> bool:
    return bool(EMAIL_REGEX.match(email))

# Bad: two responsibilities, vague name
def process(data):
    if not data.get("email"):
        return False
    # ... 50 more lines doing many things
```

**Function length:** If a function exceeds ~30 lines, ask "can this be split into smaller functions?" If yes, split. Short functions are easier to test, name, and reuse.

## Error Handling

- **Validate at system boundaries**: User input, external APIs, file reads — not everywhere
- **Fail fast with clear messages**: "User ID must be a positive integer, got: -1" not "Invalid input"
- **Don't swallow errors silently**: `except: pass` is almost always wrong
- **Use typed errors**: Custom exception classes > generic `Error("something went wrong")`

```python
# Good
def get_user(user_id: int) -> User:
    if user_id <= 0:
        raise ValueError(f"user_id must be positive, got {user_id}")
    user = db.find(user_id)
    if user is None:
        raise UserNotFound(f"No user with id={user_id}")
    return user

# Bad
def get_user(user_id):
    try:
        return db.find(user_id)
    except:
        return None  # swallowed error, caller has no idea what went wrong
```

## Constants and Configuration

- Environment variables for configuration (never hardcode URLs, timeouts, limits)
- Constants at module level, named in UPPER_SNAKE_CASE
- Defaults defined explicitly, not scattered through code

## Comments

Comments explain **why**, not **what**:
```python
# BAD: restates the code
# Increment counter
count += 1

# GOOD: explains non-obvious intent
# Retry limit is 3 because downstream API rate limits to 10/min
# and we need headroom for other services
MAX_RETRIES = 3
```

Write comments for: complex algorithms, non-obvious business rules, workarounds for external constraints.

## File Organization

- Group by feature/domain, not by type
- `user/routes.py, user/models.py, user/service.py` > `models/user.py, routes/user.py`
- One primary export per file
- Related code stays close together
