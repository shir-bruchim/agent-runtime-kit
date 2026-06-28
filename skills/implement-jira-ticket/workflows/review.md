# Workflow: Code Review and Verification

Run this after implementation is approved, before declaring the ticket done.

<process>

## Step 1: Re-Read the Jira Ticket

Go back to the original Jira ticket and verify every line:

- [ ] All acceptance criteria are met
- [ ] All requirements from the description are addressed
- [ ] Any linked instruction pages or URLs were followed
- [ ] Nothing in the ticket description was missed

If you find a gap: implement it, then re-verify.

## Step 2: Self-Review the Code

Read through every file you changed:

**Code quality checks:**
- [ ] No function complexity > O(n) (document and flag any exceptions)
- [ ] DB reads/writes are batched where possible — no unnecessary round trips
- [ ] No unused functions, parameters, or imports
- [ ] No dead code paths
- [ ] Error handling is consistent with existing patterns
- [ ] Comments explain WHY, not WHAT
- [ ] Every new CRUD method logs the compiled SQL at DEBUG (`literal_binds=True`)

**Architecture checks:**
- [ ] Single responsibility: each DB repository handles exactly one table
- [ ] No cross-table logic in a repository that belongs in the service/logic layer
- [ ] Existing naming conventions followed exactly — no redundant qualifiers in already-context-scoped modules, no ticket-only descriptors in code
- [ ] No feature flags or backwards-compatibility hacks unless the ticket requires them
- [ ] Customer/tenant scoping enforced server-side in repos (IDOR guard)
- [ ] Pagination/filter resolution extracted into reusable helper (when adding search endpoints)
- [ ] Single middleware per concern — no duplicate context-setting / logging middlewares
- [ ] Skip-path lists are module-level constants reused everywhere

**Configuration checks:**
- [ ] Every new env var lives in `app/core/config.py` `Settings` in UPPER_SNAKE_CASE
- [ ] Test env vars are in `pytest.ini` (NOT in test files)
- [ ] `testpaths = ./tests` (folder, not enumerated files)
- [ ] Multi-DB libraries use `client_name`, not manual env-var mirroring

**Integration infrastructure checks (if API changed):**
- [ ] New compose service added if a new DB is involved
- [ ] Env vars wired on BOTH `web` and `test` services
- [ ] `local_stack/conftest.py` initializes schema (often via a schema package)
- [ ] Seed data lives in a separate `*_fill_tables.sql`, not embedded in conftest
- [ ] `Dockerfile-test` copies the new test files, conftest, and seed SQL
- [ ] Docker compose `command:` includes the new test file

**Documentation checks:**
- [ ] `README.md` updated with new endpoints/env vars
- [ ] `CLAUDE.md` updated with architecture, env vars, design decisions
- [ ] `docs/api.md` updated with full request/response contracts
- [ ] `docs/architecture.md` updated with component layout + middleware stack

## Step 3: Check for Leftover Artifacts

```bash
# Search for debug prints or TODO comments you may have left
grep -rn "print(" --include="*.py" .
grep -rn "TODO\|FIXME\|HACK\|XXX" --include="*.py" .
grep -rn "import pdb\|breakpoint()" --include="*.py" .
```

Remove any found debug artifacts.

## Step 4: Update README (if needed)

If the implementation:
- Adds a new publicly visible feature
- Changes configuration options
- Adds or changes environment variables
- Changes the API surface

Then update `README.md` with:
- New functionality description
- Configuration changes
- Environment variable additions

## Step 5: Completion Checklist

Before reporting complete:

- [ ] Feature branch created from develop: `feature/{JIRA-ID}`
- [ ] Implementation plan (with test specs) approved by user
- [ ] Tests written FIRST and verified failing (Red phase approved)
- [ ] All code implemented — tests pass (Green phase approved)
- [ ] Code refactored without breaking tests (Refactor phase)
- [ ] Existing patterns followed (studied end-to-end examples)
- [ ] Single responsibility maintained (1 repo per table)
- [ ] No functions > O(n) complexity
- [ ] Unit tests cover all new functions
- [ ] Integration/localstack tests updated if API behavior changed (MANDATORY)
- [ ] No unused code, params, or imports
- [ ] Jira ticket fully addressed (every acceptance criterion checked)
- [ ] README updated (if significant behavior change)
- [ ] Ready for commit: `git diff --stat`

</process>

<next_steps>

After verification is complete:

```bash
# Review what you changed
git diff

# Commit changes
# Use /commit skill or:
git add -p
git commit -m "feat(scope): description of what was done

Implements {JIRA-ID}: [brief summary]"

# Create PR
# Use /pr skill or:
gh pr create --title "feat: [summary]" --body "Closes {JIRA-ID}"
```

</next_steps>