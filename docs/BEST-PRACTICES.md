# Best Practices

Patterns and principles that make AI-assisted development effective.

---

## Skill Design

**Keep SKILL.md under 500 lines.**
Put detailed content in `references/`, `templates/`, and `workflows/` subdirectories. The skill file is an intake router, not an encyclopedia.

**Use XML tags, not markdown headings.**
`<objective>`, `<process>`, `<success_criteria>` parse cleanly. `##` headings in skill bodies create noise.

**Write descriptions that trigger correctly.**
The `description` field in frontmatter determines when a skill or subagent is used. Be specific about the trigger condition:

```yaml
# Bad — too generic
description: Helps with code

# Good — specific trigger
description: Systematic bug investigation. Use when debugging errors, unexpected behavior, or performance issues.
```

**Progressive disclosure.**
Start with the summary. Link to details. Don't front-load everything.

---

## Subagent Design

**Subagents are black boxes.**
They cannot interact with the user. They receive a prompt, do work, return a result. Design them for autonomous operation.

**Use least-privilege tools.**
Only grant the tools the subagent needs:

```yaml
# Read-only analysis agent
tools: Read, Grep, Glob

# Code-generating agent
tools: Read, Write, Edit, Bash

# Architecture thinker — no tools needed
tools: (omit — inherits none)
```

**Match model to complexity:**
- `haiku` for mechanical tasks (running git commands, formatting)
- `sonnet` for code generation and review
- `opus` for architecture, planning, complex reasoning

**One subagent per domain.**
A `tester` subagent writes tests. A `reviewer` subagent reviews code. They don't do both. Specialization = reliability.

---

## Planning

**Start plans earlier than you think.**
Context degrades at 40-50%, not 80%. If a task has more than ~3 steps, write a PLAN.md first.

**Maximum 2-3 tasks per plan.**
Each task should be completable in a single focused session. Break larger work into phases.

**Include exact file paths.**
Vague plans ("update the auth module") are worse than no plan. Good plans say:
```
File: src/auth/middleware.py
Action: Add JWT validation before route handlers
Done when: All routes return 401 for missing/invalid tokens
```

**The planning hierarchy:**
```
.planning/
├── BRIEF.md       → Goals and constraints (write first)
├── ROADMAP.md     → Milestones and phases
└── phases/
    ├── 01-phase-PLAN.md    → Specific tasks with file paths
    └── 01-phase-SUMMARY.md → What was built, what changed
```

---

## Git Workflow

**Conventional commits are not optional.**
Every commit: `type(scope): description`

```
feat(auth): add JWT token refresh
fix(api): handle empty response from upstream
docs(readme): update installation steps
refactor(db): extract connection pooling logic
test(auth): add cases for expired tokens
```

**Never force-push to main/master.**
The `block-dangerous-bash.sh` hook will catch this, but configure it in your team norms too.

**PRs should be small.**
One feature, one PR. Large PRs don't get reviewed well.

---

## Security

**The security hooks are defaults, not ceilings.**
`block-dangerous-bash.sh` covers common patterns but add your own blocking rules for project-specific concerns.

**Protected files never get edited directly.**
Configure `protect-files.sh` with the paths that matter: `.env`, `secrets/`, production configs.

**Security review on every PR.**
Use the `security` subagent automatically: "Use the security subagent to review this PR before merging."

**MCP servers carry risk.**
Only add MCP servers you trust. Each server is a potential attack surface. Review `mcp/recommended-servers.json` before installing.

---

## Testing

**Tests are not optional.**
The `tdd` skill enforces red-green-refactor. Start with a failing test, then make it pass.

**Test file placement matters:**
- Python: `tests/test_<module>.py` or `<module>_test.py`
- TypeScript: `<module>.test.ts` alongside the module
- Go: `<module>_test.go` alongside the module

**Use the tester subagent for coverage.**
When you've added a feature, run: "Use the tester subagent to write comprehensive tests for [feature]."

---

## Working With Commands

**`/ship` is for when you're confident.**
It runs commit + push + PR in one go. Use it when changes are clean and tested. Use `/commit` + `/push` separately when you want checkpoints.

**`/spec-interview` before building anything significant.**
Skipping requirements gathering is how you build the wrong thing. The spec-interview skill asks the right questions.

**`/review` before merging.**
Self-review catches obvious issues. The review command looks at recent changes and gives structured feedback.

---

## Meta-Skills (Creating New Skills)

**Use `create-ai-skills` to build skills, not raw writing.**
The meta-skill knows the patterns. Let it guide you.

**Test skills with representative inputs.**
Before committing a skill, test it with 2-3 realistic prompts. Does it trigger at the right time? Does it produce useful output?

**Keep skills focused.**
A skill for "Python" is too broad. A skill for "Python database migrations with Alembic" is appropriately scoped.

**Skills that reference other skills are powerful.**
The planning skill references the spec-interview skill. The security skill references the git workflow. Cross-references enable compound behaviors.

---

## Context Management

**Long conversations degrade.**
After ~50% context, start a fresh conversation and paste the relevant plan/summary.

**Use PLAN.md as handoffs.**
When ending a session: write a SUMMARY.md in `.planning/phases/`. When starting a new session: point the agent to it.

**Subagents protect main context.**
Delegate research-heavy tasks to subagents. Their context stays isolated. The main conversation stays clean.

---

## MCP Servers

**Start with less.**
Add MCP servers as you need them, not all at once. Each server adds capability and risk.

**Filesystem MCP requires explicit paths.**
Configure it to only access the directories it needs, not your entire home directory.

**Test MCP connections before relying on them.**
Run a simple query with each server before building workflows that depend on it.
