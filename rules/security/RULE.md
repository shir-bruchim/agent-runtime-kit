---
name: security
description: Security best practices — input validation, secrets management, authN/authZ, sensitive data handling, dependency hygiene.
---

# Security Guardrails

- **Input:** validate type/length/format/range at boundaries; parameterized queries only (never f-string SQL); allow-lists over deny-lists; reject with 400, don't silently sanitize; server-side (client validation is UX only).
- **Secrets:** never commit/log/return them; env vars only; hash passwords with bcrypt/argon2/scrypt (never MD5/SHA1).
- **AuthN ≠ AuthZ:** check both server-side on every protected route. Guard against IDOR — a user changing `user_id=1` to `=2` must be rejected; rate-limit auth endpoints.
- **Sensitive data:** HTTPS always; encrypt PII/payment at rest; don't log passwords/tokens/PII; collect the minimum.
- **Deps:** keep updated; audit (`pip-audit`, `npm audit`); no abandoned packages.

Full OWASP Top-10 review checklist and safe-op patterns live in the lazy `security` skill — invoke it for reviews.
