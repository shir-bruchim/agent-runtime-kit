---
name: planning
description: Create phase-based plans with file paths and verification. Use for features, refactors, or multi-step work.
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

<principle name="qa_section_required">
Every PLAN.md must include a `## QA / Verification` section enumerating HOW the plan's work gets validated end-to-end. Not optional. Without it, "done" means "code compiles" instead of "code is production-ready" — and the user re-reviews everything you should have reviewed yourself.

Required sub-items in the QA section:

1. **Skills to invoke** — list the relevant skills (e.g., `testing`, `tdd-guide`, `pr-review`, `security`, `verification-loop`, `debugging`). Plans that touch test code should ALWAYS list `testing`. Plans that ship to production should ALWAYS list `security` and `pr-review`.
2. **Subagent fan-out** — for any plan with ≥3 independent modules, list the parallel subagent invocations (e.g., `tester` per module, `reviewer` on the diff, `security` audit, `web-research` on idioms). Default to spawning these in one message so they run concurrently.
3. **Per-module unit tests** — one line per new module/script: test file path + key behaviors covered. "Module exists" doesn't satisfy this; "what does it do?" → "test it."
4. **Smoke run** — the exact command that proves end-to-end wiring (e.g., `make load-test ENV=local`, `pytest tests/ -q`, `docker compose --profile X up`). If no such command exists, propose adding one.
5. **Pre-commit gates** — what runs locally before commit (pytest, flake8, the project's pr-review skill, etc.).
6. **CI-coverage check** — for every new test file: confirm it actually runs in CI. If the service Dockerfile `--ignore`s it, the plan must add a compensating GHA step.

Before declaring the plan "complete" or marking phase-tasks done, the plan author re-reads the QA section and only marks complete what was actually executed. Subagents are part of the plan's execution surface, not an afterthought.
</principle>

<principle name="planning_folder_hygiene">
`.planning/` is the user's primary durable context source — loaded into every future session via CLAUDE.md / MEMORY. Two rules:

1. **Always update `.planning/` before/during related work.** When a phase ships, when a decision lands, when scope changes — reflect it in the relevant `PLAN.md` / `ROADMAP.md` / `SUMMARY.md` *before* the conversation ends. The user (or future-you in a new session) expects to come back later and find an accurate picture.

2. **Prune done phases — but only after verifying done.** When a phase's deliverable has merged (or rolled into a later phase), it's fine to delete or archive that phase folder. NEVER delete based on assumption — verify via `git log` / PR status / on-disk artifacts. Don't prune just because something LOOKS old. If unsure, archive to `.planning/archive/` instead of deleting.

`.planning/` is usually gitignored. That's intentional — it's local-only context, not a deliverable. Code that needs to be tracked lives outside `.planning/`. Don't put committable code there.
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
| "spec interview", "requirements gathering", "interview" | `workflows/spec-interview.md` |
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
| spec-interview.md | Requirements gathering through structured interview |
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
