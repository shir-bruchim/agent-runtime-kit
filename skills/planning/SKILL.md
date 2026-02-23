---
name: planning
description: Create hierarchical project plans for agentic development. Produces actionable, phase-based plans with specific file paths, dependencies, and verification criteria. Use when planning features, refactors, new projects, or complex multi-step implementations. Merged from create-plans skill + planner agent best practices.
---

<essential_principles>

<principle name="plans_are_prompts">
A PLAN.md is not a document. It IS the prompt that executes the work.
It contains: objective, context (@file references), tasks with file paths, verification, and success criteria.
When you plan a phase, you are writing the prompt that will run it.
</principle>

<principle name="actionable_specificity">
Every step must be specific enough to execute without questions:
- Exact file paths (not "update the service layer")
- Specific function names when known
- Clear dependencies between steps
- Risk level per step (Low/Medium/High)

BAD: "Set up the database"
GOOD: "Create migration `supabase/migrations/004_subscriptions.sql` with RLS policies for the subscriptions table"
</principle>

<principle name="scope_control">
Plans must complete within ~50% of context to maintain quality.

Quality degrades at 40-50% context (not 80%). Split phases into many small focused plans:
- 2-3 tasks per PLAN.md maximum
- Better 10 small high-quality plans than 3 large degraded ones
- Each plan independently executable and verifiable
</principle>

<principle name="solo_dev_plus_agent">
Planning for ONE person (the user) + ONE implementer (the agent).
No teams, no stakeholders, no coordination overhead.
No enterprise PM theater: no RACI matrices, no sprint ceremonies, no multi-week estimates.
</principle>

<principle name="phases_deliver_independently">
Each phase must be independently deliverable:
- Phase 1: Minimum viable — smallest slice that provides value
- Phase 2: Core experience — complete happy path
- Phase 3: Edge cases — error handling, polish
- Phase 4: Optimization — performance, monitoring

Never design phases that require all phases to complete before anything works.
</principle>

<principle name="human_checkpoints">
Claude automates everything with a CLI/API. Checkpoints are for verification, not manual work.

Types:
- `checkpoint:human-verify` — Human confirms automated work (visual check, UI test)
- `checkpoint:decision` — Human makes architectural choice
- `checkpoint:human-action` — Only for truly manual tasks (email verification links)

NEVER ask the human to do what a CLI can do.
</principle>

<principle name="deviation_rules">
Plans are guides, not straitjackets. During execution:
1. Auto-fix bugs — fix immediately, document in Summary
2. Auto-add missing critical items — security/correctness gaps
3. Auto-fix blockers — can't proceed, fix first
4. Ask about architectural changes — major structural changes only
5. Log enhancements — defer to ISSUES.md, continue

Only rule 4 requires user input. Everything else flows automatically.
</principle>

</essential_principles>

<context_scan>
Run on every invocation:

```bash
git rev-parse --git-dir 2>/dev/null || echo "NO_GIT_REPO"
ls -la .planning/ 2>/dev/null
find . -name ".continue-here*.md" -type f 2>/dev/null
[ -f .planning/BRIEF.md ] && echo "BRIEF: exists"
[ -f .planning/ROADMAP.md ] && echo "ROADMAP: exists"
```

If no git repo: offer to initialize.
Present findings before intake.
</context_scan>

<intake>
Based on scan results:

**If handoff found:**
```
Found handoff: [path]
[Summary from handoff]
1. Resume from handoff
2. Discard handoff, start fresh
```

**If planning structure exists:**
```
Project: [name]
Brief: [exists/missing] | Roadmap: [X phases] | Current: [phase status]

1. Plan next phase
2. Create handoff (stopping for now)
3. View/update roadmap
4. Create PRD / spec
```

**If no planning structure:**
```
No planning structure found.

1. Start new project (create brief + roadmap)
2. Plan a specific feature (no full roadmap needed)
3. Create implementation plan for current task
4. Get guidance on approach
```

**Wait for response before proceeding.**
</intake>

<routing>
| Response | Workflow |
|----------|----------|
| "brief", "new project", "start" | `workflows/create-brief.md` |
| "roadmap", "phases" | `workflows/create-roadmap.md` |
| "plan", "next phase", "feature" | `workflows/plan-phase.md` |
| "execute", "build it", "run it" | `workflows/execute-phase.md` |
| "handoff", "stopping" | `workflows/handoff.md` |
| "resume", "continue" | `workflows/resume.md` |
| "prd", "spec", "requirements" | `workflows/create-prd.md` |
| "guidance", "help" | `workflows/get-guidance.md` |

**After reading the workflow, follow it exactly.**
</routing>

<hierarchy>
Planning artifacts hierarchy:

```
BRIEF.md          → Human vision (you read this)
    ↓
ROADMAP.md        → Phase structure
    ↓
[RESEARCH.md]     → Research prompt (optional)
    ↓
PLAN.md           → THE PROMPT (agent executes this)
    ↓
SUMMARY.md        → Outcome (existence = phase complete)
```

Output structure:
```
.planning/
├── BRIEF.md
├── ROADMAP.md
├── MILESTONES.md           (after first release)
└── phases/
    ├── 01-foundation/
    │   ├── 01-01-PLAN.md
    │   ├── 01-01-SUMMARY.md
    │   └── 01-02-PLAN.md
    └── 02-auth/
        ├── 02-01-RESEARCH.md
        ├── 02-01-FINDINGS.md
        └── 02-02-PLAN.md
```

**Naming:** `{phase}-{plan}-PLAN.md` e.g. `01-03-PLAN.md`
</hierarchy>

<templates_index>
All in `templates/`:

| Template | Purpose |
|----------|---------|
| brief.md | Project vision (greenfield + brownfield) |
| roadmap.md | Phase structure with milestone groupings |
| plan.md | Executable phase prompt (PLAN.md) |
| summary.md | Phase outcome with deviations |
| milestone.md | Milestone entry for MILESTONES.md |
| prd.md | Product requirements document |
</templates_index>

<workflows_index>
All in `workflows/`:

| Workflow | Purpose |
|----------|---------|
| create-brief.md | Create project vision document |
| create-roadmap.md | Define phases from brief |
| plan-phase.md | Create executable phase prompt |
| execute-phase.md | Run phase, create summary |
| handoff.md | Create context handoff for pausing |
| resume.md | Load handoff, restore context |
| create-prd.md | Create PRD through guided discovery |
| get-guidance.md | Help decide planning approach |
</workflows_index>

<success_criteria>
Planning skill succeeds when:
- Context scan runs before intake
- Appropriate workflow selected based on state
- PLAN.md IS the executable prompt (not separate from it)
- Each plan has ≤3 tasks with specific file paths
- Hierarchy maintained: brief → roadmap → plan
- Deviations handled automatically per embedded rules
- All work documented in SUMMARY.md
</success_criteria>
