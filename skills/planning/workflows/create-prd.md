# Workflow: Create PRD

<purpose>
Create a Product Requirements Document through guided discovery.
Use when a feature needs thorough specification before planning.
</purpose>

<process>

<step name="gather_feature_context">
Ask conversationally:
1. What feature are we building? (one clear sentence)
2. Who uses this? (user type / persona)
3. What problem does it solve? (job to be done)
4. What's the success metric? (how do we measure it worked?)
5. What are the edge cases and error states?
6. Are there existing patterns in the codebase we should follow?
</step>

<step name="draft_prd">
Use `templates/prd.md` to structure the PRD.

Save as `.planning/PRD-[feature-name].md`

PRD structure:
- Overview: problem + solution in 2-3 sentences
- User stories: "As a [user], I want to [action] so that [outcome]"
- Acceptance criteria: specific, testable conditions
- Out of scope: explicit exclusions
- Technical notes: implementation constraints, existing patterns to follow
- Open questions: things that need decisions before/during development
</step>

<step name="confirm_and_link">
After creating PRD:
"PRD created at `.planning/PRD-[name].md`.
Want to create an implementation plan (roadmap + phases) from this PRD?"
</step>

</process>

<success_criteria>
PRD contains clear acceptance criteria that a developer could use to verify completion.
No ambiguous requirements. All open questions documented.
</success_criteria>
