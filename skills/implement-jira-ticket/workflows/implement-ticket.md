# Workflow: Implement Jira Ticket

<required_reading>
**Before starting, read principles in SKILL.md:**
- no_ping_pong
- follow_existing_patterns
- single_responsibility
- code_quality
</required_reading>

<process>

## Phase 1: Git Setup

<step number="1">
**Checkout and update develop:**

```bash
git checkout develop
git pull origin develop
```

Verify you're on latest develop before branching.
</step>

<step number="2">
**Create feature branch:**

Extract Jira ID from ticket (e.g., `PBAT-123`) and create branch:

```bash
git checkout -b feature/{JIRA-ID}
```

Example: `git checkout -b feature/PBAT-123`
</step>

<step number="3">
**Update dependencies (CRITICAL):**

Find and install from all requirements files:

```bash
# Find requirement files
find . -name "requirements*.txt" -type f

# Install each (adjust paths as found)
pip install -r requirements.txt
pip install -r requirements-dev.txt
```

**If ticket mentions a package version update:**
1. Update the version in requirements.txt
2. Run `pip install -r requirements.txt` IMMEDIATELY
3. Verify the new version is installed: `pip show <package>`

**IMPORTANT:** Always re-run pip install before running tests after any package update.
</step>

## Phase 2: Research & Understanding

<step number="4">
**Read project documentation:**

Read these files in order:
1. `CLAUDE.md` - Claude-specific instructions (highest priority)
2. `README.md` - Project overview
3. Any `CONTRIBUTING.md` or `DEVELOPMENT.md`

Extract:
- Coding standards
- Testing requirements
- Architecture patterns
- Special instructions
</step>

<step number="5">
**Study existing patterns (CRITICAL):**

Before writing ANY code:
1. Find similar features already implemented
2. Read them END-TO-END (API → Service → Logic → Repository → DB)
3. Note patterns for:
   - API endpoint structure
   - Service layer organization
   - Logic layer patterns
   - Repository patterns (search with dict filters, etc.)
   - Error handling
   - Response building

**Follow these patterns exactly in your implementation.**
</step>

<step number="6">
**Verify single responsibility:**

Check repository structure:
- Each DB table should have ONE repository
- If logic for table X is in repository Y, plan to move it
- Each repository: search, get, create, update, delete for ONE table only
</step>

## Phase 3: Planning

<step number="7">
**Fetch Jira ticket details:**

Use Atlassian MCP to get ticket:

```
mcp__atlassian__getJiraIssue with:
- issueIdOrKey: {JIRA-ID}
```

Extract from ticket:
- Summary (title)
- Description
- Acceptance criteria
- Issue type (bug, feature, task, etc.)
- Any linked issues or dependencies
- **Instruction pages/links** (check description for URLs)
</step>

<step number="8">
**Create implementation plan:**

Based on ticket and codebase understanding, create a plan with:

```
## Implementation Plan for {JIRA-ID}

### Summary
[Brief description of what will be implemented]

### Existing Patterns Found
[List similar features studied and patterns to follow]

### Changes Required
1. [File/module]: [What changes]
2. [File/module]: [What changes]
...

### New Files (if any)
- [path/to/new/file.py]: [Purpose]

### Repository Changes (if any)
- Move [table] logic from [wrong repo] to [correct repo]
- Create search function with dict filter for [table]

### Tests to Write First (TDD Red Phase)
- Unit tests: [list test cases per function — happy path, edge cases, errors]
- Integration/localstack tests: [MANDATORY if API behavior changes — list endpoints + DB state assertions]

### Risks/Considerations
- [Any edge cases or concerns]
```

**Present plan to user and wait for approval.**
</step>

<approval_gate name="plan">
**STOP: Get user approval on implementation plan (including test specs).**

Ask: "Does this implementation plan look correct? The test specs show what I'll write first (TDD). Reply 'approve' to proceed, or provide feedback to adjust."

- If approved → proceed to Phase 4 (TDD Red)
- If feedback → revise plan and re-present
</approval_gate>

## Phase 4: TDD Red Phase — Write Tests FIRST

<step number="9">
**Run existing tests to establish baseline:**

```bash
pytest --tb=short -q
```

Record which tests pass/fail. Pre-existing failures are not your concern unless the ticket requires fixing them.
</step>

<step number="10">
**Write unit test stubs for all planned functions:**

For every new function/method in the plan:
1. Create or locate `tests/test_{module}.py`
2. Write test cases covering:
   - Happy path (expected input → expected output)
   - Edge cases (empty inputs, boundary values, None/null)
   - Error conditions (invalid input raises correct exception)
3. Mock only at system boundaries (DB, HTTP, AWS)
4. Use real objects for business logic
5. Follow existing test patterns in the repo exactly

These tests should **FAIL** because the production code doesn't exist yet.
</step>

<step number="11">
**Write integration/localstack tests if API behavior changes (MANDATORY):**

If the ticket changes ANY of these, integration test updates are **required, not optional**:
- API endpoint behavior (new endpoints, changed responses, changed request schemas)
- Data flow between layers
- External integrations (queues, events, webhooks)
- DB state (new tables, changed records, new queries)

**Integration test requirements:**
- Verify DB state BEFORE action (e.g., table is empty, record has status X)
- Perform the action
- Verify DB state AFTER action (e.g., correct records inserted, status changed)
- Follow existing integration test patterns in the repo
- Use `/localstack-integration` skill for localstack-specific patterns

These tests should also **FAIL** at this point.
</step>

<step number="12">
**Verify all new tests fail (Red):**

```bash
pytest tests/test_{new_module}.py -v  # unit tests fail
pytest tests/integration/ -v          # integration tests fail (if written)
```

If any new test accidentally passes, it's testing the wrong thing — fix the assertion.

**Present test stubs to user and wait for approval.**
</step>

<approval_gate name="tests_red">
**STOP: Get user approval on test stubs.**

Ask: "Test stubs written — all failing as expected (Red phase). Here's what's covered:
- Unit tests: [list test cases]
- Integration tests: [list if applicable]

Reply 'approve' to proceed to implementation, or provide feedback."

- If approved → proceed to Phase 5 (Green)
- If feedback → adjust tests and re-present
</approval_gate>

## Phase 5: Implementation — Make Tests Pass (NO PING-PONG)

<critical_rule>
**Implement EVERYTHING, then present for approval.**

Do NOT:
- Ask questions mid-implementation
- Present partial changes
- Request approval for individual files

DO:
- Make all changes according to plan
- Make reasonable decisions when unclear
- Edit ALL files needed
- Then present complete implementation
</critical_rule>

<step number="13">
**Implement according to plan:**

Follow the approved plan exactly:
- Make changes file by file
- Follow existing code patterns (from Step 5)
- Maintain single responsibility (1 repo per table)
- Use dict filters for search functions (like existing code)
- Don't over-engineer or add unrequested features
- Goal: make the failing tests PASS
</step>

<step number="14">
**Quality checks during implementation:**

As you code, verify:
- [ ] No function complexity > O(n) (ask user if unavoidable)
- [ ] Minimize DB reads/writes (batch where possible)
- [ ] No unused code/params
- [ ] No dead imports
- [ ] Following existing patterns exactly
</step>

<step number="15">
**Run all tests — they should pass (Green):**

```bash
pytest --tb=short -v
```

If tests fail:
1. **Run pip install first** (in case package was updated)
2. Analyze failure reason — debug what function actually returns
3. Fix the **production code** to satisfy the tests (that's the TDD contract)
4. If test expectation was wrong, fix the test — but prefer fixing code first
5. Use **existing fixtures** from conftest — don't create new ones
6. Use **real objects** (metadata, models) — don't manually create values
7. Re-run until ALL tests pass (existing + new)
</step>

<step number="16">
**Show complete implementation to user:**

After completing ALL changes, summarize:
- Files changed (with brief description of each)
- Key code additions
- Test results: all passing (Green)
- Any deviations from plan (with reasoning)
- Any decisions made autonomously

**Present COMPLETE implementation and wait for approval.**
</step>

<approval_gate name="implementation">
**STOP: Get user approval on COMPLETE implementation.**

Ask: "Implementation complete — all tests passing (Green phase). Please review the changes. Reply 'approve' to proceed to refactor/verification, or provide feedback."

- If approved → proceed to Phase 6
- If feedback → make adjustments and re-present
</approval_gate>

## Phase 6: Refactor (TDD Final Phase)

<step number="17">
**Refactor if needed:**

Now that tests are green, improve code quality WITHOUT changing behavior:
- Extract duplicated logic
- Improve naming
- Simplify complex expressions
- Remove any scaffolding added during implementation

Re-run tests after each refactor to confirm they still pass:

```bash
pytest --tb=short -v
```
</step>

## Phase 7: Verification

<step number="18">
**Re-check Jira ticket:**

Go back to Jira ticket and verify:
- [ ] All acceptance criteria met
- [ ] All requirements addressed
- [ ] Any linked instruction pages followed
- [ ] Nothing missed from description
</step>

<step number="19">
**Check for unused code:**

Scan implementation for:
- Unused functions
- Unused parameters
- Unused imports
- Dead code paths

Remove any found.
</step>

<step number="20">
**Update README if needed:**

If implementation adds significant new behavior:
- Update README with new functionality
- Document any new configuration
- Update architecture section if needed
</step>

## Phase 8: Complete

<step number="21">
**Verify completion checklist:**

- [ ] Feature branch created: `feature/{JIRA-ID}`
- [ ] Tests written FIRST and verified failing (Red)
- [ ] All code implemented — tests pass (Green)
- [ ] Code refactored without breaking tests (Refactor)
- [ ] User approved implementation
- [ ] Single responsibility maintained (1 repo per table)
- [ ] Existing patterns followed
- [ ] No functions > O(n)
- [ ] Unit tests cover all new functions
- [ ] Integration/localstack tests updated (if API behavior changed — MANDATORY)
- [ ] No unused code/params
- [ ] Jira ticket re-checked
- [ ] README updated if needed
</step>

<step number="22">
**Report completion:**

Summarize to user:
- What was implemented
- Files changed
- Tests added (unit + integration breakdown)
- TDD phases completed: Red → Green → Refactor
- Any autonomous decisions made
- Branch name (ready for commit/PR)

Suggest next steps:
- Review changes: `git diff`
- Commit: Use `/commit` skill
- Create PR: Use `/pr` skill
</step>

</process>

<error_handling>

<scenario name="test_failures">
If tests still fail after implementation (Green phase):
1. **Run pip install first** — package might have been updated
2. Read the failure output carefully
3. **Debug what function returns** — print actual values before fixing
4. The TDD contract: tests define the expected behavior, so fix the **production code** to satisfy them
5. If a test expectation was genuinely wrong (misunderstood requirement), fix the test — but prefer fixing code first
6. **Use existing fixtures** from conftest — don't create new ones
7. **Use real objects** from metadata/models — don't create manual values
8. Re-run tests
9. If stuck, ask user for guidance

**NEVER:**
- Skip the Red phase (writing tests that fail first)
- Create new fixtures if they exist in conftest
- Manually create values that exist in real objects
</scenario>

<scenario name="jira_fetch_fails">
If Atlassian MCP fails to fetch ticket:
1. Verify the ticket ID is correct
2. Check MCP connection
3. Ask user to paste ticket details manually
</scenario>

<scenario name="pattern_unclear">
If existing patterns are unclear:
1. Look for more examples in the codebase
2. Make a reasonable decision based on what you found
3. Document your decision in the implementation summary
4. Do NOT stop to ask - proceed and let user review
</scenario>

<scenario name="complexity_exceeds_on">
If a function requires > O(n) complexity:
1. Document why in the implementation summary
2. Present to user during implementation approval
3. Suggest alternative approaches if possible
</scenario>

</error_handling>

<success_criteria>
Workflow is complete when:
- [ ] Implementation plan (with test specs) was approved
- [ ] Tests written first and verified failing (Red phase approved)
- [ ] Code implemented — all tests pass (Green phase approved)
- [ ] Code refactored without breaking tests
- [ ] Unit tests cover all new functions
- [ ] Integration/localstack tests updated if API behavior changed (MANDATORY)
- [ ] No unused code/params
- [ ] Jira ticket fully addressed
- [ ] Code is ready for commit/PR
</success_criteria>