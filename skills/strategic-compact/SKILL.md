---
name: strategic-compact
description: Suggests manual context compaction at logical intervals to preserve context through task phases rather than arbitrary auto-compaction. Use when context is getting large, working on a long multi-phase task, or asking about context management strategies.
---

<objective>
Guide strategic use of `/compact` at logical task boundaries instead of relying on arbitrary auto-compaction. Auto-compaction fires at unpredictable points — often mid-task — losing important context. Strategic compaction preserves what matters by compacting between phases.
</objective>

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
- [ ] Compaction happens at a logical phase boundary (not mid-task)
- [ ] Important context saved to durable storage before compacting
- [ ] Fresh context available for the next phase
- [ ] No critical information lost that wasn't captured in files/TodoWrite
</success_criteria>
