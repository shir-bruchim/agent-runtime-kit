---
name: verification-loop
description: "A comprehensive verification system for Claude Code sessions. Use when verifying an implementation is complete, validating code correctness, running a final check before committing, or asking to verify all requirements are met."
---

<objective>
Run a multi-phase verification loop that checks build, types, lint, tests, security, and diff review. Produces a structured PASS/FAIL report. Use after completing features, before PRs, or after refactoring.
</objective>

<when_to_activate>
- After completing a feature or significant code change
- Before creating a PR
- When asked to verify or validate an implementation
- After refactoring
- As a pre-commit quality gate
</when_to_activate>

<context_scan>
Detect project type and available tools:
```bash
# Build system
[ -f "package.json" ] && echo "NODE" && (grep -q '"build"' package.json && echo "HAS_BUILD")
[ -f "pyproject.toml" ] && echo "PYTHON"
[ -f "Cargo.toml" ] && echo "RUST"
[ -f "go.mod" ] && echo "GO"
[ -f "pom.xml" ] && echo "JAVA_MAVEN"
[ -f "build.gradle" ] && echo "JAVA_GRADLE"

# Test framework
[ -f "pytest.ini" ] || [ -f "pyproject.toml" ] && grep -q "pytest" pyproject.toml 2>/dev/null && echo "PYTEST"
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
python -m py_compile main.py  # or check import

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
pyright . 2>&1 | head -30
# or: mypy . 2>&1 | head -30

# Rust (included in build)
# Go (included in build)
```

### Phase 3: Lint
```bash
# JavaScript/TypeScript
npm run lint 2>&1 | head -30

# Python
ruff check . 2>&1 | head -30

# Rust
cargo clippy 2>&1 | head -30

# Go
golangci-lint run 2>&1 | head -30
```

### Phase 4: Tests
```bash
# Run tests with coverage
npm run test -- --coverage 2>&1 | tail -50
# or: pytest --cov --tb=short 2>&1 | tail -50
# or: cargo test 2>&1 | tail -50
# or: go test ./... -cover 2>&1 | tail -50
```
Target: 80% minimum coverage.

### Phase 5: Security Scan
```bash
# Check for hardcoded secrets
grep -rn "sk-\|api_key\s*=\s*['\"]" --include="*.py" --include="*.ts" --include="*.js" . 2>/dev/null | head -10

# Check for debug artifacts
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
| `quick` | Build + Tests | Quick sanity check mid-implementation |
| `full` (default) | All 6 phases | Before PR or after completing feature |
| `pre-commit` | Build + Types + Lint + Tests | Before committing |
| `pre-pr` | All 6 + diff review emphasis | Before opening PR |
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
- [ ] All phases run for detected project type
- [ ] Build passes
- [ ] No type errors (or all acknowledged)
- [ ] No lint errors
- [ ] Tests pass with 80%+ coverage
- [ ] No hardcoded secrets
- [ ] Diff reviewed for unintended changes
</success_criteria>
