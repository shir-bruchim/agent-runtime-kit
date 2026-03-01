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
3. **File protections** — Set up protected-path blocking

**Wait for response.**
</intake>

<routing>
| Response | Action |
|----------|--------|
| 1, "review", "vulnerabilities" | Run security code review workflow below |
| 2, "hooks", "safety" | See hooks reference below — install scripts |
| 3, "file protections", "protect" | See hooks reference below — protect-files.sh |
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

**block-dangerous-commands.sh** — Primary hook. Blocks rm -rf /, dd to disks, fork bombs, mkfs, and git force pushes. Exits 2 (hard stop).
**block-dangerous-bash.sh** — Compatibility alias. Delegates to block-dangerous-commands.sh; use when your hooks.json references the "bash" filename.
**protect-files.sh** — Blocks writes to ~/.ssh, ~/.gnupg, ~/.aws/credentials, and any paths in PROTECTED_PATHS or ~/.claude/protected-paths.txt. Exits 2 (hard stop).

To install (Claude Code) — add to `~/.claude/settings.json`:
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{"type": "command", "command": "bash ~/.claude/hooks/block-dangerous-commands.sh"}]
      },
      {
        "matcher": "Write|Edit",
        "hooks": [{"type": "command", "command": "bash ~/.claude/hooks/protect-files.sh"}]
      }
    ]
  }
}
```

Copy hook files: `cp hooks/block-dangerous-commands.sh hooks/block-dangerous-bash.sh hooks/protect-files.sh ~/.claude/hooks/ && chmod +x ~/.claude/hooks/*.sh`
</hooks_reference>

<non_hook_platforms>
**Cursor / GitHub Copilot / Gemini** — no native hook system.

Instead, add a "never do" list to the project's `AGENTS.md` (or `GEMINI.md`) and to the AI's always-on rules:

```
NEVER run: rm -rf /, git push --force, dd to /dev/sd*, mkfs, fork bombs.
NEVER write to: ~/.ssh/, ~/.gnupg/, ~/.aws/credentials, .env files with real secrets.
```

The safety is enforced by instruction, not by a hard block. For high-risk environments, prefer Claude Code with hooks.
</non_hook_platforms>

<success_criteria>
Security review: All OWASP Top 10 categories checked. Findings with severity + specific fixes.
Safety setup: Hooks installed, tested with a blocked command, protecting key paths.
</success_criteria>