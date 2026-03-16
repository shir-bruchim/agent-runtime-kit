---
description: Toggle concise response mode (on/off/status)
argument-hint: "[on|off|status]"
---

Toggle concise response mode. When enabled, responses are brief (1-3 sentences, no code blocks unless essential).

## Usage

- `/concise on` — Enable concise mode
- `/concise off` — Disable concise mode
- `/concise` or `/concise status` — Show current state

## Implementation

Run the toggle script:

```bash
~/.claude/hooks/concise-toggle.sh $ARGUMENTS
```

State is stored in `~/.claude/.concise-mode`. The `concise-mode.sh` UserPromptSubmit hook reads this state file to inject style instructions.
