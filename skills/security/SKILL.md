---
name: security
description: Security review and safe operation patterns. Includes code vulnerability review, dangerous operation blocking patterns, and protected file configuration. Use when reviewing code for security issues, setting up safety hooks, or configuring file protections.
---

<objective>
Two aspects: (1) Review code for security vulnerabilities (OWASP Top 10 and beyond). (2) Configure operational safety via hooks and file protections to prevent accidental damage.
</objective>

<intake>
What would you like to do?

1. **Code review** — Review code for security vulnerabilities
2. **Setup hooks** — Configure safety hooks to block dangerous operations
3. **File protections** — Set up zero-access and read-only path protections
4. **Review patterns** — Learn about common vulnerability patterns

**Wait for response.**
</intake>

<routing>
| Response | Action |
|----------|--------|
| 1, "review", "vulnerabilities" | Run security code review workflow below |
| 2, "hooks", "safety" | See `hooks/` directory — install scripts |
| 3, "file protections", "protect" | See `patterns.yaml` for path protection config |
| 4, "patterns", "learn" | Read `references/owasp.md` |
</routing>

<code_review_workflow>
When reviewing code for security:

**Scan for OWASP Top 10:**
1. Injection (SQL, NoSQL, OS, LDAP)
2. Broken Authentication
3. Sensitive Data Exposure
4. XML External Entities (XXE)
5. Broken Access Control
6. Security Misconfiguration
7. XSS (Cross-Site Scripting)
8. Insecure Deserialization
9. Using Components with Known Vulnerabilities
10. Insufficient Logging & Monitoring

**For each finding:**
- File path and line number
- Severity: Critical / High / Medium / Low
- Explanation of the vulnerability
- Specific remediation code

**Never mark complete without:**
- [ ] Authentication/authorization flows checked
- [ ] All user inputs validated at system boundaries
- [ ] Sensitive data (passwords, tokens, PII) handled correctly
- [ ] No hardcoded credentials or secrets
- [ ] SQL queries parameterized (no string concatenation)
</code_review_workflow>

<hooks_reference>
The `hooks/` directory contains ready-to-install safety scripts:

**protect-files.sh** — Blocks writes to .env, *.pem, and other secret files
**block-dangerous-bash.sh** — Blocks rm -rf, force pushes, and other destructive commands

To install (Claude Code):
```json
// Add to .claude/hooks.json or ~/.claude/hooks.json:
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{"type": "command", "command": "bash ~/.claude/hooks/block-dangerous-bash.sh"}]
      },
      {
        "matcher": "Write|Edit",
        "hooks": [{"type": "command", "command": "bash ~/.claude/hooks/protect-files.sh"}]
      }
    ]
  }
}
```

**Cursor:** No native hook system. Add always-on rules listing operations to never perform.
</hooks_reference>

<success_criteria>
Security review: All OWASP Top 10 categories checked. Findings with severity + specific fixes.
Safety setup: Hooks installed, tested with debug mode, protecting key paths.
</success_criteria>
