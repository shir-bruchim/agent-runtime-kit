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

1. WebFetch `https://code.claude.com/docs/en/features-overview` FIRST — this is the canonical map of every Claude Code extension type (skills, subagents, hooks, commands, MCP, plugins, agent teams, artifacts, code intelligence, CLAUDE.md/rules). It tells you what categories the audit must cover.
2. WebFetch `https://code.claude.com/docs/en/skills` to confirm the frontmatter fields snapshot in `references/claude-code-best-practices.md` is still current.
3. If a candidate touches hooks/subagents/MCP/plugins/agent-teams: WebFetch the matching `/en/<topic>` doc.
4. If any live doc contradicts the local snapshot, note it in the session output — fix the snapshot AFTER the user's promotion decisions land.

Token budget: ~15-40k (1-4 WebFetch calls). It prevents promoting against a stale doc AND prevents the SCAN from ignoring an extension category that's grown since the last run.

## Step 1 — Inventory the FULL extension universe AND session usage

The audit covers EVERY Claude extension type from `/en/features-overview`, not just skills. This is what makes Gate 4 (sub-brain placement) accurate — without it, every rule looks like a skill rule by default.

**Run the inventory script** — one call, structured output covering all extension types:

```bash
bash ~/.claude/skills/strategic-compact/scripts/scan-inventory.sh
```

This emits sections (each prefixed with `=== NAME ===`) for: SKILLS, SUBAGENTS, COMMANDS, RULES (with line counts), CLAUDE_MD (present/absent + line count), HOOK_SCRIPTS, HOOKS_CONFIG (parsed from settings.json: event / matcher / type / target / if-condition), MCP, PLUGINS, SKILL_LENGTHS, TIMESTAMP_UTC. Parse the sections you need; you do NOT need to re-run any of the underlying `ls` / `grep` / `python3` commands.

If the SKILL.md `<universe>` block already inlined these via dynamic context injection, you can SKIP the script call — the inventory is already in your context. The script exists for fresh-fork invocations where that injection didn't run.

**Session usage** (still requires walking the visible conversation — no script can read your context). Count:
- `<command-name>` tags (e.g., `<command-name>/pr-review</command-name>`)
- `<command-message>` tags
- Direct `Skill` tool calls
- Slash-commands typed in user messages (`/implement-jira-ticket`, `/ship`, `/commit`, `/pr-review`, etc.)
- Skills auto-invoked by Claude in response to a user request
- `Agent` tool calls — capture `subagent_type=<name>` for subagent usage counts

Output: `SKILLS_USED = [{name, count}, ...]` and `SUBAGENTS_USED = [{name, count}, ...]` sorted by count descending.

**Frontmatter reads.** For each subagent, Read its frontmatter and capture: `name`, `description`, `model`, `tools`, `skills:` preload list, `memory`, `maxTurns`, `isolation`. For each rule, capture `paths:`/`description:`. The script gave you the file lists; you do the Read passes.

**Cross-check hook scripts.** The script's HOOKS_CONFIG section lists every configured hook with its target path. Cross-reference each `type: command` target against HOOK_SCRIPTS (which lists what exists on disk). The `self-healing-sweep.sh` script (run in step 1c) does this check automatically with shell-builtin filtering — you don't need to repeat it manually unless you want the data inline now.

**Command-vs-skill duplication.** For each command in the COMMANDS section, check if a skill of the same name exists in SKILLS. Flag duplicates (one should be deleted) and commands > ~30 lines (candidates for promotion to skill form with `workflows/` subdir).

**CLAUDE_MD section.** If the script reports `ABSENT`, several self-healing checks have nothing to introspect — note this and proceed. If line count exceeds 200, per `/en/memory` move reference content to skills/rules.

**MCP and plugins.** If the MCP section reports `(none in settings.json — may be configured at plugin/project scope)`, your visible context's tool list is the only authoritative source — prompt the user to paste `/mcp` output if you need connection status (forked subagents can't run slash commands).

## Step 1b — Detect repeat-use as under-specification signal

Any skill in `SKILLS_USED` invoked **3+ times in this session** is a candidate for tightening. Common reasons:

- Skill body too thin — does only step 1 of what should be multi-step.
- Triggers too narrow — user re-invokes for adjacent cases the skill should handle.
- No checkpoint/loop — skill ends after one cycle when natural shape is iterate-until-done.
- Output incomplete — partial findings; user invokes again to get the rest.

For each repeat-used skill, Read its `SKILL.md` and form a hypothesis: *what is missing that would have made one invocation sufficient?* Mark these `[repeat-use]` instead of `[from-feedback]`.

## Step 1c — Run self-healing sweep EARLY

Run the mechanical checks via the script:

```bash
bash ~/.claude/skills/strategic-compact/scripts/self-healing-sweep.sh
```

Output covers the four mechanical checks: XREF_ROT (broken `~/.claude/<x>/<y>` links across skills/agents/rules/commands, with known-optional paths filtered — `SCAN_STRICT_XREF=1` to see suppressed entries), STALE_PROMOTIONS (every `feedback-*.md` stub marked promoted, with its skill-pointer resolution status), DESC_LENGTH (SKILL.md descriptions over the 120-char target), HOOK_EXISTENCE (missing hook scripts, with shell-builtin awareness).

The remaining checks from `references/self-healing-checks.md` require LLM reasoning and stay manual: Check 3 (duplication drift — semantic, not lexical), Check 5 (repeat-use signal recurrence — needs the per-run log), Check 6 (subagent freshness — frontmatter judgment), Check 8 (rule duplication across CLAUDE.md / rules / skills — semantic), Check 9 (MCP server health — needs user-pasted `/mcp` output), Check 10 (plugin / marketplace cohesion). Read `references/self-healing-checks.md` for the criteria; the script handled the bash.

If duplicate-drift or cross-reference rot exists, the user needs to see it before picking candidates in step 8 — they might pick differently or skip a duplicate.

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

## Step 5 — List candidate destinations (skill, subagent, hook, rule)

`CANDIDATE_DESTINATIONS = (SKILLS_USED ∪ SUBAGENTS_USED ∪ ALL_HOOKS ∪ ALL_RULES)` filtered to entries where at least one feedback rule maps to them. Per Gate 4, a rule belongs in the right TYPE of extension — don't auto-default to a skill.

## Step 6 — Match feedback → extension (many-to-many across all 4 types)

For each rule in `ALL_FEEDBACK`, decide which extension(s) in `CANDIDATE_DESTINATIONS` are the natural home. A single rule can land in multiple targets. Heuristics:

- Test conventions → skill: `testing`, `implement-jira-ticket`, `tdd-guide`
- Code-review judgement → skill: `pr-review`, `code-review`
- Self-review before presenting → skill: `pr-review`, `implement-jira-ticket`
- Git commit / PR description conventions → skill: `git`, `pr-review`, `commit`, `pr`
- Naming, layer separation, package-reuse → typically already in `pr-review` skill lens
- Always-on convention ("never commit `.env`") → rule: `~/.claude/CLAUDE.md` or `~/.claude/rules/<topic>.md`
- Pre/post-tool safety check ("block `rm -rf /`") → hook: `~/.claude/settings.json` `PreToolUse` entry
- Specialist agent knowledge ("the testing agent must know X") → subagent: edit `~/.claude/agents/<name>.md` body OR add to `skills:` preload list
- Workflow ordering (project-specific) — leave in project memory

If a feedback rule has no natural extension home, leave it in memory; do NOT create a new skill from a single rule.

Output: `EDITS = [{target_path, target_type, rule, why, source, location_hint}, ...]` where `target_type ∈ {skill, subagent, hook, rule, memory}`. Sort by `usage_count(target)` descending.

## Step 7 — Build a diff per candidate

For each entry in `EDITS`, Read the target file and craft a minimal Edit based on `target_type`:

**target_type = skill**
- Existing `<best_practices>` block — append a new bullet
- Existing `<when_to_activate>` block — extend triggers
- New `<lessons_learned>` or `<rules>` block at the bottom — only if no natural section exists

**target_type = subagent** (`~/.claude/agents/<name>.md`)
- Body has a `<review_checklist>` / `<conventions>` / `<best_practices>` block — append a bullet
- Or add the rule to the agent's `skills:` preload list (cleaner than restating in the body)

**target_type = hook** (`~/.claude/settings.json`)
- New entry in the appropriate `hooks.<event>` array
- For `command` type: path to a script in `~/.claude/hooks/`
- For `prompt` type: inline LLM-evaluated prompt (use when reasoning is needed)

**target_type = rule** (`~/.claude/CLAUDE.md` or `~/.claude/rules/<topic>.md`)
- Existing section — append a bullet
- New rule file — only if no existing rule file covers the topic
- Add `paths:` frontmatter if the rule is path-scoped (saves context)

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
- (informational; not approval-prompted; covers skills, subagents, hooks, rules, MCP, plugins)
- ...

## Drift-watch (new features since last snapshot)
- (informational; surfaces capabilities from /en/features-overview not yet adopted locally)
- Example: "Agent teams (/en/agent-teams) — recommend adopting for parallel review workflows"
- ...

## Promotion candidates

[1/N] <target_type>: <target_path>  (used N× this session, gates: all passed)
      Rule: <imperative-voice rule>
      Why:  <one-line reason>
      Source: <session feedback "..." | memory: feedback_X.md>
      Diff:
        + - <new bullet>
      Apply? [main loop will prompt y/n/skip-skill]

[2/N] ...
```

The `target_type` prefix (skill / subagent / hook / rule) tells the APPLY phase which file family to edit and which validation to run.

The main-loop phase reads this, prompts per-candidate, and routes approvals to `workflows/apply-edits.md`.

## Skip conditions

Skip the whole pass and go straight to compaction-decision if:
- No `feedback_*` memories exist AND the session contained no corrections worth promoting.
- All candidate rules are project-specific.
- The user explicitly said "skip self-improvement" or "just compact".