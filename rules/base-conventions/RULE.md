---
name: base-conventions
description: Universal coding standards (naming, function design, error handling, comments, file organization) that apply regardless of language or framework.
---

# Base Coding Conventions

Universal coding standards that apply regardless of language or framework.

## Code Clarity

- **Names must reflect purpose**: `getUserByEmail()` not `getUser()`, `isEmailValid` not `flag`
- **Functions do ONE thing**: If you need "and" to describe it, split it
- **Early returns reduce nesting**: Return early on error/validation before the happy path
- **No magic numbers**: `const MAX_RETRIES = 3` not `if (count > 3)`
- **Avoid abbreviations**: `userId` not `uid`, `configuration` not `cfg`
- **Never reach for `hasattr` / `getattr` / reflection when you know the type.** You wrote the function signature, you know what object you pass and accept — so you know whether the attribute exists. Just access `obj.attribute` directly. Same applies to `dict.get(key, default)` when you know the key is always present (use `obj["key"]`). Reflection is for genuinely-dynamic dispatch (plugin loaders, ORM column iteration); it's NOT for "I'm too lazy to track which fields a dataclass has." Bad code: `getattr(resources, attr_name).extend(ids)`. Good code: `getattr` is fine for SAFETY against a not-yet-set attribute on a *third-party* object you don't control, but inside your own modules where you wrote the dataclass — use a `dict[str, list]` keyed by name, or explicit per-attribute assignment.
- **Never mutate source files via `python -c`, `sed -i`, `awk -i inplace`, or heredoc redirection.** Use `Read` → `Edit` (or `Write`) exclusively for any file tracked in git — including tests, Dockerfiles, CI configs, Terraform, migrations. Inline shell mutation bypasses the diff preview and any protect-files hooks, and mangles multi-line content silently. `Edit` also requires a prior `Read`, so it fails loudly when you didn't inspect the file first. Bash is fine for the file's *content* being read into a variable or piped elsewhere — it's the WRITE path that must go through the tool.
- **Write to the project's linter on the first pass.** Before writing style-sensitive code (column-aligned dicts, wide tables, long import blocks), check the project's lint config (`.flake8`, `.eslintrc`, `pyproject.toml`, `tsconfig.json`, etc.) for the constraints — line length, alignment rules (e.g., flake8 E241 forbids multiple spaces after `:`), unused-import rules, trailing-newline rules. Write to the config from the start; don't ship pretty-but-lint-failing code planning to fix in a formatter pass. Pre-commit / pre-push hooks reject the push and force an amend cycle. Alignment for readability belongs in a comment header (`# col1  col2  col3`) — never inside the code the linter parses.

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

**Default is NO comment.** Add one only when a naive reader would ask "why this weird construction?" and the answer is a specific past bug or a subtle invariant — kept to ONE line. When editing code that already has a comment block, trim it, don't extend it. Rationale citing PR history, options-not-taken, or restating what the code obviously does — delete before showing the edit. Terse over verbose; well-named identifiers already explain WHAT.

## File Organization

- Group by feature/domain, not by type
- `user/routes.py, user/models.py, user/service.py` > `models/user.py, routes/user.py`
- One primary export per file
- Related code stays close together