# Apply edits

The APPLY phase. Runs in the MAIN LOOP (not the fork), because per-candidate y/n prompts need `AskUserQuestion`, which forked subagents cannot call.

## Inputs

The candidate list produced by `workflows/self-improvement-pass.md`. Two sources, whichever is available:

1. **Preferred** — the forked subagent's final-output Markdown (already in main-loop context).
2. **Fallback** — `~/.claude/tmp/strategic-compact-candidates-<timestamp>.md` on disk. Read it back if the subagent output truncated or was lost.

## Per-candidate prompt loop

For EACH promotion candidate (informational self-healing entries are surfaced once at the top, not per-prompt):

```
[i/N] <skill>/SKILL.md  (used N× this session)
      Rule: <rule>
      Why:  <reason>
      Diff:
        + - <new bullet>
      Apply? [y / n / skip-skill]
```

Options:
- `y` — apply the Edit.
- `n` — decline this specific edit (the rule may still apply elsewhere; later candidates for the same rule on a different skill are still prompted).
- `skip-skill` — skip ALL remaining edits for this skill (e.g., user declined the whole concept).

Use `AskUserQuestion` for each — three labeled options, the third option being skip-skill when there are more edits queued for this skill.

## On approval (per candidate)

1. **Apply the Edit** to the target SKILL.md. Use the diff exactly as proposed; if the surrounding context drifted since the fork started, re-read the file and adapt to the new context, but preserve the rule text verbatim.
2. **Shrink the source.**
   - **Session-only feedback** (rule came from this session, never been a memory): write a one-line memory note pointing at the now-promoted rule, so the same correction in a future session can be traced. Path: `~/.claude/projects/<project-dir>/memory/feedback-<slug>.md`. Content: a stub like the existing promoted feedback files.
   - **Memory-promoted feedback** (rule came from `feedback_*.md`): shrink the `feedback_*.md` body to a stub that just points at the skill (`See: ~/.claude/skills/<skill>/SKILL.md §<section>`). Keep the frontmatter; drop the body.
3. **Update MEMORY.md index.** If the entry isn't already marked `✅ PROMOTED`, edit the index line to add the marker.
4. **Update the "Don't re-promote" list** at the bottom of MEMORY.md. Append the new entry so a future `/strategic-compact` run skips it in step 4 dedupe.

## On decline (`n`)

Leave files unchanged. Note the decision in the session output so the user sees the trail: `[i/N] <skill> — declined`.

The rule may still apply to a different skill — continue to the next candidate.

## On skip-skill

Skip every remaining candidate whose target skill matches. Note in session output: `<skill>/SKILL.md — skip-skill (N edits skipped)`.

## After the loop

Emit a summary:

```
Applied: M edits across K skills
Declined: P edits
Skipped: Q (skip-skill across R skills)

Memory updates:
- <feedback-file> → shrunk to stub
- MEMORY.md → marked ✅ PROMOTED for <list>
```

Then proceed to `workflows/compaction-decision.md` for the compaction recommendation.

## Self-healing late sweep

If the early self-healing sweep (step 1c of `self-improvement-pass.md`) surfaced findings, re-check them now — applied Edits may have fixed (or worsened) drift. Note any new issues as informational; they don't block the compaction recommendation.