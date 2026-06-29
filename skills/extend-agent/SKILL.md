---
name: extend-agent
description: Create new skills, commands, hooks, or subagents for your AI agent. Use when you need to add new capabilities to Claude Code or Cursor — any type of extension.
---

f<freshness_check>

**MANDATORY first step on every invocation.** Claude Code's extension knobs (skill frontmatter fields, subagent options, hook events, the model lineup, slash-command behavior) change frequently. The tables in this SKILL.md are a SNAPSHOT — they go stale. Verify the LIVE docs FIRST, then design.

### Step 1 — Fetch the current docs

Use WebFetch (preferred over delegating to `web-research` subagent, because WebFetch is often restricted in subagent contexts — the parent loop usually has it). Always go to the live URL first; if the doc has moved (HTTP 301), follow the redirect to the new canonical host.

Verified canonical hosts (as of late 2026):
1. `https://code.claude.com/docs/en/skills` — Skill frontmatter, invocation control, subagent execution, dynamic context injection
2. `https://code.claude.com/docs/en/sub-agents` — Subagent frontmatter, model defaults, invocation
3. `https://code.claude.com/docs/en/hooks` — Hook events (30+), handler types, blocking output JSON
4. `https://code.claude.com/docs/en/slash-commands` — Custom commands (note: commands are now merged into skills)
5. `https://code.claude.com/docs/en/agent-teams` and `/agent-view` — Cross-session orchestration
6. `https://code.claude.com/docs/en/context-window` — Compaction + token-cost visualization
7. `https://docs.anthropic.com/en/docs/claude-code/*` — fallback URL pattern; redirects to `code.claude.com` since the 2026 doc migration.
8. The repo's own `~/.claude/skills/extend-agent/SKILL.md` snapshot — fallback only when the live docs are unreachable.

If the WebFetch returns "redirect detected," follow the redirect URL once. If both 404, the doc has moved — search `https://www.anthropic.com/news` for the latest Claude Code post.

### Step 2 — Verify the specific knobs your new extension will use

The fields you'd use change quarterly. Always re-confirm:

- **Skill frontmatter fields** (`name`, `description`, `disable-model-invocation`, `user-invocable`, `context: fork`, `allowed-tools`, plus any new fields). Pay attention to context-cost rules (which fields load `description:` into context, which don't).
- **Subagent frontmatter** (`model`, `tools`, `memory`, `skills`, `maxTurns`, `isolation`). Default model when none is specified.
- **Model lineup.** What models can be set as `model: ...`? The lineup churns most often. Check anthropic.com/news for the latest.
- **Hook events** — verify each event you'll subscribe to is still listed; the event roster has grown to ~30. Verify payload shape for the event you use.
- **Hook handler types** — `command` / `http` / `mcp_tool` / `prompt` / `agent` (experimental) — verify the type you want exists.
- **Recommended size caps** — current docs suggest SKILL.md `description:` ≤200 chars; progressive disclosure to `references/` for detail.

### Step 3 — Surface what's NEW since the local snapshot

After verifying knobs the new extension needs, do a second pass: scan the live doc for capabilities NOT YET reflected in this SKILL.md, related skills, or the user's `~/.claude/agents/` / `~/.claude/skills/` configs. Report any "new since snapshot" features as recommendations the user might want to adopt — even if not directly relevant to the current extension. Examples to look for each run:

- New hook events (the `PostToolBatch`, `TaskCreated`, `PostCompact` series didn't exist in the snapshot).
- New handler types (`prompt`, `agent` hook types — verify which experimental flags are needed).
- New invocation modes (subagent skills, dynamic context injection, agent teams, background agents).
- New frontmatter fields (e.g., `metadata.allowed-tools` arrived in the AgentSkills standard).
- Model-lineup changes (a new haiku tier, opus pricing changes).
- Doc reorganization (URL migrations, merged docs).

For each gap, report: feature name, doc URL, one-line value-prop, and whether it's worth adopting now or filing as a follow-up. The user decides. The skill author surfaces.

### Step 4 — If a live doc contradicts this SKILL.md, fix the SKILL.md AFTER the user's request lands

Treat the live doc as authoritative. The snapshot is hand-off context, not source of truth. Open a follow-up note (memory or a comment in the SKILL.md) so the next `/strategic-compact` run catches the drift.

### Token budget for the freshness check

3-4 WebFetch calls (~10-30k tokens depending on doc size — they're large pages). It pays for itself by preventing a session-long detour fixing a wrong field name or recommending a removed feature.

</freshness_check>

<essential_principles>

- **Skill bodies must be project-agnostic.** A skill body loads into every future session regardless of repo. Before writing a new bullet, ask "would this make sense in a Go service / Rust CLI / TypeScript Next.js app?" If no, rewrite. No service names, file paths, ticket prefixes, or framework class names in the rule body — those belong in the "Why:" line or in a clearly-marked example block. See `~/.claude/skills/strategic-compact/references/promotion-quality-gates.md` §Gate 1 for the full 5-criterion checklist.

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
- `skills:` preloading injects full skill content at startup (no need for inline "read skills/X/SKILL.md")
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
