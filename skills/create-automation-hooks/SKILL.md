---
name: create-automation-hooks
description: Expert guidance for creating event-driven automation hooks. Primarily for Claude Code's hook system (PreToolUse, PostToolUse, SessionStart, etc.) with notes on Cursor automation alternatives. Use when setting up safety checks, automating workflows, injecting context, or understanding hook types.
---

<objective>
Hooks are event-driven automation that execute shell commands or prompts in response to agent tool usage and session events. They provide programmatic control over AI behavior without modifying core code, enabling safety checks, workflow automation, and context injection.

**Platform support:**
- **Claude Code** — Full hook system with JSON configuration
- **Cursor** — No native hook system; use `alwaysApply: true` rules for always-on behavior and MCP tools for programmatic automation
</objective>

<hook_types>
## Claude Code Hook Events

| Event | When it fires | Can block? |
|-------|---------------|------------|
| **PreToolUse** | Before tool execution | Yes |
| **PostToolUse** | After tool execution | No |
| **UserPromptSubmit** | User submits a prompt | Yes |
| **Stop** | Agent attempts to stop | Yes |
| **SubagentStop** | Subagent attempts to stop | Yes |
| **SessionStart** | Session begins | No |
| **SessionEnd** | Session ends | No |
| **PreCompact** | Before context compaction | Yes |
| **Notification** | Agent needs user input | No |

Blocking hooks return `"decision": "block"` to prevent the action.
</hook_types>

<quick_start>
**Minimal hook config** (`.claude/hooks.json` in project or `~/.claude/hooks.json` globally):

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "echo 'Running bash command' >> ~/.claude/bash-log.txt"
          }
        ]
      }
    ]
  }
}
```

**Test with:** `claude --debug`
</quick_start>

<hook_anatomy>
## Hook Configuration Structure

```json
{
  "hooks": {
    "<EventType>": [
      {
        "matcher": "<tool-pattern>",    // Optional: regex matching tool name
        "hooks": [
          {
            "type": "command",          // or "prompt"
            "command": "<shell command>", // for type: command
            "timeout": 30000            // milliseconds, optional
          }
        ]
      }
    ]
  }
}
```

## Hook Types

**Command hooks** — execute shell scripts:
```json
{
  "type": "command",
  "command": "/path/to/script.sh",
  "timeout": 30000
}
```
Input: JSON via stdin. Output: JSON via stdout (optional).

**Prompt hooks** — LLM evaluates a prompt:
```json
{
  "type": "prompt",
  "prompt": "Evaluate if this is safe: $ARGUMENTS\nReturn JSON: {\"decision\": \"approve\" or \"block\", \"reason\": \"explanation\"}"
}
```
Use for complex decision logic that requires reasoning.

## Matchers

```json
"matcher": "Bash"           // Single tool
"matcher": "Write|Edit"     // Multiple tools (regex OR)
"matcher": "mcp__.*"        // All MCP tools
// No matcher = fires for all tools
```

## Output Schema (for blocking hooks)

```json
{
  "decision": "approve" | "block",
  "reason": "Human-readable explanation"
}
```
</hook_anatomy>

<common_patterns>
## Practical Hook Examples

**Block dangerous bash commands:**
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/block-dangerous-bash.sh"
          }
        ]
      }
    ]
  }
}
```

**Protect sensitive files:**
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/protect-files.sh"
          }
        ]
      }
    ]
  }
}
```

**Inject context at session start:**
```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "cat .planning/BRIEF.md 2>/dev/null | jq -Rs '{hookSpecificOutput: {additionalContext: .}}'"
          }
        ]
      }
    ]
  }
}
```

**Desktop notification when input needed:**
```json
{
  "hooks": {
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "osascript -e 'display notification \"Agent needs input\" with title \"Claude Code\"'"
          }
        ]
      }
    ]
  }
}
```

**Auto-format after file edits:**
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "cd $CLAUDE_PROJECT_DIR && prettier --write . 2>/dev/null || true",
            "timeout": 15000
          }
        ]
      }
    ]
  }
}
```
</common_patterns>

<cursor_equivalent>
## Cursor Automation Alternatives

Cursor does not have a native hook system. Alternatives:

**Always-on rules** (equivalent to SessionStart context injection):
```yaml
---
description: Project context always available
globs: ["**/*"]
alwaysApply: true
---

Project: [Name]
Stack: [Tech stack]
Key conventions: [...]
```

**Safety guardrails via rules:**
```yaml
---
description: Safety rules - never do these things
globs: ["**/*"]
alwaysApply: true
---

NEVER:
- Delete files without explicit user request
- Push directly to main/master
- Modify .env files
- Run rm -rf commands
```

**Programmatic automation via MCP:**
- Use MCP servers for complex automation that would otherwise need hooks
- MCP tools can be called before/after operations
- See `mcp/recommended-servers.json` for options
</cursor_equivalent>

<security_checklist>
## Safety Requirements

- **Infinite loop prevention**: Check `stop_hook_active` in Stop hooks
- **Timeout**: Set reasonable timeouts (default 60s) to prevent hanging
- **Permissions**: Hook scripts need executable permissions (`chmod +x`)
- **Path safety**: Use `$CLAUDE_PROJECT_DIR` for absolute paths
- **JSON validation**: Validate with `jq . .claude/hooks.json` before use
- **Conservative blocking**: Prefer `ask: true` over `block` when unsure

**Test all hooks before deploying:**
```bash
claude --debug    # Shows which hooks matched and what they returned
jq . .claude/hooks.json  # Validates JSON syntax
```
</security_checklist>

<reference_index>
All in `references/`:

- **hook-types.md** — Complete event types, schemas, and use cases
- **examples.md** — Working hook implementations for common scenarios
- **troubleshooting.md** — Debugging hooks, common failures
</reference_index>

<success_criteria>
A working hook setup:
- Valid JSON in `.claude/hooks.json` (passes `jq` validation)
- Correct hook event for use case
- Matcher targets the right tools
- Tested with `claude --debug`
- No infinite loops in Stop hooks
- Reasonable timeout set
- Executable permissions on script files
</success_criteria>
