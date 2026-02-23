# Brief Template

## Greenfield Brief (New Project)

Save as `.planning/BRIEF.md`:

```markdown
# [Project Name]

**One-liner**: [What this is in one sentence]

## Problem

[What problem does this solve? Why does it need to exist? 2-3 sentences.]

## Success Criteria

How we know it worked:

- [ ] [Measurable outcome 1]
- [ ] [Measurable outcome 2]
- [ ] [Measurable outcome 3]

## Constraints

- [Tech stack, timeline, budget, or key dependencies]
- [Constraint 2]

## Out of Scope

What we're NOT building (prevents scope creep):

- [Not doing X]
- [Not doing Y]
```

<guidelines>
- Keep under 50 lines
- Success criteria must be measurable/verifiable
- Out of scope prevents "while we're at it" creep
- This is the only human-focused document
</guidelines>

---

## Brownfield Brief (Existing Project, v1.1+)

After shipping v1.0, update BRIEF.md:

```markdown
# [Project Name]

## Current State (Updated: YYYY-MM-DD)

**Shipped:** v[X.Y] (YYYY-MM-DD)
**Status:** [Production / Beta / Internal]
**Codebase:** [X,XXX] lines of [primary language], [key tech stack]
**Known Issues:** [Issues to address, or "None"]

## v[Next] Goals

**Vision:** [What's the goal for next iteration?]
**Scope:**
- [Feature/improvement 1]
- [Feature/improvement 2]

**Success Criteria:**
- [ ] [Measurable outcome 1]
- [ ] [Measurable outcome 2]

**Out of Scope:**
- [Not doing X in this version]

---

<details>
<summary>Original Vision (v1.0)</summary>

**One-liner**: [Original one-liner]

## Problem
[Original problem statement]

## Success Criteria
- [x] [Achieved outcome 1]
- [x] [Achieved outcome 2]
</details>
```
