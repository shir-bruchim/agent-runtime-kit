---
name: spec-interview
description: Requirements gathering through structured interview. Use when starting a new project or feature and need to build a comprehensive specification before implementation. Produces a specification document through guided discovery.
---

<objective>
Build a complete project or feature specification through a structured conversation. Avoids jumping into implementation before requirements are understood.
</objective>

<interview_process>
Conduct the interview conversationally — don't ask all questions at once.

**Phase 1: Core Understanding**
1. What are we building? (one sentence)
2. Who is the primary user?
3. What problem does it solve for them?
4. What does success look like in 3 months?

**Phase 2: Scope**
5. What is the MVP (minimum to be useful)?
6. What features are explicitly out of scope for v1?
7. What does the user journey look like end-to-end?

**Phase 3: Technical Context**
8. What tech stack / existing systems does this integrate with?
9. Are there performance or scale requirements?
10. Any security, compliance, or regulatory constraints?

**Phase 4: Edge Cases**
11. What happens when things go wrong?
12. What are the critical failure modes?
13. Any known risks or concerns?

**Decision gate after each phase:**
"Ready to move on, or is there more to explore here?"
</interview_process>

<spec_format>
After the interview, create the spec using `templates/spec-template.md`:

```markdown
# Spec: [Feature/Project Name]

**Created:** [Date]
**Status:** Draft

## Overview
[2-3 sentences: what it is and why it exists]

## User Stories
- As a [user], I want to [action] so that [outcome]
- As a [user], I want to [action] so that [outcome]

## Acceptance Criteria
- [ ] [Specific testable condition]
- [ ] [Specific testable condition]

## Out of Scope (v1)
- [Explicitly excluded]
- [Explicitly excluded]

## Technical Notes
- [Key tech decisions or constraints]
- [Integration points]

## Open Questions
- [Things needing decisions before or during development]

## Edge Cases
- [Error condition]: [Expected behavior]
```
</spec_format>

<success_criteria>
Spec document created with:
- Clear problem statement and user persona
- Specific, testable acceptance criteria
- Explicit out-of-scope list
- Open questions documented
- Ready to hand off for planning
</success_criteria>
