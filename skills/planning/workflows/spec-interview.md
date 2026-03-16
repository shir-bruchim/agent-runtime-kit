# Spec Interview Workflow

Requirements gathering through structured interview. Use when starting a new project or feature and need to build a comprehensive specification before implementation. Produces a specification document through guided discovery.

## Objective

Build a complete project or feature specification through a structured conversation. Avoids jumping into implementation before requirements are understood.

## Interview Process

Conduct the interview conversationally — don't ask all questions at once.

### Phase 1: Core Understanding

1. What are we building? (one sentence)
2. Who is the primary user?
3. What problem does it solve for them?
4. What does success look like in 3 months?

### Phase 2: Scope

5. What is the MVP (minimum to be useful)?
6. What features are explicitly out of scope for v1?
7. What does the user journey look like end-to-end?

### Phase 3: Technical Context

8. What tech stack / existing systems does this integrate with?
9. Are there performance or scale requirements?
10. Any security, compliance, or regulatory constraints?

### Phase 4: Edge Cases

11. What happens when things go wrong?
12. What are the critical failure modes?
13. Any known risks or concerns?

**Decision gate after each phase:**
"Ready to move on, or is there more to explore here?"

## Spec Output

After the interview, create the spec and save as `.planning/SPEC-[feature-name].md`:

```markdown
# Spec: [Feature/Project Name]

**Created:** [Date]
**Status:** Draft | Review | Approved

## Overview

[2-3 sentences: what this is and why it needs to exist]

## User Stories

- As a [user type], I want to [action] so that [outcome]
- As a [user type], I want to [action] so that [outcome]
- As a [user type], I want to [action] so that [outcome]

## Acceptance Criteria

Must have (v1):
- [ ] [Specific, testable condition]
- [ ] [Specific, testable condition]
- [ ] [Specific, testable condition]

Nice to have (later):
- [ ] [Lower priority item]

## Out of Scope (v1)

Explicitly NOT in this version:
- [Feature explicitly excluded]
- [Integration explicitly excluded]
- [Use case explicitly excluded]

## User Journey

[Step-by-step description of the user experience]
1. User [action]
2. System [response]
3. User [action]
4. ...

## Technical Notes

- **Stack:** [Languages, frameworks, key libraries]
- **Integrations:** [External services, APIs, databases]
- **Constraints:** [Performance, scale, security requirements]
- **Key files:** [Existing files relevant to this feature]

## Edge Cases & Error Handling

| Scenario | Expected Behavior |
|----------|-------------------|
| [Error condition] | [What should happen] |
| [Edge case] | [What should happen] |

## Open Questions

- [ ] [Question that needs a decision]
- [ ] [Question that needs a decision]

## Success Metrics

How we'll know this worked:
- [Metric 1]
- [Metric 2]
```

## Success Criteria

Spec document created with:
- Clear problem statement and user persona
- Specific, testable acceptance criteria
- Explicit out-of-scope list
- Open questions documented
- Ready to hand off for planning
