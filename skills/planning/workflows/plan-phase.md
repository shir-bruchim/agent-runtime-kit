# Workflow: Plan Phase

<purpose>
Create an executable phase prompt (PLAN.md) — the document that IS the execution prompt.
Each PLAN.md should have 2-3 tasks maximum, each with specific file paths and verification criteria.
</purpose>

<process>

<step name="understand_context">
Read:
- `.planning/BRIEF.md` — project vision
- `.planning/ROADMAP.md` — what phase we're planning
- Relevant existing files in the codebase (to understand actual state)
</step>

<step name="determine_scope">
For the phase being planned:
1. What exactly needs to be built?
2. What existing files will be modified?
3. What new files will be created?
4. What are the dependencies between tasks?
5. What are the risks?

Split if scope exceeds 3 tasks:
- 01-01-PLAN.md: Foundation (DB schema, models)
- 01-02-PLAN.md: API layer (routes, handlers)
- 01-03-PLAN.md: UI layer (components, pages)
</step>

<step name="write_plan">
Use `templates/plan.md`.

For each task, be specific:
- Exact file path (not "update the service")
- What action (create/modify + what content)
- Why this step (motivation)
- Specific "done when" criteria (testable condition)
- Risk level (Low/Medium/High)

Include in `## Context`:
- @.planning/BRIEF.md
- @.planning/ROADMAP.md
- @relevant-existing-files

Save as `.planning/phases/{phase-name}/{phase}-{plan}-PLAN.md`
</step>

<step name="confirm_plan">
Present the plan to the user:
"Here's the plan for [description]. Ready to execute, or want to adjust?"

Gate: Don't execute without user confirmation.
</step>

</process>

<quality_checklist>
Before finalizing:
- [ ] ≤3 tasks in this plan
- [ ] Every task has an exact file path
- [ ] Every task has a specific "done when" condition
- [ ] Dependencies between tasks are explicit
- [ ] Context includes relevant existing files
- [ ] Verification section has runnable checks
</quality_checklist>

<success_criteria>
PLAN.md exists as an executable prompt ready for the agent to run.
A competent agent could execute it without asking questions.
</success_criteria>
