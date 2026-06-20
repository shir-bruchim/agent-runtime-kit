---
name: strategic-compact
description: Suggests manual context compaction at logical intervals to preserve context through task phases rather than arbitrary auto-compaction. Use when context is getting large, working on a long multi-phase task, or asking about context management strategies. ALSO performs a skill self-improvement pass before compacting — scanning recent feedback memories AND the session for rules that should be promoted into a relevant skill so future runs of any skill won't need the same correction.
---

<objective>
Two responsibilities, run in order:

1. **Skill self-improvement pass** (always — runs FIRST before any compaction action). Scan the session conversation AND auto-memory for accumulated feedback, cross-reference against the user's skills in `~/.claude/skills/`, and propose edits that promote recurring per-conversation feedback into the relevant skill so the user doesn't have to give the same correction twice. Detect repeat-use of the same skill within one session as an under-specification signal.

2. **Strategic compaction guidance.** Guide `/compact` at logical task boundaries instead of relying on arbitrary auto-compaction. Auto-compaction fires at unpredictable points — often mid-task — losing important context. Strategic compaction preserves what matters by compacting between phases.
</objective>

<self_improvement_pass>

**ALWAYS run this BEFORE recommending compaction.** A few seconds of cross-referencing now saves a re-correction in the next session.

The pass has two evidence sources — the live conversation AND the auto-memory — and produces a *prioritized* list of skill edits, not just one. Run all steps in order; do NOT short-circuit after finding a single match.

<step number="1">
**Inventory the full skill universe AND this session's usage.** Two scans, both required every run.

(a) **Full universe.** List every user skill on disk:
```bash
ls ~/.claude/skills/
```
Skip plugin skills (read-only) and built-in commands (`/init`, `/commit`, `/push`, `/review`). Output: `ALL_SKILLS = [...]`.

(b) **Session usage.** Walk the visible conversation top-to-bottom and count skill invocations. Look for `<command-name>` tags, `<command-message>` tags, direct `Skill` tool calls, slash-commands typed by the user, and skills auto-invoked by the agent in response to a user request. Output: `SKILLS_USED = [{name, count}, ...]` sorted descending.
</step>

<step number="1b">
**Detect repeat-use as an under-specification signal.** Any skill in `SKILLS_USED` invoked **3 or more times in this session** is a candidate for tightening — the user shouldn't need to reach for the same skill repeatedly within a single task. Common reasons:
- Skill body is too thin — does only step 1 of what should be a multi-step workflow.
- Triggers are too narrow — user has to re-invoke for adjacent cases the skill should handle.
- No checkpoint/loop — skill ends after one cycle when the natural shape is iterate-until-done.
- Output is incomplete — produces partial findings; user invokes again to get the rest.

For each repeat-used skill, read its `SKILL.md` and form a hypothesis: *what is missing that would have made one invocation sufficient?* Mark these clearly: `[repeat-use]` instead of `[from-feedback]` so the user can tell them apart.
</step>

<step number="2">
**Inventory user feedback THIS session.** Re-read the user's messages in the current context and extract every directive, correction, or non-obvious preference. Look for: corrections ("no, do X instead"), preferences expressed once, confirmations of non-obvious choices, and reasoning the user provided ("X depends on Y, so the order matters" — these often become `Why:` lines). Output: `SESSION_FEEDBACK` with verbatim source quotes.
</step>

<step number="3">
**Read the memory index.** Open the project's `MEMORY.md` (path is in the `auto memory` system context). List every `feedback_*.md` link, then read each. These are rules already promoted to durable memory in this or earlier sessions. Output: `MEMORY_FEEDBACK`.
</step>

<step number="4">
**Merge and dedupe.** Combine `SESSION_FEEDBACK + MEMORY_FEEDBACK`. If a session rule restates a memory rule almost word-for-word, drop the duplicate (memory wins).
</step>

<step number="5">
**Build candidate skill set.** `CANDIDATE_SKILLS = SKILLS_USED ∪ {natural-home skills for any feedback that didn't fire this session}`. Skills used this session are first-class targets; other user skills are only candidates if a feedback rule clearly maps to them.
</step>

<step number="6">
**Match feedback → skill (many-to-many).** A single rule can land in multiple skills. Heuristics:
- Test conventions → `testing`, `implement-jira-ticket`, `tdd-guide`
- Code-review judgement → `pr-review`, `code-review`
- Self-review before presenting → `pr-review`, `implement-jira-ticket`
- Workflow ordering / domain-specific facts → leave in project memory, do NOT promote to a skill

If a feedback rule has no natural skill home, leave it in memory; do NOT create a new skill from a single rule. Sort the resulting `EDITS` list by `usage_count(skill)` descending so the most-used skills get reviewed first.
</step>

<step number="7">
**Build a diff per candidate.** For each entry, read the target SKILL.md and craft a minimal Edit that adds the rule to the right section. Prefer existing `<best_practices>`, `<when_to_activate>`, or a new `<lessons_learned>` block. Format the bullet as `- <rule>. Why: <reason>. (from <source>)`.
</step>

<step number="8">
**Present ALL candidates as a numbered list, ask to confirm each.** Every (rule, skill) pair gets its own y/n prompt. Show usage count and whether the candidate is `[from-feedback]` or `[repeat-use]`. User options: `y` (apply), `n` (decline this edit), `skip-skill` (skip remaining edits for this skill), `apply all` (bulk-approve).
</step>

<step number="9">
**On approval, apply each Edit and shrink the corresponding source.** Memory-promoted feedback: shrink the `feedback_*.md` body to a stub that points at the skill (`See: ~/.claude/skills/<skill>/SKILL.md`). Session-only feedback: write a one-line memory stub that points at the now-promoted rule.
</step>

<step number="10">
**Then proceed to the strategic-compaction phase below.**
</step>

</self_improvement_pass>

<self_improvement_skip_when>
- No `feedback_*` memories exist AND the session contained no corrections worth promoting.
- All candidate rules are project-specific (e.g., domain ordering, ticket-specific facts) — leave in project memory.
- The user explicitly says "skip self-improvement" or "just compact".
</self_improvement_skip_when>

<core_principle>
Compact at PHASE BOUNDARIES, not arbitrary thresholds. The goal is fresh context for each phase while preserving the outputs of the previous phase in durable storage (files, TodoWrite, git).
</core_principle>

<when_to_activate>
- Running long sessions approaching context limits (200K+ tokens)
- Working on multi-phase tasks (research → plan → implement → test)
- Switching between unrelated tasks within the same session
- After completing a major milestone and starting new work
- When responses slow down or become less coherent (context pressure)
</when_to_activate>

<compaction_decision_guide>

| Phase Transition | Compact? | Why |
|-----------------|----------|-----|
| Research → Planning | Yes | Research context is bulky; plan is the distilled output |
| Planning → Implementation | Yes | Plan is in TodoWrite or a file; free up context for code |
| Implementation → Testing | Maybe | Keep if tests reference recent code; compact if switching focus |
| Debugging → Next feature | Yes | Debug traces pollute context for unrelated work |
| Mid-implementation | No | Losing variable names, file paths, and partial state is costly |
| After a failed approach | Yes | Clear the dead-end reasoning before trying a new approach |

</compaction_decision_guide>

<what_survives_compaction>

| Persists | Lost |
|----------|------|
| CLAUDE.md instructions | Intermediate reasoning and analysis |
| TodoWrite task list | File contents you previously read |
| Memory files (`~/.claude/memory/`) | Multi-step conversation context |
| Git state (commits, branches) | Tool call history and counts |
| Files on disk | Nuanced user preferences stated verbally |

**Rule:** Before compacting, save anything important to a durable location (file, memory, TodoWrite).
</what_survives_compaction>

<best_practices>
1. **Compact after planning** — Once plan is finalized in TodoWrite, compact to start fresh
2. **Compact after debugging** — Clear error-resolution context before continuing
3. **Don't compact mid-implementation** — Preserve context for related changes
4. **Write before compacting** — Save important context to files or memory first
5. **Use `/compact` with a summary** — Add a custom message: `/compact Focus on implementing auth middleware next`
6. **Read the suggestion** — The optional hook tells you *when*, you decide *if*
</best_practices>

<optional_hook>
An optional `suggest-compact.sh` hook can track tool call count and suggest compaction at configurable thresholds. See `skills/strategic-compact/suggest-compact.sh` for the script.

Add to `~/.claude/settings.json` (OPT-IN):
```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{
        "type": "command",
        "command": "~/.claude/skills/strategic-compact/suggest-compact.sh"
      }]
    }]
  }
}
```

Configuration:
- `COMPACT_THRESHOLD` env var — Tool calls before first suggestion (default: 50)
- Reminders every 25 calls after threshold
</optional_hook>

<success_criteria>
- [ ] Self-improvement pass ran first (or was explicitly skipped per `<self_improvement_skip_when>`)
- [ ] Both `ALL_SKILLS` and `SKILLS_USED` enumerated; repeat-use skills (3+ invocations) flagged
- [ ] Recurring `feedback_*` memories evaluated for promotion to a user skill
- [ ] Each proposed skill edit shown as a diff and confirmed per-candidate before applying
- [ ] Promoted feedback memories shrunk or stubbed after graduating into a skill
- [ ] Compaction happens at a logical phase boundary (not mid-task)
- [ ] Important context saved to durable storage before compacting
- [ ] Fresh context available for the next phase
- [ ] No critical information lost that wasn't captured in files/TodoWrite
</success_criteria>
