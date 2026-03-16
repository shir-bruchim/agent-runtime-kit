# Deep Security Review

Comprehensive security review across 10 dimensions. Goes deeper than `rules/security.md` (which defines conventions) — this workflow provides checklists, verification steps, and code-level patterns for active security review.

## Relationship to Rules

This workflow EXTENDS `rules/security.md` — it does not replace it.
- `rules/security.md` = always-loaded conventions (input validation, secrets, auth basics)
- This workflow = on-demand deep review with checklists and verification steps

Load this workflow when actively reviewing security, not for general coding.

## When to Activate

- Implementing authentication or authorization
- Handling user input or file uploads
- Creating new API endpoints
- Working with secrets or credentials
- Implementing payment or sensitive features
- Storing or transmitting sensitive data
- Integrating third-party APIs
- Pre-deployment security audit

## Security Dimensions

### 1. Secrets Management
- [ ] No hardcoded API keys, tokens, or passwords in source
- [ ] All secrets in environment variables
- [ ] `.env*` files in `.gitignore`
- [ ] No secrets in git history (`git log -p -S "password"`)
- [ ] Production secrets in hosting platform / secrets manager

### 2. Input Validation
- [ ] All user inputs validated with schemas (Zod, Pydantic, etc.)
- [ ] File uploads restricted (size, type, extension)
- [ ] No direct use of user input in queries or shell commands
- [ ] Allow-list validation (not deny-list)
- [ ] Error messages don't leak internal details

### 3. Injection Prevention
- [ ] All database queries use parameterized queries / ORM
- [ ] No string concatenation in SQL
- [ ] No `eval()`, `exec()`, or shell injection vectors with user input
- [ ] Template engines auto-escape output

### 4. Authentication & Authorization
- [ ] Tokens in httpOnly cookies (not localStorage)
- [ ] Authorization checked on every protected endpoint
- [ ] Role-based or resource-based access control
- [ ] Session management secure (expiry, rotation)
- [ ] IDOR protection (users can't access other users' resources)

### 5. XSS Prevention
- [ ] User-provided HTML sanitized (DOMPurify or equivalent)
- [ ] Content-Security-Policy headers configured
- [ ] No unvalidated dynamic content rendering
- [ ] Framework auto-escaping enabled

### 6. CSRF Protection
- [ ] CSRF tokens on state-changing operations
- [ ] SameSite=Strict on all cookies
- [ ] Origin/Referer header validation

### 7. Rate Limiting
- [ ] Rate limiting on all API endpoints
- [ ] Stricter limits on auth endpoints and expensive operations
- [ ] IP-based and user-based limiting

### 8. Sensitive Data Exposure
- [ ] No passwords, tokens, or PII in logs
- [ ] Error messages generic for users (detailed only in server logs)
- [ ] No stack traces exposed in production
- [ ] HTTPS enforced

### 9. Dependency Security
- [ ] No known vulnerabilities (`npm audit` / `pip-audit` / `cargo audit`)
- [ ] Lock files committed
- [ ] Automated dependency updates (Dependabot/Renovate)

### 10. Database Security
- [ ] Row Level Security enabled (if using Supabase/Postgres)
- [ ] Least-privilege database users
- [ ] Connection pooling in production
- [ ] Migrations reviewed for data safety

## Pre-Deployment Checklist

Before ANY production deployment, verify all 10 dimensions above. Flag items as:
- **CRITICAL** — Must fix before merge (secrets exposure, injection, auth bypass)
- **HIGH** — Should fix before merge (missing validation, no rate limiting)
- **MEDIUM** — Fix soon (missing CSP headers, verbose error messages)

## Output Format

```markdown
## Security Review: [Feature/Component]

### Critical Issues
- `path/to/file:42` — [Issue description]. [Remediation].

### High Issues
- `path/to/file:17` — [Issue description]. [Remediation].

### Medium Issues
- `path/to/file:88` — [Issue description]. [Remediation].

### Passed
- Secrets: No hardcoded secrets found
- Auth: Authorization checks present on all endpoints
- ...

### Summary
| Dimension | Status |
|-----------|--------|
| Secrets Management | PASS/FAIL |
| Input Validation | PASS/FAIL |
| ... | ... |
```

## Success Criteria

- [ ] All 10 security dimensions checked
- [ ] Every finding has severity + specific file:line + remediation
- [ ] No CRITICAL issues remain unaddressed
- [ ] Review references `rules/security.md` for project conventions
