---
description: Incrementally fix build and type errors with minimal, safe changes
---

<objective>
Detect build system, parse errors, and fix them one at a time. Guardrails prevent making things worse.
</objective>

<process>
1. **Detect build system** — package.json, tsconfig, Cargo.toml, go.mod, pyproject.toml
2. **Run build** and capture stderr
3. **Group errors** by file path, sort by dependency order
4. **Fix loop** (one error at a time):
   - Read the file (10 lines around error)
   - Diagnose root cause
   - Apply minimal fix via Edit
   - Re-run build to verify
   - Move to next error

**Guardrails — STOP and ask if:**
- A fix introduces more errors than it resolves
- Same error persists after 3 attempts
- Fix requires architectural changes
- Errors stem from missing dependencies
</process>

<success_criteria>
- Errors fixed with file paths listed
- No new errors introduced
- Minimal diffs (no unnecessary refactoring)
- Suggested next steps for any unresolved issues
</success_criteria>
