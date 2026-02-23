# Cursor .mdc Format Reference

## File Location

```
.cursor/rules/<rule-name>.mdc      # Project-specific
~/.cursor/rules/<rule-name>.mdc    # Global (all projects)
```

## Frontmatter Fields

```yaml
---
description: What this rule does and when to apply it   # Required
globs: ["**/*.py", "src/**/*.ts"]   # File patterns that trigger this rule
alwaysApply: false                   # true = always in context, false = on-demand
---
```

## Three Rule Types

**Always-On Rules** (coding standards, project conventions):
```yaml
---
description: Project coding conventions and style guide
globs: ["**/*"]
alwaysApply: true
---

Always follow these conventions in this project:
- Use TypeScript strict mode
- Prefer functional components
- All API calls go through the service layer
```

**File-Triggered Rules** (language/domain specific):
```yaml
---
description: Python best practices and type annotation guidelines
globs: ["**/*.py"]
alwaysApply: false
---

When working with Python files:
- Use type hints on all function signatures
- Prefer dataclasses for data structures
- Use pathlib instead of os.path
```

**On-Demand Rules** (invoked manually or by agent):
```yaml
---
description: Security review checklist for code changes
globs: []
alwaysApply: false
---

When asked to perform a security review...
```

## Converting a SKILL.md to Cursor Format

**Source (SKILL.md):**
```yaml
---
name: python-conventions
description: Python development patterns and style. Use when writing or reviewing Python code.
---

<objective>...</objective>
<process>...</process>
```

**Target (.mdc):**
```yaml
---
description: Python development patterns and style. Apply when writing or reviewing Python code.
globs: ["**/*.py"]
alwaysApply: false
---

<objective>...</objective>
<process>...</process>
```

Changes made:
- Remove `name:` field
- Add `globs:` matching relevant file patterns
- Add `alwaysApply:` (false for on-demand, true for always-on)
- Keep all content body identical

## Cursor vs Claude Code Differences

| Aspect | Claude Code | Cursor |
|--------|-------------|--------|
| File extension | `.md` | `.mdc` |
| Name field | Required | Not used |
| Trigger | Description matching | `globs` + `alwaysApply` |
| Location | `.claude/skills/` | `.cursor/rules/` |
| Subdirectories | Supported (router pattern) | Not natively supported |
| Loading | On-demand by description | By file pattern or always |
| Commands | `.claude/commands/*.md` | No direct equivalent |
| Agents | `.claude/agents/*.md` | Via rules or MCP |
