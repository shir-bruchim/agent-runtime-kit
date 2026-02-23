---
description: Generate a Product Requirements Document through guided discovery
argument-hint: [feature-name]
---

<objective>
Create a PRD for "$ARGUMENTS" through guided discovery. Covers problem statement, user stories, acceptance criteria, technical notes, and open questions.
</objective>

<process>
1. Ask about the feature: what, who, problem it solves, success metric
2. Explore scope, edge cases, and technical constraints
3. Generate structured PRD at `.planning/PRD-$ARGUMENTS.md`
4. Offer to create implementation plan from the PRD
</process>

<success_criteria>
PRD created with specific, testable acceptance criteria. Ready for implementation planning.
</success_criteria>
