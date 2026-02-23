# Workflow: Create Handoff

<purpose>
Create a context handoff when stopping work mid-session.
Preserves enough context to resume cleanly in a new session.
</purpose>

<process>

<step name="capture_state">
Gather current state:
```bash
git status
git log --oneline -5
ls .planning/phases/*/
```
</step>

<step name="create_handoff">
Create `.planning/phases/{phase}/.continue-here-{phase}-{plan}.md`:

```markdown
# Continue Here: [Phase/Plan]

**Created:** [Date]
**Status:** In progress / Blocked / Ready to resume

## What Was Being Done

[1-2 sentences on the active task]

## Current State

- Last completed: [PLAN/task]
- Next step: [Specific next action]
- Git status: [clean / uncommitted changes]

## Uncommitted Changes

[List files with uncommitted changes, or "None"]

## Context to Load

@.planning/BRIEF.md
@.planning/ROADMAP.md
@.planning/phases/{phase}/{phase}-{plan}-PLAN.md

## Blockers / Open Questions

[Any blockers, or "None"]

## Quick Start

To resume: read this file, then continue with [specific next action].
```
</step>

<step name="git_if_needed">
If there are substantial uncommitted changes, offer to commit them:
"Want me to commit the current progress before stopping?"
</step>

</process>

<success_criteria>
Handoff file exists. A new session starting from this file can resume without re-reading the entire project.
</success_criteria>
