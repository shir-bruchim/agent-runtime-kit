---
name: implement-jira-ticket
description: Implements Jira tickets end-to-end with git setup, planning, coding, and testing. Use when given a Jira ticket ID (e.g., PBAT-123) or when asked to implement a ticket/feature/bug from Jira.
---

<essential_principles>

- **No ping-pong** — batch all changes, present for ONE approval. Do not ask questions mid-implementation.
- **Approval gates** — only 3 stops require user input: plan, implementation complete, new integration tests.
- **Follow existing patterns** — study similar features end-to-end before writing a single line.
- **Single responsibility** — 1 DB repository per table, no cross-table logic in repos.
- **Test discipline** — run tests before and after. Fix test inputs, not production code. See `workflows/testing.md`.
- **Use MCP tools** — if Atlassian MCP is connected, use it. If groundcover MCP is connected, use it for logs.

</essential_principles>

<intake>
Provide a Jira ticket ID (e.g., `PBAT-123`) or paste the ticket details directly.

**Wait for ticket ID before proceeding.**
</intake>

<routing>

| Input | Action |
|-------|--------|
| Jira ID (e.g., PBAT-123) | Fetch via Atlassian MCP → follow `workflows/implement-ticket.md` |
| Pasted ticket details | Parse details → follow `workflows/implement-ticket.md` |
| Testing question | → `workflows/testing.md` |
| Review / done check | → `workflows/review.md` |

**Detailed steps are in the workflow files. Read the relevant workflow before proceeding.**

</routing>

<success_criteria>

- [ ] Branch created from develop with correct naming (`feature/{JIRA-ID}`)
- [ ] Implementation plan approved
- [ ] All code implemented in one batch (no ping-pong)
- [ ] Existing patterns followed
- [ ] All tests pass — see `workflows/testing.md`
- [ ] Ticket re-checked against acceptance criteria — see `workflows/review.md`
- [ ] README updated if behavior changed

</success_criteria>