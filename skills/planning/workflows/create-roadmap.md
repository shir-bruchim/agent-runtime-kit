# Workflow: Create Roadmap

<purpose>
Define the phase structure from the project brief.
Each phase must deliver independently shippable software.
</purpose>

<process>

<step name="read_brief">
Read `.planning/BRIEF.md` completely.
Understand the problem, success criteria, and constraints before designing phases.
</step>

<step name="design_phases">
Design 3-6 phases following this pattern:

- **Phase 1: Foundation** — Minimum viable: smallest slice that works end-to-end
- **Phase 2: Core** — Complete happy path for primary use case
- **Phase 3: Resilience** — Error handling, edge cases, validation
- **Phase 4: Polish** — UX refinement, performance, monitoring
- **Phase 5+: Growth** — Additional features (only if in scope)

Rules:
- Each phase must be runnable/deployable without subsequent phases
- Phase 1 should be completable quickly (confidence builder)
- No phase should have more than 4 plans
- Each plan should have 2-3 tasks maximum
</step>

<step name="write_roadmap">
Create `.planning/` directory if needed:
```bash
mkdir -p .planning/phases
```

Write `.planning/ROADMAP.md` using `templates/roadmap.md`.

For each phase, list the plans with short descriptions.
Do NOT write the plans yet — just name them.
</step>

<step name="confirm_roadmap">
Present the phase structure:
"Here's the roadmap with [N] phases and [M] total plans.
Does this scope look right, or should we adjust before creating the first plan?"

Gate: Confirm before proceeding.
</step>

<step name="offer_next">
```
Roadmap created: .planning/ROADMAP.md

What's next?
1. Plan Phase 1 now (start building)
2. Review/adjust roadmap first
3. Done for now
```
</step>

</process>

<anti_patterns>
- Don't create more than 6 phases (scope creep signal)
- Don't put more than 4 plans in a phase
- Don't estimate time for phases
- Don't design phases that are all-or-nothing (must be independently shippable)
</anti_patterns>

<success_criteria>
ROADMAP.md exists with 3-6 phases, each with named plans and a clear goal.
Phase 1 is small enough to complete quickly and deliver real value.
</success_criteria>
