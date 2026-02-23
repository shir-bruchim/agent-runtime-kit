# Summary Template

Save as `.planning/phases/{phase}/{phase}-{plan}-SUMMARY.md`

Existence of this file marks the plan as complete.

```markdown
# Summary: [Plan Name] (Completed: YYYY-MM-DD)

## What Was Built

[2-3 sentences describing what was implemented]

## Files Modified

- `path/to/file.ts` — [what changed]
- `path/to/new-file.ts` — [created, what it does]

## Deviations from Plan

[List any deviations and which rule applied, or "None"]

Example entries:
- Auto-fixed: [bug description] (Rule 1 — bug found)
- Auto-added: [security check] (Rule 2 — missing critical item)
- Logged to ISSUES.md: [enhancement idea] (Rule 5 — defer enhancement)

## Verification Results

- [x] [check 1] — passed
- [x] [check 2] — passed
- [x] All tests pass

## Commit

`feat(XX-YY): [commit message]`

## Issues Logged

[Any ISSUES.md entries added, or "None"]
```

<guidelines>
- Create immediately after all verification checks pass
- Never create before verification is complete
- Deviations section must be honest — log everything that differed from the plan
- This file is the source of truth for "what actually happened"
</guidelines>
