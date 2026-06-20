---
name: pr-review
description: "Reviews a GitHub pull request diff and produces a structured report covering correctness, security, best practices, and test coverage. Use when asked to review a PR, check a pull request, analyze a diff, or validate code before merging."
allowed-tools: Bash, Read, Grep, Glob
---

<objective>
Fetch a PR diff via `gh`, analyze it across 5 dimensions, and output a structured review report with inline findings. Universal — works for any language.
</objective>

<when_to_activate>
- User says "review PR", "review this pull request", "check PR #123"
- User pastes a GitHub PR URL and asks for feedback
- After creating a PR with `/pr` and wanting self-review before requesting teammates
</when_to_activate>

<workflow>

### Step 0 — Ordering when both PR comments and CI failures exist

If the user's request includes BOTH unresolved bot/reviewer comments AND a CI run, address comments FIRST, then check CI:

1. Fetch and address unresolved bot/reviewer comments via `gh api repos/<o>/<r>/pulls/<n>/comments`. Reply per-thread with rationale (apply / declined-with-reason / false-positive).
2. THEN inspect CI failure logs.

Bot comments often explain or contextualize the CI failure. Reading CI first risks fixing a symptom that the bot already proposed a different fix for.

### Step 1 — Fetch PR Diff
```bash
# By PR number (current repo)/
gh pr diff <number>

# Get PR metadata
gh pr view <number> --json title,body,additions,deletions,changedFiles,baseRefName,headRefName
```

### Step 2 — Categorize Changed Files
- `src/` or app code → logic review
- `tests/` → test quality review
- Config files (`*.toml`, `*.yml`, `*.env*`) → secrets + config review
- Migrations → database safety review
- Lock files, generated files → skip

### Step 3 — Analyze Across 5 Dimensions

#### A. Correctness
- Logic errors, off-by-one, null/None handling
- Edge cases not covered
- Incorrect assumptions about input types

#### B. Security (CRITICAL — flag immediately)
- Hardcoded secrets, API keys, passwords
- SQL injection (string formatting into queries)
- Unsanitized user input passed to shell/eval/exec
- Insecure deserialization
- Path traversal vulnerabilities

#### C. Best Practices (language-aware)
- Mutable default arguments (Python: `def f(x=[])`)
- Bare `except:` / empty `catch` clauses
- Missing type annotations on public functions
- Functions >50 lines, files >800 lines
- Magic numbers / hardcoded values

#### D. Test Coverage
- Are new functions covered by tests?
- Are edge cases tested?
- Are exception paths tested?
- Are external calls mocked?
- Coverage appears to meet 80%+ threshold?

#### E. Code Quality
- Naming clarity (functions, variables, classes)
- Duplication (same logic appears 2+ times)
- Deep nesting (>4 levels)
- Commented-out code left in
</workflow>

<decision_logic>
- **No PR number/URL provided** → Ask for it
- **`gh` not authenticated** → Show `gh auth login` instructions
- **PR has >50 changed files** → Focus on `src/`, `app/`, core logic; skip lock/generated files
- **Security issue found (CRITICAL)** → Flag at top of report before anything else
- **No tests changed but logic changed** → Flag: "No tests added/modified for changed logic"
- **Only docs changed** → Skip security/logic; focus on clarity and accuracy
</decision_logic>

<output_format>
```markdown
## PR Review: <title> (#<number>)

**Branch**: `<head>` → `<base>`
**Changes**: +<additions> / -<deletions> across <N> files

---

### CRITICAL Issues
(Security or correctness blockers — must fix before merge)

- `path/to/file:42` — **Issue**. Remediation.

---

### Warnings
(Should fix — code quality, missing tests, non-critical bugs)

- `path/to/file:17` — **Issue**. Remediation.

---

### Suggestions
(Nice to have — style, naming, minor improvements)

- `path/to/file:88` — Suggestion.

---

### Looks Good
- Items that passed review

---

### Summary
| Dimension | Status |
|-----------|--------|
| Correctness | PASS / WARN / FAIL |
| Security | PASS / WARN / FAIL |
| Best Practices | PASS / WARN / FAIL |
| Test Coverage | PASS / WARN / FAIL |
| Code Quality | PASS / WARN / FAIL |

**Verdict**: APPROVE / REQUEST CHANGES / NEEDS DISCUSSION
```
</output_format>

<success_criteria>
- [ ] All 5 dimensions analyzed for every changed file
- [ ] CRITICAL issues flagged at top with file:line and remediation
- [ ] Verdict clearly stated
- [ ] No false positives on generated/lock files
</success_criteria>

<self_review_first>
Before presenting any non-trivial change as "complete", run the project-specific lens (if any) below on your own diff. Apply review-grade cleanups during the initial implementation, not after. Common easy wins:

- Two near-identical helpers in two siblings? Extract to the base on the first pass, not the third.
- Repeating a string literal across multiple files? Module-level constant on the first pass.
- Reusable test factory in two test files? Conftest fixture, not a private helper per file.
- Comment carrying a ticket prefix? Strip the prefix; ticket history belongs in PR/git, not in code.
- Trailing newlines on every file you touch — fix while you're there.

The "I'll let pr-review catch it" loop is avoidable churn.
</self_review_first>

<duplication_classification>
When a finding suggests extracting a shared helper, classify it BEFORE applying:

- **Real duplication** — same args, same data flow, same constants → extract to base/shared module.
- **Shape-similarity** — different mappers / topics / source-data types that just *look* alike → leave it; report "shape-similar only, not extracting" with the divergence list.

Don't auto-apply extract findings without that classification. A 2-call-site abstraction over genuinely different signatures is thin and awkward; revisit when a third lands.
</duplication_classification>
