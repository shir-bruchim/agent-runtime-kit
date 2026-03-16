# Setup Safety Hooks

Install and configure operational safety hooks to block dangerous commands, protect sensitive files, and prevent accidental damage.

## Available Hooks

**block-dangerous-commands.sh** — Primary hook. Blocks rm -rf /, dd to disks, fork bombs, mkfs, and git force pushes. Exits 2 (hard stop).

**block-dangerous-bash.sh** — Compatibility alias. Delegates to block-dangerous-commands.sh; use when your hooks.json references the "bash" filename.

**protect-files.sh** — Blocks writes to ~/.ssh, ~/.gnupg, ~/.aws/credentials, and any paths in PROTECTED_PATHS or ~/.claude/protected-paths.txt. Exits 2 (hard stop).

## Installation (Claude Code)

Add to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{"type": "command", "command": "bash ~/.claude/hooks/block-dangerous-commands.sh"}]
      },
      {
        "matcher": "Write|Edit",
        "hooks": [{"type": "command", "command": "bash ~/.claude/hooks/protect-files.sh"}]
      }
    ]
  }
}
```

Copy hook files:

```bash
cp hooks/block-dangerous-commands.sh hooks/block-dangerous-bash.sh hooks/protect-files.sh ~/.claude/hooks/ && chmod +x ~/.claude/hooks/*.sh
```

## Non-Hook Platforms

**Cursor / GitHub Copilot / Gemini** — no native hook system.

Instead, add a "never do" list to the project's `AGENTS.md` (or `GEMINI.md`) and to the AI's always-on rules:

```
NEVER run: rm -rf /, git push --force, dd to /dev/sd*, mkfs, fork bombs.
NEVER write to: ~/.ssh/, ~/.gnupg/, ~/.aws/credentials, .env files with real secrets.
```

The safety is enforced by instruction, not by a hard block. For high-risk environments, prefer Claude Code with hooks.

## Success Criteria

- [ ] Hooks installed in ~/.claude/hooks/
- [ ] settings.json updated with PreToolUse entries
- [ ] Tested with a blocked command to verify hooks work
- [ ] Key paths (SSH, GPG, AWS credentials) protected
