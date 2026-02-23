# PRD Template

Save as `.planning/PRD-[feature-name].md`

```markdown
# PRD: [Feature Name]

**Created:** YYYY-MM-DD
**Status:** Draft / Review / Approved

## Overview

[2-3 sentences: what this feature is, the problem it solves, and the solution approach.]

## User Stories

- As a [user type], I want to [action] so that [outcome]
- As a [user type], I want to [action] so that [outcome]
- As a [user type], I want to [action] so that [outcome]

## Acceptance Criteria

All of the following must be true for this feature to be complete:

- [ ] [Specific, testable condition 1]
- [ ] [Specific, testable condition 2]
- [ ] [Specific, testable condition 3]
- [ ] Error states handled: [list error states]
- [ ] Edge cases covered: [list edge cases]

## Out of Scope

Explicitly NOT included in this feature:

- [Excluded thing 1]
- [Excluded thing 2]

## Technical Notes

- [Existing pattern to follow: e.g., "Use same auth pattern as /api/users"]
- [Constraint: e.g., "Must work with existing Stripe integration"]
- [Performance requirement if any]
- [Security consideration if any]

## Open Questions

Questions that need answers before or during development:

- [ ] [Question 1] — Owner: [human/agent/TBD]
- [ ] [Question 2] — Owner: [human/agent/TBD]
```

<guidelines>
- Acceptance criteria must be verifiable by a developer without asking questions
- Out of scope section prevents scope creep during implementation
- Open questions should be resolved before creating the PLAN.md, if possible
- Technical notes save the agent from re-discovering existing patterns
</guidelines>
