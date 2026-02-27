# Troubleshooting

Common issues and their fixes across Claude Code and Cursor.

---

## Skills Not Loading

### Claude Code
```bash
# Check skill exists
ls ~/.claude/skills/<skill-name>/SKILL.md

# Skills must have this structure:
~/.claude/skills/
└── skill-name/
    └── SKILL.md        ← required
```

**Common issues:**
- Directory missing the inner `SKILL.md` file
- Skill installed to wrong path (`.claude/` instead of `~/.claude/` for global)
- Frontmatter YAML syntax error — validate with: `python3 -c "import yaml; yaml.safe_load(open('SKILL.md').read().split('---')[1])"`

### Cursor
```bash
# Check rule file exists
ls .cursor/rules/<skill-name>.mdc

# Validate frontmatter is correct YAML
head -10 .cursor/rules/skill-name.mdc
```

**Common issues:**
- File extension is `.md` instead of `.mdc`
- `alwaysApply` value is a string (`"false"`) instead of boolean (`false`)
- `globs` patterns don't match any open file → rule won't trigger

---

## Commands Not Working

### Claude Code
```bash
# Commands must be in correct location
ls ~/.claude/commands/          # user-level
ls .claude/commands/            # project-level

# Verify frontmatter has description field
head -5 ~/.claude/commands/ship.md
```

**Common issues:**
- Missing `description:` in frontmatter (required for `/help` to show it)
- File is `.txt` or `.yaml` instead of `.md`
- Bash commands use space between `!` and backtick (must be `!` immediately followed by `` ` ``)

### Cursor
Cursor does not have native slash commands. Use `.cursor/rules/` with `alwaysApply: false` as workflow instructions instead.

---

## Subagents Failing

### Claude Code
```bash
# Check agent files
ls ~/.claude/agents/

# Validate frontmatter
head -10 ~/.claude/agents/reviewer.md
```

**Common issues:**
- Agent uses `AskUserQuestion` — subagents cannot interact with users
- `tools:` list contains a tool that doesn't exist
- `model:` value is not `sonnet`, `opus`, `haiku`, or `inherit`

### Cursor
```bash
# Cursor reads from .claude/agents/ OR .cursor/agents/
ls .cursor/agents/
ls .claude/agents/
```

**Common issues:**
- Invoke with `/agent-name` (not automatic in all contexts)
- `readonly: true` prevents writes — remove if agent needs to create files
- `tools:` field is ignored by Cursor — use `readonly: true`/`is_background: true` instead

---

## Hooks Not Firing

### Claude Code
```bash
# Validate JSON syntax
jq . .claude/hooks.json

# Test with debug mode
claude --debug
```

**Common issues:**
- JSON syntax error (use `jq` to validate before saving)
- Script doesn't have executable permissions: `chmod +x .claude/hooks/*.sh`
- Hook path uses relative path instead of `$CLAUDE_PROJECT_DIR`
- Matcher pattern doesn't match the tool name (case-sensitive)
- Script exits with non-zero but doesn't output JSON → hook fails silently

**Debugging hooks:**
```bash
# Manual test of hook script
echo '{"tool_input":{"command":"rm -rf /"}}' | bash .claude/hooks/block-dangerous-bash.sh
echo "Exit code: $?"
```

---

## Planning System Issues

**`.planning/` directory not found:**
```bash
# Create it
mkdir -p .planning/phases
```

**Plans getting too long:**
- Maximum 2-3 tasks per PLAN.md
- Start new plans at 40-50% context usage (not 80%)
- Move completed tasks to SUMMARY.md

---

## MCP Server Issues

```bash
# List connected MCP servers (Claude Code)
claude mcp list

# Test a server standalone (example: postgres)
npx -y @modelcontextprotocol/server-postgres postgresql://... --help
```

> **Note:** Do NOT use `@modelcontextprotocol/server-github`. That npm package was deprecated in April 2025. Use the Docker or remote SSE option instead — see `mcp/SETUP.md`.

**Server not showing up:**
- Restart Claude Code after editing `~/.claude.json`
- Check environment variable names (case-sensitive)
- Verify `npx` can reach npm registry: `npm ping`

**Authentication failures:**
- GitHub: token needs `repo` scope minimum
- Postgres: check connection string format
- Atlassian: API token (not password) required

---

## Git Workflow Issues

**Commit blocked by hooks:**
```bash
# See what the hook returned
claude --debug

# Temporarily disable hook for a specific operation (use with caution)
# Edit .claude/hooks.json to remove the blocking entry, commit, then restore
```

**Force push blocked:**
The `block-dangerous-bash.sh` hook blocks `git push --force` and direct pushes to `main`. This is intentional. Use `--force-with-lease` for safer force pushes, or get explicit user approval first.

---

## Performance Issues

**Slow skill loading:**
- Move large reference docs out of SKILL.md into `references/` subdirectory
- SKILL.md should be under 500 lines

**Context filling up:**
- Don't load all skills at once — load only what's needed for the current task
- Write a SUMMARY.md and start a fresh session
- Use subagents to isolate context-heavy research

---

## Getting More Help

1. Check `docs/CUSTOMIZATION.md` for extension patterns
2. Check `docs/BEST-PRACTICES.md` for design principles
3. Run `claude --debug` for Claude Code to see hook and skill loading details
4. For Cursor: Check the Output panel (View → Output → Cursor) for error messages
