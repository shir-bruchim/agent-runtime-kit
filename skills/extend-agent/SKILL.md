---
name: extend-agent
description: Create new skills, commands, hooks, or subagents for your AI agent. Use when you need to add new capabilities to Claude Code or Cursor — any type of extension.
---

<essential_principles>

## Types of Agent Extensions

| Type | Claude Code | Cursor | Gemini CLI | Copilot | Purpose |
|------|-------------|--------|------------|---------|---------|
| **Skill** | `skills/<name>/SKILL.md` | `.cursor/rules/<name>.mdc` | N/A (use GEMINI.md) | N/A (use instructions) | Domain knowledge + workflows |
| **Command** | `commands/<name>.md` | `.cursor/rules/<name>.mdc` | `.gemini/commands/<name>.toml` | N/A | Quick action shortcuts |
| **Hook** | `settings.json` hooks | `alwaysApply: true` rules | `settings.json` hooks | N/A | Event-driven automation |
| **Subagent** | `agents/<name>.md` | `.cursor/agents/<name>.md` | N/A (use MCP/extensions) | N/A | Specialist AI instances |
| **Rule** | `.claude/rules/<name>.md` | `.cursor/rules/<name>.mdc` | `GEMINI.md` sections | `.github/instructions/*.instructions.md` | Coding conventions |

### Skill Frontmatter — All Fields (Claude Code)

```yaml
---
name: skill-name                    # Required: unique identifier
description: What and when to use   # Required: Claude reads this to decide invocation
disable-model-invocation: true      # Optional: only user can invoke via /name (zero context cost)
user-invocable: false               # Optional: hides from / menu, Claude auto-invokes only
context: fork                       # Optional: runs in isolated subagent context
agent: general-purpose              # Optional: which agent type for forked context
allowed-tools: Read, Grep, Glob     # Optional: restrict available tools
---
```

**Context cost rules:**
- `disable-model-invocation: true` → description NOT in context (zero cost, user-only)
- `user-invocable: false` → description IN context (Claude auto-invokes)
- Default → description IN context + appears in / menu

### Skill Frontmatter — Cursor (.mdc)

```yaml
---
description: What it does and when it applies
globs: ["**/*.py"]      # File patterns (empty = on-demand)
alwaysApply: false       # true = always in context
---
```

### Skill Frontmatter — Copilot (.instructions.md)

```yaml
---
applyTo: "**/*.py,**/*.ts"          # Glob patterns for file scope
excludeAgent: "code-review"         # Optional: exclude from specific agent
---
```

### Subagent Frontmatter — All Fields (Claude Code)

```yaml
---
name: agent-name                    # Required
description: When to use            # Required
tools: Read, Grep, Glob, Bash      # Optional: restrict tool access
model: sonnet                       # Optional: sonnet/opus/haiku
memory: user                        # Optional: persistent cross-session learning
skills:                             # Optional: preload skills at startup
  - testing
  - security
maxTurns: 10                        # Optional: limit agent turns
isolation: worktree                 # Optional: isolated git worktree
---
```

### Command Frontmatter — Gemini CLI (.toml)

```toml
description = "What this command does"
prompt = "The prompt to send when invoked"
```

### Rule Path-Scoping (Cross-Platform)

| Platform | Field | Format |
|----------|-------|--------|
| Claude Code | `paths:` | `["**/test_*", "**/*.spec.*"]` |
| Cursor | `globs:` | `["**/test_*", "**/*.spec.*"]` |
| Copilot | `applyTo:` | `"**/test_*,**/*.spec.*"` |
| Gemini CLI | N/A | Context files loaded by directory hierarchy |

</essential_principles>

<intake>
What would you like to create?

1. **Skill** — Domain expertise module (SKILL.md for Claude / .mdc for Cursor)
2. **Command** — Quick action shortcut
3. **Hook** — Event-driven automation
4. **Subagent** — Specialist AI instance

**Wait for response before proceeding.**
</intake>

<routing>
| Choice | Instructions |
|--------|-------------|
| 1, "skill", "rule", "mdc" | Read `workflows/create-simple-skill.md` |
| 2, "command", "slash" | See `<create_command>` below |
| 3, "hook", "automation" | See `<create_hook>` below |
| 4, "subagent", "agent" | Read `workflows/create-subagent.md` |
</routing>

<create_command>

### Creating a Command

**Claude Code** (`.claude/commands/<name>.md`):
```yaml
---
description: What this command does (appears in /help)
argument-hint: [optional-arg]
allowed-tools: Bash(git add:*), Bash(git commit:*)  # Optional
---

<objective>
What to accomplish. Use $ARGUMENTS if taking user input.
</objective>

<context>
Current status: !`git status`
Relevant file: @package.json
</context>

<process>
1. Step one
2. Step two
3. Verify
</process>

<success_criteria>
Definition of done.
</success_criteria>
```
Install: `cp command.md ~/.claude/commands/`
Invoke: `/command-name [args]`

**Cursor** (`.cursor/rules/<name>.mdc` with `alwaysApply: false`):
```yaml
---
description: When asked to [action], follow this workflow
globs: []
alwaysApply: false
---

<process>
1. Step one
2. Step two
</process>
```
Key difference: Cursor has no `/` invocation — the rule activates when the user describes the action.

**Arguments:**
- `$ARGUMENTS` — all args as one string: `/fix-issue 123` → `$ARGUMENTS = "123"`
- `$1`, `$2`, `$3` — positional: `/review-pr 456 high` → `$1=456`, `$2=high`
- No args — operates on current context (git status, open file, etc.)

</create_command>

<create_hook>

### Creating a Hook (Claude Code)

Hooks are event-driven automation in `.claude/hooks.json`.

**Hook events:**
| Event | When | Blocking? |
|-------|------|-----------|
| `PreToolUse` | Before tool runs | Yes |
| `PostToolUse` | After tool runs | No |
| `UserPromptSubmit` | User submits prompt | Yes |
| `Stop` | Agent tries to stop | Yes |
| `SubagentStop` | Subagent tries to stop | Yes |
| `SessionStart` | Session begins | No |
| `SessionEnd` | Session ends | No |
| `PreCompact` | Before context compaction | Yes |
| `Notification` | Claude needs input | No |

**Command hook template:**
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/my-hook.sh",
            "timeout": 10000
          }
        ]
      }
    ]
  }
}
```

**Blocking hook output** (stdout from your script):
```json
{"decision": "block", "reason": "Why this was blocked"}
```

**Prompt hook template** (LLM evaluates instead of a script):
```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{"type": "prompt", "prompt": "Is this command safe: $ARGUMENTS\nReturn JSON: {\"decision\": \"approve\" or \"block\", \"reason\": \"...\"}"}]
    }]
  }
}
```
Use `prompt` type when decision requires reasoning; `command` type for deterministic checks.
Test hooks with: `claude --debug`

**Matchers:**
```
"Bash"           → Exact tool name
"Write|Edit"     → Multiple tools (regex OR)
"mcp__.*"        → All MCP tools
(omit matcher)   → Fires for all tools
```

**Cursor equivalent:** No native hook system. Use `alwaysApply: true` rules:
```yaml
---
alwaysApply: true
---

NEVER run: rm -rf, git push --force, DROP TABLE.
ALWAYS check git status before committing.
```

See `skills/security/hooks/` for working hook script examples.

</create_hook>

<create_skill_and_subagent_notes>

**Skill design patterns:**
- Simple (4-10 lines of instructions) → single `SKILL.md` file
- Complex (multi-step workflows, multiple domains) → router pattern with `workflows/`, `references/`, `templates/` subdirs
- Keep SKILL.md under 500 lines — move detailed content to `references/` subdirectory
- Description is critical — Claude uses it to decide when to invoke. Be specific about triggers.
- Use progressive disclosure: lean SKILL.md routes to detailed workflow/reference files

**Subagent execution model — critical constraints:**
- Subagents **cannot** use `AskUserQuestion` or wait for user input
- Run isolated — user sees only final output, not intermediate steps
- Invoked automatically (Claude matches `description` field) or explicitly via the Task tool
- Project subagents (`.claude/agents/`) override user subagents (`~/.claude/agents/`) on name conflict
- `memory: user` enables persistent learning at `~/.claude/agent-memory/<name>/`
- `skills:` preloading injects full skill content at startup (no need for inline "read SKILL.md")
- For multi-stage orchestration: use the planning skill + Task tool, not a single subagent

**When to use subagents proactively:**

| Situation | Agent | Why |
|-----------|-------|-----|
| Complex feature | planner | Break down before building |
| Code just written | reviewer | Catch issues immediately |
| New feature or bug fix | tester | Tests alongside code |
| Architecture decision | architect | Design before implementation |
| Security-sensitive code | security | Audit before commit |
| Database work | db-expert | Schema and query optimization |

Always launch independent agents in parallel when possible.

</create_skill_and_subagent_notes>

<reference_index>
- `references/skill-structure.md` — Complete skill patterns and XML tags
- `references/cursor-format.md` — Cursor .mdc format in depth
- `references/core-principles.md` — Prompting principles for all extension types
</reference_index>

<workflows_index>
| Workflow | Purpose |
|----------|---------|
| `workflows/create-simple-skill.md` | Build a single-file skill or a complex router skill with subdirectories |
| `workflows/convert-to-cursor.md` | Transform a SKILL.md to Cursor .mdc format |
| `workflows/create-subagent.md` | Build a specialist agent for Claude Code or Cursor |
</workflows_index>

<scanner_skill_pattern>
When designing a skill that scans across many targets (skills, files, PRs, test failures, comments, ...) and proposes per-target actions, the skill body MUST:

1. Enumerate ALL candidates first — never short-circuit on the first match.
2. Sort the candidates by a clear priority signal (usage count, severity, recency).
3. Present each as a numbered list `[i/N]` with rationale and proposed action.
4. Ask for per-candidate confirmation, with `skip-skill` / `apply all` shortcuts for batch decisions.

Anti-pattern: returning one match with "I found this" — the user can't see what you skipped, can't redirect priority, and trusts a partial scan as complete.

Repeat-use as a smell: if the user invokes the same skill 3+ times within one session/task, the skill body is probably under-specified. Make sure new scanner skills produce a complete pass per invocation; one call should fully discharge the user's intent.
</scanner_skill_pattern>

<success_criteria>
- Valid YAML frontmatter for the target platform
- XML-structured body (no markdown headings in body)
- Description specific enough to trigger at the right time
- Installed in the correct location for the platform
- Tested with a representative user request
- For scanner-type skills: produces a complete enumerated, prioritized list per invocation (no short-circuit, no repeat-use needed)
</success_criteria>
