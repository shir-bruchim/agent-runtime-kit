# Compaction decision

After `workflows/self-improvement-pass.md` and `workflows/apply-edits.md` complete, decide whether to recommend `/compact` and at what phase boundary.

## Core principle

Compact at PHASE BOUNDARIES, not arbitrary thresholds. The goal is fresh context for each phase while preserving the outputs of the previous phase in durable storage (files, TodoWrite, git).

## When to activate

- Running long sessions approaching context limits (200K+ tokens).
- Working on multi-phase tasks (research → plan → implement → test).
- Switching between unrelated tasks within the same session.
- After completing a major milestone and starting new work.
- When responses slow down or become less coherent (context pressure).

## Decision table

| Phase Transition | Compact? | Why |
|-----------------|----------|-----|
| Research → Planning | Yes | Research context is bulky; plan is the distilled output |
| Planning → Implementation | Yes | Plan is in TodoWrite or a file; free up context for code |
| Implementation → Testing | Maybe | Keep if tests reference recent code; compact if switching focus |
| Debugging → Next feature | Yes | Debug traces pollute context for unrelated work |
| Mid-implementation | No | Losing variable names, file paths, and partial state is costly |
| After a failed approach | Yes | Clear the dead-end reasoning before trying a new approach |

## What survives compaction

| Persists | Lost |
|----------|------|
| CLAUDE.md instructions | Intermediate reasoning and analysis |
| TodoWrite task list | File contents you previously read |
| Memory files (`~/.claude/memory/`) | Multi-step conversation context |
| Git state (commits, branches) | Tool call history and counts |
| Files on disk | Nuanced user preferences stated verbally |

**Rule:** Before compacting, save anything important to a durable location (file, memory, TodoWrite).

## Best practices

1. **Compact after planning** — Once plan is finalized in TodoWrite, compact to start fresh.
2. **Compact after debugging** — Clear error-resolution context before continuing.
3. **Don't compact mid-implementation** — Preserve context for related changes.
4. **Write before compacting** — Save important context to files or memory first.
5. **Use `/compact` with a summary** — Add a custom message: `/compact Focus on implementing auth middleware next`.
6. **Read the suggestion** — The optional hook tells you *when*, you decide *if*.

## Optional `suggest-compact.sh` hook

`~/.claude/skills/strategic-compact/suggest-compact.sh` tracks tool call count and suggests compaction at configurable thresholds.

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
- `COMPACT_THRESHOLD` env var — Tool calls before first suggestion (default: 50).
- Reminders every 25 calls after threshold.

## Output

Present a compaction recommendation as the FINAL step of the run:

```
Recommended phase boundary: <transition name>
Reason: <one-line>
Suggested /compact summary:
  /compact <text the user can paste as-is>

Critical context to save first:
- [ ] <item> → <durable-location>
```

The user decides whether to compact.