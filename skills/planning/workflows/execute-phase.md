# Workflow: Execute Phase

<purpose>
Execute a PLAN.md, handle deviations, and produce a SUMMARY.md.
</purpose>

<deviation_rules>
During execution, handle discoveries automatically:

| Situation | Action |
|-----------|--------|
| Bug found in existing code | Fix it, document in Summary |
| Missing security/correctness | Add it, document in Summary |
| Blocker preventing progress | Fix blocker, document |
| Major architectural change needed | STOP, ask user |
| Nice-to-have enhancement | Log to ISSUES.md, continue |

Rules 1-3 and 5: Automatic. Rule 4 only: Ask user.
</deviation_rules>

<process>

<step name="read_plan">
Read the PLAN.md completely.
Load all @referenced files.
Understand the full scope before making any changes.
</step>

<step name="execute_tasks">
Execute tasks in dependency order.
After each task: verify the "done when" condition.
If a task fails: apply deviation rules above.
Document any deviations as you go.
</step>

<step name="verify">
Run all checks in the `## Verification` section of PLAN.md.
All checks must pass before proceeding.
If a check fails: fix, don't skip.
</step>

<step name="git_commit">
Stage and commit the changes:
```bash
git add [specific files]
git commit -m "feat(XX-YY): [description]

[Brief summary of what was built]

Co-Authored-By: Claude <noreply@anthropic.com>"
```
</step>

<step name="write_summary">
Create SUMMARY.md at `.planning/phases/{phase}/{phase}-{plan}-SUMMARY.md`:

```markdown
# Summary: [Plan Name] (Completed: YYYY-MM-DD)

## What Was Built
[2-3 sentences describing what was implemented]

## Files Modified
- `path/to/file.ts` — [what changed]
- `path/to/new-file.ts` — [created, what it does]

## Deviations from Plan
[List any deviations and which rule applied, or "None"]

## Verification Results
- [x] [check 1] — passed
- [x] [check 2] — passed

## Commit
`feat(XX-YY): [commit message]`

## Issues Logged
[Any ISSUES.md entries added, or "None"]
```

SUMMARY.md existence marks this plan as complete.
</step>

<step name="update_roadmap">
Update ROADMAP.md: mark this plan `[x]` as complete.
</step>

</process>

<success_criteria>
- All tasks executed
- All verification checks passing
- Changes committed
- SUMMARY.md created
- ROADMAP.md updated
</success_criteria>
