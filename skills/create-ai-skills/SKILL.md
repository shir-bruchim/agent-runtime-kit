---
name: create-ai-skills
description: Expert guidance for creating AI skills and rules that work across Claude Code and Cursor. Use when creating SKILL.md files, Cursor .mdc rules, authoring new skills, improving existing ones, or understanding skill structure and best practices for any AI agent.
---

<essential_principles>

## What AI Skills Are

Skills are modular, filesystem-based capabilities that provide domain expertise on demand. This skill teaches how to create effective skills for any AI coding agent.

### 1. Skills Are Prompts

All prompting best practices apply. Be clear, be direct, use XML structure. Assume the AI is smart — only add context it doesn't already have.

### 2. Platform File Formats

**Claude Code** — skills live in `.claude/skills/<skill-name>/SKILL.md`
```yaml
---
name: skill-name
description: What it does and when to use it.
---
```

**Cursor** — rules live in `.cursor/rules/<rule-name>.mdc`
```yaml
---
description: What this rule does and when it applies
globs: ["**/*.py"]      # File patterns that trigger this rule
alwaysApply: false      # true = always injected, false = on-demand
---
```

**Universal frontmatter** (works as-is for Claude; adapt globs/alwaysApply for Cursor):
```yaml
---
name: skill-name
description: What it does, when to use it, and what files/contexts it applies to.
---
```

### 3. Router Pattern for Complex Skills

```
skill-name/
├── SKILL.md              # Router + essential principles (always loaded)
├── workflows/            # Step-by-step procedures (FOLLOW)
├── references/           # Domain knowledge (READ)
├── templates/            # Output structures (COPY + FILL)
└── scripts/              # Reusable code (EXECUTE)
```

SKILL.md asks "what do you want to do?" → routes to workflow → workflow specifies which references to read.

**When to use each folder:**
- **workflows/** — Multi-step procedures the agent follows
- **references/** — Domain knowledge the agent reads for context
- **templates/** — Consistent output structures to copy and fill
- **scripts/** — Executable code the agent runs as-is

### 4. Pure XML Structure

No markdown headings (#, ##, ###) in skill body. Use semantic XML tags:
```xml
<objective>...</objective>
<process>...</process>
<success_criteria>...</success_criteria>
```

Keep markdown formatting *within* content (bold, lists, code blocks).

### 5. Progressive Disclosure

SKILL.md under 500 lines. Split detailed content into reference files. Load only what's needed for the current workflow.

### 6. Platform Transformation Rules

When installing to Cursor, transform skills:
- Rename `SKILL.md` → `skill-name.mdc`
- Add `globs: ["**/*"]` for general skills
- Add `alwaysApply: false` (or `true` for always-on rules)
- Remove `name:` field (not used by Cursor)
- Keep all content body as-is
</essential_principles>

<intake>
What would you like to do?

1. Create new skill
2. Audit/modify existing skill
3. Add component (workflow/reference/template/script)
4. Get guidance on structure
5. Convert a skill for Cursor format

**Wait for response before proceeding.**
</intake>

<routing>
| Response | Next Action | Workflow |
|----------|-------------|----------|
| 1, "create", "new", "build" | Ask: "Simple skill or complex router?" | Route to appropriate create workflow |
| 2, "audit", "modify", "existing" | Ask: "Path to skill?" | `workflows/audit-skill.md` |
| 3, "add", "component" | Ask: "Add what? (workflow/reference/template/script)" | `workflows/add-component.md` |
| 4, "guidance", "help" | General guidance | `workflows/get-guidance.md` |
| 5, "convert", "cursor", "mdc" | Transform to Cursor format | `workflows/convert-to-cursor.md` |

**Progressive disclosure for option 1:**
- "Simple skill" → `workflows/create-simple-skill.md`
- "Complex router" → `workflows/create-router-skill.md`

**After reading the workflow, follow it exactly.**
</routing>

<quick_reference>
## Skill Structure Quick Reference

**Simple skill (single file):**
```yaml
---
name: skill-name
description: What it does and when to use it.
---

<objective>What this skill does</objective>
<quick_start>Immediate actionable guidance</quick_start>
<process>Step-by-step procedure</process>
<success_criteria>How to know it worked</success_criteria>
```

**Complex skill (router pattern):**
```
SKILL.md:
  <essential_principles> - Always applies
  <intake> - Question to ask
  <routing> - Maps answers to workflows

workflows/:  Step-by-step procedures
references/: Domain knowledge files
templates/:  Output structures to copy and fill
scripts/:    Executable code to run as-is
```

**Cursor equivalent (.mdc):**
```yaml
---
description: What it does and when it applies
globs: ["**/*.py", "src/**/*.ts"]
alwaysApply: false
---

Same content body works in both formats.
```
</quick_reference>

<platform_notes>
## Installing Skills by Platform

**Claude Code:**
```
~/.claude/skills/<skill-name>/SKILL.md         (global, all projects)
.claude/skills/<skill-name>/SKILL.md           (project-specific)
```

**Cursor:**
```
~/.cursor/rules/<skill-name>.mdc               (global, all projects)
.cursor/rules/<skill-name>.mdc                 (project-specific)
```

**Key difference:** Claude loads skills on-demand when matched by description. Cursor loads `.mdc` files based on `globs` (file patterns) or `alwaysApply: true`.
</platform_notes>

<reference_index>
All in `references/`:

**Structure:** skill-structure.md, recommended-structure.md
**Principles:** core-principles.md, use-xml-tags.md
**Patterns:** common-patterns.md
**Platform:** cursor-format.md (Cursor .mdc specifics)
</reference_index>

<workflows_index>
All in `workflows/`:

| Workflow | Purpose |
|----------|---------|
| create-simple-skill.md | Build a single-file skill from scratch |
| create-router-skill.md | Build a complex router skill with subdirs |
| audit-skill.md | Analyze skill against best practices |
| add-component.md | Add workflow/reference/template/script to skill |
| convert-to-cursor.md | Transform a skill to Cursor .mdc format |
| get-guidance.md | Help decide what kind of skill to build |
</workflows_index>

<yaml_requirements>
## YAML Frontmatter

**Claude Code (required):**
```yaml
---
name: skill-name          # lowercase-with-hyphens, matches directory
description: ...          # What it does AND when to use it (third person)
---
```

**Cursor (required):**
```yaml
---
description: ...          # What it does (no name field)
globs: ["**/*"]           # File patterns that trigger this rule
alwaysApply: false        # true = always injected into context
---
```
</yaml_requirements>

<success_criteria>
A well-structured skill:
- Has valid YAML frontmatter
- Uses pure XML structure (no markdown headings in body)
- Has essential principles inline in SKILL.md
- Routes directly to appropriate workflows based on user intent
- Keeps SKILL.md under 500 lines
- Works for both Claude Code and Cursor (or documents the difference)
- Has been tested with real usage
</success_criteria>
