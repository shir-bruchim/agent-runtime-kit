---
name: verification-loop
description: Verification driven by built-in /loop. Use when verifying an implementation or running a final check before commit.
---

<objective>
Run a multi-phase verification cycle (build → types → lint → tests → security → diff) and produce a structured PASS/FAIL report. Use after completing features, before PRs, or after refactoring.

The looping mechanism is **not** implemented inside this skill — use Claude Code's built-in `/loop` command. This skill only owns the verification checklist (what to verify per phase).
</objective>

<when_to_activate>
- After completing a feature or significant code change
- Before creating a PR
- When asked to verify or validate an implementation
- After refactoring
- As a pre-commit quality gate
</when_to_activate>

<loop_via_builtin>
Claude Code ships a built-in `/loop` that runs a prompt or slash command on a recurring interval (default: 10m, e.g. `/loop 5m /test`). Use it as the procedural backbone for any verification that needs to re-run until green.

Common patterns:

| Goal | Invocation |
|------|------------|
| Re-run the test suite every 5 minutes while you work on a long-running fix | `/loop 5m /test` |
| Re-run the build every 10 minutes | `/loop /build-fix` |
| Re-run a full verification | `/loop 15m "run the verification-loop skill in pre-pr mode and stop when all phases PASS"` |
| One-shot verification (no loop) | Just invoke this skill directly — no `/loop` needed |

Rules:
- Don't roll a homegrown `while/sleep` loop in Bash. `/loop` is interrupt-able, surfaces output cleanly, and respects the session.
- Pick an interval that exceeds the verification's wall-clock — a 10s loop on a 2-min test suite stacks runs.
- Stop the loop the moment the underlying check goes green (`/loop` exits on the user-cancel signal; check after each iteration).

If `/loop` is not available in the current session (very old Claude Code), fall back to invoking this skill once manually after each code change. **Do not** write a custom looping wrapper.
</loop_via_builtin>

<context_scan>
Detect project type and available tools before running phases:
```bash
# Build system
[ -f "package.json" ] && echo "NODE" && (grep -q '"build"' package.json && echo "HAS_BUILD")
[ -f "pyproject.toml" ] && echo "PYTHON"
[ -f "Cargo.toml" ] && echo "RUST"
[ -f "go.mod" ] && echo "GO"

# Test framework
[ -f "pytest.ini" ] || ([ -f "pyproject.toml" ] && grep -q "pytest" pyproject.toml 2>/dev/null) && echo "PYTEST"
[ -f "jest.config.js" ] || [ -f "jest.config.ts" ] && echo "JEST"
[ -f "vitest.config.ts" ] && echo "VITEST"

# Linter
[ -f ".eslintrc.js" ] || [ -f ".eslintrc.json" ] || [ -f "eslint.config.js" ] && echo "ESLINT"
[ -f "ruff.toml" ] || ([ -f "pyproject.toml" ] && grep -q "ruff" pyproject.toml 2>/dev/null) && echo "RUFF"

# Type checker
[ -f "tsconfig.json" ] && echo "TYPESCRIPT"
(command -v pyright >/dev/null || command -v mypy >/dev/null) && echo "PYTHON_TYPES"
```
</context_scan>

<verification_phases>

### Phase 1: Build
```bash
# Node.js
npm run build 2>&1 | tail -20
# Python
python -m py_compile main.py
# Rust
cargo build 2>&1 | tail -20
# Go
go build ./... 2>&1 | tail -20
```
**If build fails, STOP and fix before continuing.**

### Phase 2: Type Check
```bash
# TypeScript
npx tsc --noEmit 2>&1 | head -30
# Python
pyright . 2>&1 | head -30   # or: mypy . 2>&1 | head -30
# Rust / Go — included in build
```

### Phase 3: Lint
```bash
npm run lint 2>&1 | head -30        # JS/TS
ruff check . 2>&1 | head -30        # Python
cargo clippy 2>&1 | head -30        # Rust
golangci-lint run 2>&1 | head -30   # Go
```

### Phase 4: Tests
```bash
npm run test -- --coverage 2>&1 | tail -50
# or: pytest --cov --tb=short 2>&1 | tail -50
# or: cargo test 2>&1 | tail -50
# or: go test ./... -cover 2>&1 | tail -50
```
Target: 80% minimum coverage.

### Phase 5: Security Scan
```bash
# Hardcoded secrets
grep -rn "sk-\|api_key\s*=\s*['\"]" --include="*.py" --include="*.ts" --include="*.js" . 2>/dev/null | head -10
# Debug artifacts
grep -rn "console\.log\|print(\|debugger\b" --include="*.ts" --include="*.tsx" --include="*.py" src/ 2>/dev/null | head -10
# Dependency audit
npm audit 2>/dev/null | tail -5
pip-audit 2>/dev/null | tail -5
```

### Phase 6: Diff Review
```bash
git diff --stat
git diff HEAD~1 --name-only
```
Review each changed file for unintended changes, missing error handling, edge cases.
</verification_phases>

<verification_modes>

| Mode | Phases | Use When |
|------|--------|----------|
| `quick` | Build + Tests | Mid-implementation sanity check |
| `full` (default) | All 6 phases | Before PR or after completing a feature |
| `pre-commit` | Build + Types + Lint + Tests | Before committing |
| `pre-pr` | All 6 + diff review emphasis | Before opening a PR |

For any mode that may need to re-run on code changes, drive it with `/loop` (see `<loop_via_builtin>`).
</verification_modes>

<output_format>
```
VERIFICATION REPORT
==================

Build:     [PASS/FAIL]
Types:     [PASS/FAIL] (X errors)
Lint:      [PASS/FAIL] (X warnings)
Tests:     [PASS/FAIL] (X/Y passed, Z% coverage)
Security:  [PASS/FAIL] (X issues)
Diff:      [X files changed]

Overall:   [READY/NOT READY] for PR

Issues to Fix:
1. ...
2. ...
```
</output_format>

<success_criteria>
- [ ] All phases ran for the detected project type
- [ ] Build passes
- [ ] No type errors (or all acknowledged)
- [ ] No lint errors
- [ ] Tests pass with 80%+ coverage
- [ ] No hardcoded secrets
- [ ] Diff reviewed for unintended changes
- [ ] If iteration was needed, it was driven by `/loop` — not a custom shell loop
</success_criteria>