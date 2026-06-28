# Self-improvement pass (forked-scan workflow)

This workflow is the SCAN phase of `/strategic-compact`. It runs in a forked subagent (per `context: fork` in SKILL.md) and produces a structured candidate list for the main loop to act on.

**ALWAYS run this BEFORE recommending compaction.** A few seconds of cross-referencing now saves a re-correction in the next session.

Two evidence sources: the live conversation AND the auto-memory. Produces a *prioritized* list of skill edits, not just one. Run all steps in order; do NOT short-circuit after finding a single match.

## Output contract (read this first)

The forked subagent's final output must be a Markdown candidate list AND must also be written to a known path the main loop reads back. The dual path is the belt-and-suspenders approach — if the subagent return truncates, the main loop falls back to the file.

Path: `~/.claude/tmp/strategic-compact-candidates-<YYYYMMDD-HHMMSS>.md`

The main loop will:
1. Read the file (or parse the subagent return).
2. Walk each candidate and prompt the user per-entry.
3. Apply approved Edits via `workflows/apply-edits.md`.

## Step 0 — Freshness check

Run BEFORE step 1. Same pattern as `~/.claude/skills/extend-agent/SKILL.md` `<freshness_check>`.

1. WebFetch `https://code.claude.com/docs/en/skills` to confirm the frontmatter fields snapshot in `references/claude-code-best-practices.md` is still current.
2. If a candidate touches hooks/subagents: WebFetch the matching doc.
3. If the live doc contradicts the local snapshot, note it in the session output — fix the snapshot AFTER the user's promotion decisions land.

Token budget: ~10-30k. It prevents promoting against a stale doc.

## Step 1 — Inventory skill universe AND session usage

Two scans, both required. They feed different parts of the analysis.

(a) **Full universe.** SKILL.md uses dynamic context injection to inline the list (`!`ls ~/.claude/skills/``); when running this workflow in a fresh fork without that injection, run:
```bash
ls ~/.claude/skills/
```
Skip plugin skills (read-only) and built-in commands (`/init`, `/commit`, `/push`, `/review`). Output: `ALL_SKILLS = [...]`.

(b) **Session usage.** Walk the visible conversation top-to-bottom and count skill invocations. Look for:
- `<command-name>` tags (e.g., `<command-name>/pr-review</command-name>`)
- `<command-message>` tags
- Direct `Skill` tool calls
- Slash-commands typed in user messages (`/implement-jira-ticket`, `/ship`, `/commit`, `/pr-review`, etc.)
- Skills auto-invoked by Claude in response to a user request

Output: `SKILLS_USED = [{name, count}, ...]` sorted by count descending.

## Step 1b — Detect repeat-use as under-specification signal

Any skill in `SKILLS_USED` invoked **3+ times in this session** is a candidate for tightening. Common reasons:

- Skill body too thin — does only step 1 of what should be multi-step.
- Triggers too narrow — user re-invokes for adjacent cases the skill should handle.
- No checkpoint/loop — skill ends after one cycle when natural shape is iterate-until-done.
- Output incomplete — partial findings; user invokes again to get the rest.

For each repeat-used skill, Read its `SKILL.md` and form a hypothesis: *what is missing that would have made one invocation sufficient?* Mark these `[repeat-use]` instead of `[from-feedback]`.

## Step 1c — Run self-healing sweep EARLY

Run `references/self-healing-checks.md` BEFORE feedback inventory. If duplicate-drift or cross-reference rot exists, the user needs to see it before picking candidates in step 8 — they might pick differently or skip a duplicate.

Findings go into the candidate list output as a top section: "Self-healing recommendations" — not promotion candidates, but informational entries for the user.

## Step 2 — Inventory session feedback

Re-read user messages in the visible conversation. Extract every directive, correction, non-obvious preference:

- **Corrections** — "no, do X instead", "stop doing Y", "that's wrong because…"
- **Preferences expressed once** — "use real objects, never MagicMock for models"
- **Confirmations of non-obvious choices** — "yes that was the right call"
- **Reasoning the user provided** — "X depends on Y, so the order matters" (often become `Why:` lines)

Output: `SESSION_FEEDBACK = [{rule, why, how_to_apply, source_quote}, ...]`. Include the source quote verbatim.

## Step 3 — Read the memory index

Open `~/.claude/projects/<project-dir>/memory/MEMORY.md`. List every `feedback_*.md` link, then read each one.

Output: `MEMORY_FEEDBACK = [{rule, why, how_to_apply, file_path}, ...]`.

## Step 4 — Merge and dedupe

Combine `SESSION_FEEDBACK + MEMORY_FEEDBACK`. If a session rule restates a memory rule almost word-for-word, drop the duplicate (memory wins — canonical phrasing). Result: `ALL_FEEDBACK`.

Also drop anything already on the "Don't re-promote" list in `MEMORY.md` (the index marks promoted entries with ✅ PROMOTED).

## Step 5 — List candidate skills

`CANDIDATE_SKILLS = SKILLS_USED ∪ {natural-home skills for any feedback that didn't fire this session}`. Skills used this session are first-class targets; other user skills only candidates if a feedback rule clearly maps to them.

## Step 6 — Match feedback → skill (many-to-many)

For each rule in `ALL_FEEDBACK`, decide which skill(s) in `CANDIDATE_SKILLS` are the natural home. A single rule can land in multiple skills. Heuristics:

- Test conventions → `testing`, `implement-jira-ticket`, `tdd-guide`
- Code-review judgement → `pr-review`, `code-review`
- Self-review before presenting → `pr-review`, `implement-jira-ticket`
- Git commit / PR description conventions → `git`, `pr-review`, `commit`, `pr`
- Naming, layer separation, package-reuse → typically already in `pr-review` lens
- Workflow ordering (project-specific) — leave in project memory

If a feedback rule has no natural skill home, leave it in memory; do NOT create a new skill from a single rule.

Output: `EDITS = [{skill_path, rule, why, source, location_hint}, ...]`. Sort by `usage_count(skill)` descending.

## Step 7 — Build a diff per candidate

For each entry in `EDITS`, Read the target SKILL.md and craft a minimal Edit:
- Existing `<best_practices>` block — append a new bullet
- Existing `<when_to_activate>` block — extend triggers
- New `<lessons_learned>` or `<rules>` block at the bottom — only if no natural section exists

Bullet format:
```
- <rule, imperative voice>. Why: <one-line reason>. (from <source>)
```
Source is `session feedback: "<quote>"` or `memory: feedback_<name>.md`.

## Step 7b — Run the 6 promotion quality gates

Apply `references/promotion-quality-gates.md` to EVERY candidate. Each must clear all 6 gates:

1. Generic-applicability (with 5 sub-criteria — no service names, no file paths, no ticket prefixes, principle-not-incident, language-agnostic)
2. Steel-man the user's intent
3. Overlap / duplication audit
4. Sub-brain placement (skill / global rule / hook / subagent preload)
5. Token efficiency
6. Human-feel check

Candidates that fail a gate: REWRITE in-place or DROP (note why). Only survivors proceed to step 8.

## Step 8 — Emit candidate list

Write the candidate list to `~/.claude/tmp/strategic-compact-candidates-<timestamp>.md` AND return the SAME content as the forked-subagent's final output. Dual path: the main loop reads whichever arrives intact.

Format:

```markdown
# Strategic-compact candidates — <timestamp>

## Self-healing recommendations
- (informational; not approval-prompted)
- ...

## Promotion candidates

[1/N] <skill>/SKILL.md  (used N× this session, gates: all passed)
      Rule: <imperative-voice rule>
      Why:  <one-line reason>
      Source: <session feedback "..." | memory: feedback_X.md>
      Diff:
        + - <new bullet>
      Apply? [main loop will prompt y/n/skip-skill]

[2/N] ...
```

The main-loop phase reads this, prompts per-candidate, and routes approvals to `workflows/apply-edits.md`.

## Skip conditions

Skip the whole pass and go straight to compaction-decision if:
- No `feedback_*` memories exist AND the session contained no corrections worth promoting.
- All candidate rules are project-specific.
- The user explicitly said "skip self-improvement" or "just compact".