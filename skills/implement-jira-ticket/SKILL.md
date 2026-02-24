---
name: implement-jira-ticket
description: Implements Jira tickets end-to-end with git setup, planning, coding, and testing. Use when given a Jira ticket ID (e.g., PBAT-123) or when asked to implement a ticket/feature/bug from Jira.
---

<essential_principles>

<principle name="no_ping_pong">
**Minimize developer interruptions during implementation.**
- Batch all changes, then request ONE approval
- Do NOT ask questions during implementation - make reasonable decisions
- Edit all files needed, then present complete implementation
- Only stop at defined approval gates (plan, implementation, integration tests)
- Ping-pong kills session context and flow
</principle>

<principle name="approval_gates">
**Only these checkpoints require user approval:**
1. After showing implementation plan
2. After completing ALL implementation (before testing)
3. Before creating new integration tests

Everything else - proceed autonomously.
</principle>

<principle name="follow_existing_patterns">
**Always follow existing codebase patterns:**
- Before implementing, study how similar features work end-to-end
- Match existing code style, naming, structure
- Use same patterns for DB access, API structure, error handling
- If unsure how to do X, find where X is already done in the codebase
</principle>

<principle name="single_responsibility">
**Each module has one responsibility:**
- 1 DB repository per table (no cross-table logic in same repo)
- Move shared logic to appropriate layer (logic/service, not repository)
- Each function does ONE thing well
</principle>

<principle name="code_quality">
**Non-negotiable quality standards:**
- No functions with complexity > O(n) without user approval
- Minimize DB reads/writes - batch where possible
- Check for unused code/params after implementation
- No dead code, no unused imports
- Update README after significant changes
</principle>

<principle name="pip_install_after_updates">
**Always run pip install after package updates.**
- If ticket mentions a new package version, install it FIRST
- Run `pip install -r requirements.txt` before running tests
- If tests fail with import errors, re-run pip install
</principle>

<principle name="human_readable_comments">
**Comments are for humans, not code dumps.**
- Write comments in plain language explaining WHY, not WHAT
- No code examples in comments (unless specifically requested)
- Jira ticket comments should explain the issue and fix approach simply
- Use human-friendly names for issues (e.g., "Ghost Record Selection Issue" not "NULL_DISTINCT_FILTER_STATUS_MISMATCH")
</principle>

<principle name="use_mcp_tools">
**Use MCP tools when available.**
- If connected to groundcover MCP, use it to fetch logs
- If connected to Atlassian MCP, use it to fetch/update Jira tickets
- If a tool fails, check connection and try again
- Don't fail silently - use the available tools
</principle>

<principle name="verify_completeness">
**Before declaring done, re-verify:**
- Re-read Jira ticket - did you miss anything?
- Check ticket's instruction page/links if mentioned
- Verify all acceptance criteria are met
- Run full test suite
</principle>

<principle name="test_discipline">
**Testing is mandatory:**
- Run existing tests before AND after changes
- Create unit tests for every new function → use `/pytest-best-practices`
- Create integration tests when behavior changes → use `/localstack-integration`
- Fix broken tests immediately, don't skip them

**When fixing tests:**
- NO production code changes - only test updates
- Fix test INPUTS, not create more mocks
- Use EXISTING fixtures from conftest
- Use REAL objects (metadata, models) - don't manually create values
- Debug what function returns BEFORE trying to fix
</principle>

</essential_principles>

<related_skills>

**For unit tests:** Use `/pytest-best-practices` skill
- Creates unit tests for all new functions
- Follows 100% effective coverage policy
- Minimal mocking (boundaries only)

**For integration tests:** Use `/localstack-integration` skill
- Creates integration tests with DB state verification
- Validates before/after states
- Follows existing test patterns

</related_skills>

<intake>
Provide a Jira ticket ID (e.g., `PBAT-123`) or paste the ticket details.

**Wait for ticket ID before proceeding.**
</intake>

<routing>
| Input | Action |
|-------|--------|
| Jira ID (e.g., PBAT-123) | Fetch via Atlassian MCP → `workflows/implement-ticket.md` |
| Pasted ticket details | Parse details → `workflows/implement-ticket.md` |
| Question about workflow | Answer from this file |

**After receiving ticket, read and follow `workflows/implement-ticket.md` exactly.**
</routing>

<quick_reference>

<git_commands>
```bash
# Setup
git checkout develop
git pull origin develop
git checkout -b feature/{JIRA-ID}

# Dependencies (adjust for your project)
pip install -r requirements.txt
pip install -r requirements-dev.txt
```
</git_commands>

<atlassian_mcp>
Use `mcp__atlassian__getJiraIssue` to fetch ticket:
- Extract: summary, description, acceptance criteria
- Note: issue type (bug, feature, task)
- Check for linked instruction pages
</atlassian_mcp>

<test_commands>
```bash
# Unit tests
pytest tests/ -v

# Integration tests (LocalStack)
cd local_stack && docker compose up --build

# All tests
pytest
```
</test_commands>

</quick_reference>

<workflow_phases>
| Phase | Description | Approval Required |
|-------|-------------|-------------------|
| 1. Setup | Git checkout, branch, dependencies | No |
| 2. Research | Read CLAUDE.md, README, existing patterns | No |
| 3. Planning | Fetch ticket, create implementation plan | **Yes** |
| 4. Implementation | Write ALL code per approved plan (no ping-pong) | **Yes** |
| 5. Testing | Unit tests (`/pytest-best-practices`), integration tests (`/localstack-integration`) | Integration: **Yes** |
| 6. Verify | Re-check Jira ticket, unused code, README | No |
| 7. Complete | All tests pass, ready for PR | No |
</workflow_phases>

<success_criteria>
Implementation is complete when:
- [ ] Branch created from develop with correct naming
- [ ] Dependencies updated (including any new package versions from ticket)
- [ ] Implementation plan approved by user
- [ ] ALL code changes implemented in one batch (no ping-pong)
- [ ] Code follows existing patterns (studied e2e examples)
- [ ] Single responsibility maintained (1 repo per table)
- [ ] No functions > O(n) complexity
- [ ] All existing tests pass
- [ ] Unit tests created for new functions (`/pytest-best-practices`)
- [ ] Integration tests created if needed (`/localstack-integration`)
- [ ] No unused code/params
- [ ] Jira ticket re-checked for completeness
- [ ] README updated if significant changes
</success_criteria>