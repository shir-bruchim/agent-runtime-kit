# Self-healing checks

Maintenance sweep that runs at the START of `workflows/self-improvement-pass.md` (before feedback inventory), then again opportunistically at the END after Edits are applied. The early run lets the user pick candidates with full knowledge of any drift; the late run catches drift introduced by the new edits.

These are MAINTENANCE checks; they DON'T block compaction. Note any findings as "self-healing recommendations" with one-line remediations and proceed.

## Check 1 — Cross-reference rot

For every skill that links to another file (`See: ~/.claude/skills/X/SKILL.md §Y`), confirm §Y still exists.

```bash
# List candidate links across all user skills:
grep -rn "~/.claude/skills/" ~/.claude/skills/ 2>/dev/null | grep -v ":#"
```

For each link found, Read the target file and grep for the section anchor. If a referenced section was renamed or removed:
- Update the link in-place if the new section name is obvious.
- Otherwise open a follow-up note in the session output: "broken link: `<src>` → `<dst>` §Y".

## Check 2 — Stale promotions

Any feedback memory stub that points at a skill section that no longer exists.

```bash
grep -l "Promoted" ~/.claude/projects/*/memory/feedback-*.md 2>/dev/null
```

For each stub, follow its skill pointer. If the section is gone:
- Re-promote (the rule is still wanted), OR
- Re-park as a project memory (the rule was reverted intentionally — restore the original body).

## Check 3 — Duplication drift

Any rule that now appears verbatim in 2+ skills.

```bash
# Heuristic: grep for the first 6-8 distinctive words of each rule across skills.
grep -rln "<distinctive phrase>" ~/.claude/skills/ 2>/dev/null
```

When two skills genuinely BOTH need the rule, keep the FULL text in the more-foundational skill and replace the duplicate with a cross-reference. See Gate 3 of `promotion-quality-gates.md` for the single-source-of-truth pattern.

## Check 4 — Description-field health

Any skill with `description:` longer than ~120 chars, or vague enough that Claude wouldn't match it correctly. Propose a tightening.

```bash
# Extract description: lines and flag oversize ones:
for f in ~/.claude/skills/*/SKILL.md; do
  desc=$(awk '/^description:/{flag=1} flag{print; if(/[^\\]$/ && !/^description:/)flag=0}' "$f" | head -5 | tr -d '\n')
  len=${#desc}
  [ "$len" -gt 200 ] && echo "OVERSIZE ($len chars): $f"
done
```

The combined cap of `description` + `when_to_use` is 1,536 characters per the live docs. Anything over ~200 chars on `description` alone is a tightening candidate.

**Also surface `/doctor` output.** Claude Code's `/doctor` slash-command reports skill-listing health (which descriptions got trimmed/dropped because the listing budget overflowed). The skill itself cannot invoke `/doctor` — prompt the user:

```
Self-healing wants /doctor output. Please run `/doctor` and paste the result here (or type "skip" to continue without it).
```

If the user pastes output, scan for "trimmed" or "dropped" or "exceeded budget" lines and report those skills as candidates for description-tightening.

## Check 5 — Repeat-use signal recurrence

If the same skill was flagged for repeat-use in 2+ consecutive `/strategic-compact` runs, the body is still under-specified — recommend a focused expansion pass (separate from this run's promotions).

Track this lightly: write a one-line note to `~/.claude/tmp/strategic-compact-repeat-use.log` per run (skill name + date + count). Each invocation reads the log, compares against the current run's `SKILLS_USED` repeat-use list, and surfaces the recurrence count.