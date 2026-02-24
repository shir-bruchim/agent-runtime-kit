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

### Tests to Create
- Unit tests: [list functions to test] → `/pytest-best-practices`
- Integration tests: [if behavior changes] → `/localstack-integration`

### Risks/Considerations
- [Any edge cases or concerns]
```

**Present plan to user and wait for approval.**
</step>

<approval_gate name="plan">
**STOP: Get user approval on implementation plan.**

Ask: "Does this implementation plan look correct? Reply 'approve' to proceed, or provide feedback to adjust."

- If approved → proceed to Phase 4
- If feedback → revise plan and re-present
</approval_gate>

## Phase 4: Implementation (NO PING-PONG)

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

<step number="9">
**Implement according to plan:**

Follow the approved plan exactly:
- Make changes file by file
- Follow existing code patterns (from Step 5)
- Maintain single responsibility (1 repo per table)
- Use dict filters for search functions (like existing code)
- Add appropriate comments only where logic isn't obvious
- Don't over-engineer or add unrequested features
</step>

<step number="10">
**Quality checks during implementation:**

As you code, verify:
- [ ] No function complexity > O(n) (ask user if unavoidable)
- [ ] Minimize DB reads/writes (batch where possible)
- [ ] No unused code/params
- [ ] No dead imports
- [ ] Following existing patterns exactly
</step>

<step number="11">
**Show complete implementation to user:**

After completing ALL changes, summarize:
- Files changed (with brief description of each)
- Key code additions
- Any deviations from plan (with reasoning)
- Any decisions made autonomously

**Present COMPLETE implementation and wait for approval.**
</step>

<approval_gate name="implementation">
**STOP: Get user approval on COMPLETE implementation.**

Ask: "Implementation complete. All files have been modified. Please review the changes. Reply 'approve' to proceed to testing, or provide feedback."

- If approved → proceed to Phase 5
- If feedback → make adjustments and re-present
</approval_gate>

## Phase 5: Testing

<step number="12">
**Run existing tests:**

```bash
# Run all tests
pytest

# Or run specific test suites
pytest tests/unit/
pytest tests/integration/
```

If tests fail:
1. **Run pip install first** (in case package was updated)
2. Analyze failure reason - debug what function actually returns
3. Fix the **test inputs/data** - NOT production code (unless code is wrong)
4. Use **existing fixtures** from conftest - don't create new ones
5. Use **real objects** (metadata, models) - don't manually create values
6. Re-run tests
7. Repeat until all pass

**CRITICAL when fixing tests:**
- NO production code changes - only test updates
- Fix inputs, not create more mocks
- Use existing conftest fixtures
</step>

<step number="13">
**Create unit tests:**

Use `/pytest-best-practices` skill principles:

For every new function/method created:
1. Create test file if doesn't exist: `tests/test_{module}.py`
2. Write tests covering:
   - Happy path
   - Edge cases (empty inputs, boundaries)
   - Error conditions
3. Mock only at system boundaries (DB, HTTP, AWS)
4. Use real objects for business logic

Follow existing test patterns in the repo.
</step>

<step number="14">
**Evaluate integration test needs:**

If the implementation:
- Changes API behavior
- Modifies data flow
- Affects external integrations
- Changes user-facing behavior
- Modifies DB state

Then integration tests are needed.

**Integration test requirements:**
- Verify DB state BEFORE action (e.g., table is empty)
- Perform action
- Verify DB state AFTER action (e.g., table has correct records)
- Follow existing patterns for DB queries in tests

<approval_gate name="integration_tests">
**STOP: If creating new integration tests, get user approval first.**

Ask: "I need to create integration tests for [reason]. Here's the test plan:
- Before state verification: [what to check]
- Action: [what to test]
- After state verification: [what to verify]

Approve?"

Use `/localstack-integration` skill for implementation.
</approval_gate>
</step>

<step number="15">
**Final test run:**

Run complete test suite:

```bash
pytest --tb=short -v
```

All tests must pass before completion.
</step>

## Phase 6: Verification

<step number="16">
**Re-check Jira ticket:**

Go back to Jira ticket and verify:
- [ ] All acceptance criteria met
- [ ] All requirements addressed
- [ ] Any linked instruction pages followed
- [ ] Nothing missed from description
</step>

<step number="17">
**Check for unused code:**

Scan implementation for:
- Unused functions
- Unused parameters
- Unused imports
- Dead code paths

Remove any found.
</step>

<step number="18">
**Update README if needed:**

If implementation adds significant new behavior:
- Update README with new functionality
- Document any new configuration
- Update architecture section if needed
</step>

## Phase 7: Complete

<step number="19">
**Verify completion checklist:**

- [ ] Feature branch created: `feature/{JIRA-ID}`
- [ ] All code changes implemented per plan
- [ ] User approved implementation
- [ ] Single responsibility maintained (1 repo per table)
- [ ] Existing patterns followed
- [ ] No functions > O(n)
- [ ] All existing tests pass
- [ ] Unit tests created for new functions
- [ ] Integration tests created if needed (with DB state verification)
- [ ] No unused code/params
- [ ] Jira ticket re-checked
- [ ] README updated if needed
</step>

<step number="20">
**Report completion:**

Summarize to user:
- What was implemented
- Files changed
- Tests added
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
If tests fail after implementation:
1. **Run pip install first** - package might have been updated
2. Read the failure output carefully
3. **Debug what function returns** - print actual values before fixing
4. Identify if it's a code bug or test data issue
5. **Fix test inputs/data first** - NOT production code (unless code is wrong)
6. **Use existing fixtures** from conftest - don't create new ones
7. **Use real objects** from metadata/models - don't create manual values
8. Re-run tests
9. If stuck, ask user for guidance

**NEVER:**
- Change production code to make tests pass (unless code is actually wrong)
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
- [ ] Implementation plan was approved
- [ ] Code implementation was approved (all at once, no ping-pong)
- [ ] All tests pass (existing + new)
- [ ] Unit tests exist for all new functions
- [ ] Integration tests verify DB state changes
- [ ] No unused code/params
- [ ] Jira ticket fully addressed
- [ ] Code is ready for commit/PR
</success_criteria>