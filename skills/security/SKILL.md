---
name: security
description: Security review and safe-op patterns. Use when reviewing for vulnerabilities, setting up hooks, or protecting files.
---

<objective>
Two aspects: (1) Review code for security vulnerabilities (OWASP Top 10 and beyond). (2) Configure operational safety via hooks and file protections to prevent accidental damage.
</objective>

<intake>
What would you like to do?

1. **Code review** — Review code for security vulnerabilities
2. **Setup hooks** — Configure safety hooks to block dangerous operations
3. **File protections** — Set up protected-path blocking
4. **Deep review** — Comprehensive security audit across 10 dimensions with checklists

**Wait for response.**
</intake>

<routing>
| Response | Action |
|----------|--------|
| 1, "review", "vulnerabilities" | Run security code review workflow below |
| 2, "hooks", "safety" | See `workflows/setup-hooks.md` — install scripts |
| 3, "file protections", "protect" | See `workflows/setup-hooks.md` — protect-files.sh |
| 4, "deep review", "comprehensive", "audit" | See `workflows/deep-review.md` — comprehensive 10-dimension security audit with checklists |
</routing>

<code_review_workflow>
When reviewing code for security:

**Scan for OWASP Top 10.** Reference the canonical checklist in `~/.claude/rules/security/references/owasp-checklist.md` (the entry pointer lives at `~/.claude/rules/security/RULE.md` §"OWASP / Common Vulnerability Checklist"). Don't re-list categories here; for each match, capture `file:line + severity + remediation` per the per-finding format below.

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