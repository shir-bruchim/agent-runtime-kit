# Common Vulnerability Checklist (OWASP-flavored)

Canonical checklist referenced by the `security` and `pr-review` skills during security reviews.

- [ ] **SQL injection:** parameterized queries everywhere
- [ ] **XSS:** HTML-encode user output, Content-Security-Policy header
- [ ] **CSRF:** tokens on state-changing requests (or SameSite cookies)
- [ ] **Auth bypass:** authorization checked on every protected route
- [ ] **Sensitive data:** passwords hashed, secrets in env vars
- [ ] **Error messages:** no stack traces or internal details in production
- [ ] **Dependencies:** no critical CVEs in direct or transitive deps