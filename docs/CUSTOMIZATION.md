# Customization Guide

This guide explains how to extend the kit, add your own skills, and override defaults.

---

## Adding a New Skill

Skills live in `skills/<name>/SKILL.md`. Use the `create-ai-skills` meta-skill to generate one:

> "Use the create-ai-skills skill to create a new skill for [topic]"

Or create one manually:

```
skills/
└── my-skill/
    ├── SKILL.md              # Required: main skill file
    ├── references/           # Optional: detailed reference docs
    ├── templates/            # Optional: reusable templates
    └── workflows/            # Optional: step-by-step workflows
```

**SKILL.md frontmatter:**
```yaml
---
name: my-skill
description: What this skill does and when to use it
---
```

**Body structure (XML tags):**
```xml
<objective>
What this skill accomplishes and why it matters.
</objective>

<process>
1. Step one
2. Step two
3. Step three
</process>

<success_criteria>
- Measurable outcome 1
- Measurable outcome 2
</success_criteria>
```

---

## Adding a New Subagent (Claude Code)

Subagents live in `subagents/<name>.md` or `.claude/agents/<name>.md`:

```yaml
---
name: my-agent
description: What this agent does and when to invoke it
tools: Read, Grep, Glob, Bash
model: sonnet
---

<role>
You are a specialist in [domain].
</role>

<constraints>
- NEVER do X
- ALWAYS do Y
</constraints>

<workflow>
1. Step one
2. Step two
</workflow>

<output_format>
Describe the expected output format.
</output_format>
```

**Model selection:**
- `opus` — complex reasoning, architecture decisions, planning
- `sonnet` — general coding, review, generation (default)
- `haiku` — simple, fast tasks (git ops, formatting)

---

## Adding a New Command

Commands live in `commands/<name>.md` or `.claude/commands/<name>.md`:

```yaml
---
description: What this command does
argument-hint: [optional-arg]
---

<objective>
What the command accomplishes.
</objective>

<process>
1. Step one
2. Step two
</process>

<success_criteria>
- Done when X
</success_criteria>
```

Invoke with `/name` or `/name argument`.

---

## Overriding Language Conventions

To customize conventions for your project, edit the installed rule files directly:

```bash
# Edit the installed Python conventions
nano .claude/rules/python-conventions.md
```

Or create a project-specific override file that takes precedence:

```bash
# .claude/rules/project-conventions.md
# Add project-specific overrides here
```

---

## Adding a Hook

Edit `.claude/hooks.json` to add automation triggers.

**Block a specific command pattern:**
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Check if this command is safe: $ARGUMENTS\n\nReturn: {\"decision\": \"approve\" or \"block\", \"reason\": \"explanation\"}"
          }
        ]
      }
    ]
  }
}
```

**Run a formatter after file edits:**
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "prettier --write $CLAUDE_PROJECT_DIR",
            "timeout": 10000
          }
        ]
      }
    ]
  }
}
```

See `skills/create-automation-hooks/SKILL.md` for the complete hooks reference.

---

## Cursor-Specific Customization

For Cursor, all customization happens in `.cursor/rules/`:

**Create a new always-on rule:**
```markdown
---
description: My custom project conventions
alwaysApply: true
---

Always use tabs for indentation in this project.
Never use console.log in production code.
```

**Create a file-triggered rule:**
```markdown
---
description: Database model conventions
globs: **/models/*.py
alwaysApply: false
---

All models must inherit from Base.
Use Mapped[type] annotations for all columns.
```

---

## Selective Installation

You don't have to install everything. Pick what's relevant:

**Just git conventions:**
```bash
cp rules/git-workflow.md .claude/rules/
cp commands/commit.md ~/.claude/commands/
cp commands/push.md ~/.claude/commands/
cp commands/pr.md ~/.claude/commands/
```

**Just the planning system:**
```bash
cp -r skills/planning ~/.claude/skills/
cp subagents/planner.md ~/.claude/agents/
```

**Just security:**
```bash
cp -r skills/security ~/.claude/skills/
cp subagents/security.md ~/.claude/agents/
cp skills/security/hooks/*.sh .claude/hooks/
chmod +x .claude/hooks/*.sh
```
