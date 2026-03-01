# Security Best Practices

## Input Validation

Validate ALL user input at system boundaries:

```python
# Bad: trusting user input
query = f"SELECT * FROM users WHERE id = {user_id}"

# Good: parameterized query
query = "SELECT * FROM users WHERE id = %s"
cursor.execute(query, (user_id,))
```

**Validation rules:**
- Validate type, length, format, range
- Reject and return 400 for invalid input (don't sanitize silently)
- Use allow-lists over deny-lists (specify valid values, not invalid ones)
- Validate server-side — client-side validation is UX only

## Secrets Management

**Never:**
- Commit secrets (API keys, passwords, tokens) to git
- Log secrets
- Return secrets in API responses
- Store plaintext passwords in database

**Always:**
- Use environment variables for secrets
- Hash passwords with bcrypt/argon2/scrypt (never MD5/SHA1)
- Rotate credentials when team members leave
- Use least-privilege service accounts

```python
# Bad: hardcoded secret
STRIPE_KEY = "sk_live_abc123..."

# Good: from environment
STRIPE_KEY = os.environ["STRIPE_SECRET_KEY"]
```

## Authentication & Authorization

- **Authentication** = who are you? (identity)
- **Authorization** = what can you do? (permissions)

Both must be checked server-side on every request:

```python
# Check auth on every protected endpoint
@router.get("/users/{user_id}/profile")
async def get_profile(user_id: int, current_user: User = Depends(get_current_user)):
    # Authorization: user can only see their own profile
    if current_user.id != user_id and not current_user.is_admin:
        raise HTTPException(status_code=403, detail="Access denied")
    ...
```

**Common auth mistakes:**
- Missing authorization check (authenticated ≠ authorized)
- Client-controlled user IDs ("give me user 99 data" — check they own that resource)
- Insecure direct object reference (IDOR) — user changes `user_id=1` to `user_id=2`
- Missing rate limiting on auth endpoints (brute force)

## Sensitive Data

- Encrypt sensitive fields at rest (PII, payment info)
- Use HTTPS always (no HTTP in production)
- Don't log sensitive data (passwords, full tokens, PII)
- Minimum necessary data collection

## Dependency Security

- Keep dependencies updated (security patches)
- Audit dependencies: `npm audit`, `pip-audit`, `cargo audit`
- Don't use abandoned packages
- Review transitive dependencies for critical packages

## Common Vulnerability Checklist

- [ ] SQL injection: parameterized queries everywhere
- [ ] XSS: HTML-encode user output, Content-Security-Policy header
- [ ] CSRF: tokens on state-changing requests (or SameSite cookies)
- [ ] Auth bypass: authorization checked on every protected route
- [ ] Sensitive data: passwords hashed, secrets in env vars
- [ ] Error messages: no stack traces or internal details in production
- [ ] Dependencies: no critical CVEs in direct or transitive deps
