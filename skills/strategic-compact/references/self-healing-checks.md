# Self-healing checks

Maintenance sweep that runs at the START of `workflows/self-improvement-pass.md` (before feedback inventory), then again opportunistically at the END after Edits are applied. The early run lets the user pick candidates with full knowledge of any drift; the late run catches drift introduced by the new edits.

These are MAINTENANCE checks; they DON'T block compaction. Note any findings as "self-healing recommendations" with one-line remediations and proceed.

**Coverage.** Checks span every extension type from `/en/features-overview`: skills, subagents, hooks, commands, rules, MCP, plugins. Each check below specifies which directories it grep/reads.

## Check 1 — Cross-reference rot (across all extension dirs)

For every extension file that links to another file (`See: ~/.claude/skills/X/SKILL.md §Y`, or `~/.claude/agents/`, `~/.claude/rules/`, etc.), confirm the target still exists.

```bash
# List candidate links across all user extensions:
grep -rn "~/.claude/\(skills\|agents\|rules\|commands\|hooks\)/" \
  ~/.claude/skills/ ~/.claude/agents/ ~/.claude/rules/ ~/.claude/commands/ \
  ~/.claude/CLAUDE.md 2>/dev/null | grep -v ":#"
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

## Check 6 — Subagent freshness

For each file in `~/.claude/agents/`, verify:
- `model:` is in the current lineup (see `references/claude-code-best-practices.md` drift-watch). Flag deprecated model IDs.
- `skills:` preload entries all exist in `~/.claude/skills/`. Flag stale references.
- `description:` is specific enough to auto-trigger correctly (Gate 1 of `promotion-quality-gates.md` applies).
- `tools:` list doesn't include tools that don't exist anymore.

```bash
for f in ~/.claude/agents/*.md; do
  echo "=== $f ==="
  awk '/^---/{c++} c==1' "$f"   # frontmatter only
done
```

For each preloaded skill that's missing, prompt: remove from `skills:` or restore the skill.

## Check 7 — Hook script existence + event roster

For every `type: command` hook in `~/.claude/settings.json`, the `command:` path must resolve to an executable file. Stale paths silently no-op.

```bash
python3 -c "
import json, os
s = json.load(open(os.path.expanduser('~/.claude/settings.json')))
for event, entries in (s.get('hooks') or {}).items():
    for e in entries:
        for h in (e.get('hooks') or []):
            if h.get('type') == 'command':
                cmd = (h.get('command') or '').replace('\$CLAUDE_PROJECT_DIR', '.')
                path = cmd.split()[0] if cmd else ''
                exp = os.path.expandvars(os.path.expanduser(path))
                if exp and not os.path.exists(exp):
                    print(f'MISSING [{event}]: {exp}')
"
```

Also confirm each registered event is still in the current event roster (drift-watch lists ~30). Flag deprecated events as candidates for removal.

## Check 8 — Rule duplication across CLAUDE.md / rules / skills

A rule duplicated between `~/.claude/CLAUDE.md`, `~/.claude/rules/*.md`, and a skill body loads 2-3× into every session. Per Gate 3, single-source-of-truth wins.

```bash
# For each distinctive bullet in CLAUDE.md, grep across rules + skills:
grep -rln "<distinctive phrase>" ~/.claude/rules/ ~/.claude/skills/ ~/.claude/CLAUDE.md 2>/dev/null
```

When a rule is duplicated, keep the FULL text in the most-foundational location (CLAUDE.md if truly always-on; rules/ if path-scoped; skill if task-scoped) and replace the others with a one-line pointer.

Also flag `~/.claude/CLAUDE.md` if its line count exceeds 200 (per `/en/memory` guidance, move reference content to skills or `.claude/rules/`).

## Check 9 — MCP server health

`/en/mcp` says tool names load at session start; full schemas defer until use. Idle servers cost little, but stale/broken servers add noise.

Prompt the user (forked subagents can't run slash commands):

```
Self-healing wants /mcp output to check server health. Please run `/mcp`
and paste the result here (or type "skip").
```

If pasted, flag:
- Servers in "failed to connect" state → recommend removal or fix.
- Servers with zero tool calls this session → candidates for disconnect (if not on a planned-soon task).
- Servers exposing duplicate tools (e.g., two GitHub MCP servers) → keep one.

## Check 10 — Plugin / marketplace cohesion

`/en/plugins` says plugins bundle skills/hooks/subagents/MCP into installable units. Two signals:

- If `~/.claude/` has 3+ extensions related to one workflow (e.g., a "deploy" skill + "deploy-status" subagent + "post-deploy" hook), recommend bundling as a plugin for portability.
- If a plugin is installed but none of its skills/hooks fired this session, flag as a candidate for removal.

```bash
grep -A1 '"plugins"\|"marketplaces"' ~/.claude/settings.json 2>/dev/null
ls ~/.claude/plugins/ 2>/dev/null
```