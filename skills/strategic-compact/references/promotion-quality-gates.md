# Promotion quality gates

Six gates that run BETWEEN steps 7 and 8 of `workflows/self-improvement-pass.md`. Every candidate edit drafted in step 7 must clear ALL six gates before it's presented to the user. Gates exist because the failure mode of this skill is "promote the trigger incident verbatim" — which produces project-specific clutter in skill files that load into every future session.

## Gate 1 — Generic-applicability test

Read the candidate rule aloud as if you were in a *different* project: a Go HTTP service, a Rust CLI, a TypeScript Next.js app, a data-pipeline DAG. Would the rule still make sense? If not, REWRITE it generically or DROP it.

Sub-criteria (verbatim from `feedback-skill-improvements-must-be-generic`):

1. No service names in the rule body.
2. No specific file paths.
3. No project-specific ticket prefixes.
4. Encode the principle, not the trigger incident.
5. Use language-agnostic phrasing where possible.

Diagnostics:
- Rule mentions a specific service name, repo, package, ticket, or file path → too specific. Move the example to "Why:" or to a follow-up bullet under the generic principle.
- Rule encodes a one-off workflow (e.g., "before merging to staging, ping #release-channel") → not a skill rule; that's a runbook entry.
- Rule names a specific dependency (`pytest-mock`, `sensi-redis`, `pydantic v1`) → reword as "the project's test-doubles library" / "the shared cache client" / "the validation library version." The skill body should never lock to a stack version.

If after rewriting the rule is so abstract it stops being actionable, that's a signal it WAS just a project-specific habit. Demote it back to project memory; don't promote.

## Gate 2 — Steel-man the user's intent

A user correction is rarely just about the surface complaint. Before promoting, ask: what is the underlying engineering principle the user is enforcing? Write that as the rule, not the surface complaint.

Worked examples:

| Surface complaint | Promote this, not the surface |
|---|---|
| "stop adding `getattr` to my dataclasses" | "Don't use reflection when you know the type — direct access if the schema is yours." |
| "I asked you to remove the prefix from the workflow name" | "Workflow `name:` is rendered in the GitHub UI and shouldn't repeat context already implied by the repo / parent folder." |
| "why did you keep `sorted(set(x))` at the end?" | "Pick the right collection type at the field — don't carry duplicates and clean up at function exit." |
| "you wrote tests after, not first" | "When a deliverable is non-trivial, the QA plan (tests, smoke, review skills) is part of the plan output, not a follow-up commit." |

The skill rule should match the GENERAL principle. The surface complaint goes in the `Why:` line as the trigger, never as the rule body. This is the difference between a skill that learns and a skill that hoards incidents.

## Gate 3 — Overlap / duplication audit (skills, subagents, hooks, rules)

Before adding a rule to a target skill, grep the entire skill universe for related content. Claude has multiple "sub-brains" — skills, subagents, hooks, `.claude/rules/*.md`, project CLAUDE.md, agents' frontmatter — and overlap between them WASTES context every session because the same rule loads twice (or three times) into the same conversation.

For each candidate:
```bash
grep -rln "<the-rule-keyword>" ~/.claude/skills/ ~/.claude/agents/ ~/.claude/rules/ ~/.claude/CLAUDE.md 2>/dev/null
```

Three outcomes:

1. **Genuinely new.** No similar content anywhere. Proceed to step 8.
2. **Overlapping but complementary** (e.g., `pr-review` already has "self-review your diff," but the new rule adds a specific check). Edit the EXISTING bullet to enrich it, OR add a cross-reference `(see also: ~/.claude/skills/X/SKILL.md §Y)` instead of duplicating the principle.
3. **Already covered.** Drop the candidate. Note in the session output: "rule X is already in `<skill>/SKILL.md` §Y — not re-promoting."

When two skills genuinely BOTH need the rule (e.g., a test-conventions rule belongs in both `testing` and `pr-review`), put the FULL text in the more-foundational skill and a one-line pointer in the other:

```markdown
# In pr-review (the application-side skill):
- Tests use real objects, never MagicMock for domain models.
  See `~/.claude/skills/testing/SKILL.md` §pytest_principles for the full rationale.
```

This single-source-of-truth pattern is the difference between a maintainable rule set and a tangle.

## Gate 4 — Sub-brain placement (which TYPE of extension is right?)

The rule has to land in the right Claude-sub-brain type. Use this decision table:

| If the rule is about… | It belongs in a… | Why |
|---|---|---|
| Behavior during a specific user task ("when reviewing a PR, …") | **Skill** | Loaded on user invocation or matched description |
| A standing convention across ALL tasks ("never commit `.env`") | **Global rule** (`~/.claude/rules/<name>.md` or `CLAUDE.md`) | Always-on, no invocation needed |
| A pre/post-tool safety check ("block `rm -rf /` before it runs") | **Hook** | Deterministic gate at the tool boundary |
| Knowledge a specialist needs ("the testing agent must know our test conventions") | **Subagent `skills:` preload** OR a skill referenced by name in the agent's prompt | Avoids re-stating the rule in the agent's body |
| One-off cross-project nudge ("don't forget to update the changelog") | **Project memory or commit-msg hook** | Skill-clutter risk if promoted globally |

If a candidate doesn't fit a sub-brain cleanly, it's probably project-specific — demote to memory.

## Gate 5 — Token-efficiency check

Every additional bullet in a skill pays a per-session token cost (the skill body loads when invoked, and `description:` fields load into context discovery on every turn). Before adding:

- Can the existing bullet be extended in 1 line instead of adding a new one? (Prefer: lower bullet count.)
- Is the rule a one-time-per-session check? Consider `disable-model-invocation: true` on a tiny dedicated skill the user can `/invoke` — that block has zero context cost when not invoked.
- Is the rule a multi-paragraph explanation? Move the body to `references/<topic>.md` and keep just a one-line trigger in `SKILL.md` — that's the progressive-disclosure pattern.
- Description fields should be ≤120 characters AND specific enough to match real triggers. Anything vaguer is dead weight in context discovery.

Token-conscious phrasing:
- "Before declaring code done, run the 12-point self-review (see references/checklist.md)" — 13 words, routes to detail.
- Bad: Inline 60-line checklist in SKILL.md — 800 tokens loaded every time the skill body is read.

## Gate 6 — Human-feel check

A skill that lists 50 micro-rules reads like a checklist robot — the user pushes back ("you're being mechanical"). A skill that captures the *judgment* a senior engineer would apply reads like genuine guidance.

Before promoting, ask: would I write this rule down in my own engineering notebook? If it's a tiny mechanical check (e.g., "trailing newline on every file"), it belongs in a hook or a linter config, not a skill. Skills should encode the JUDGMENT calls — when to apply a check, what trade-off to accept, when to push back.

Symptoms of over-mechanization:
- Skill body is mostly enumerated lists with no Why lines.
- Rules are commands without exceptions.
- No examples of when to NOT apply the rule.

If a candidate edit smells like a lint rule, route it to the project's linter / pre-commit / hook instead of the skill.