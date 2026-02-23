# Skill Structure Reference

## Simple Skill (Single File)

Use for focused, single-purpose capabilities:

```yaml
---
name: skill-name
description: Clear description of what it does and when to use it.
---

<objective>
What this skill accomplishes and why it exists.
</objective>

<quick_start>
Immediate, actionable guidance for the most common use case.
</quick_start>

<process>
1. Step one
2. Step two
3. Step three
</process>

<success_criteria>
- Criterion 1
- Criterion 2
</success_criteria>
```

**When to use simple skills:**
- Single, well-defined task
- No branching logic
- Content fits under 300 lines
- Examples: `git`, `debug-like-expert`, `pytest-best-practices`

## Router Skill (Directory Pattern)

Use for complex capabilities with multiple workflows:

```
skill-name/
├── SKILL.md              # Essential principles + intake + routing
├── workflows/
│   ├── workflow-a.md     # Step-by-step procedures
│   └── workflow-b.md
├── references/
│   ├── topic-a.md        # Domain knowledge
│   └── topic-b.md
├── templates/
│   └── output-template.md  # Structures to copy and fill
└── scripts/
    └── helper.sh         # Executable code
```

**SKILL.md structure for routers:**
```
<essential_principles>   Core rules that always apply
<intake>                 Question to ask user
<routing>               Maps responses to workflows
<reference_index>       Links to all reference files
<workflows_index>       Table of all workflows
<success_criteria>      How to know skill is working
```

**When to use router skills:**
- Multiple distinct workflows (create vs modify vs audit)
- Deep domain knowledge requiring references
- Reusable templates or scripts
- Examples: `create-ai-skills`, `planning`, `security`

## Content Loading Strategy

Router SKILL.md should stay under 500 lines. Detailed content goes in subdirectories, loaded only when needed:

```
Token budget:
SKILL.md alone:          ~3k tokens  (always loaded)
+ 1 workflow:            ~5k tokens  (when needed)
+ 1-2 references:        ~8k tokens  (when needed)
All content:             ~20k tokens (never all at once)
```

**Loading rules:**
- SKILL.md: Always loaded (essential principles, routing)
- Workflows: Load the ONE relevant workflow
- References: Load ONLY references needed for current workflow
- Templates: Copy when creating output, not before
- Scripts: Read and execute when needed

## XML Tag Convention

Use semantic XML tags, not markdown headings:

| Use This | Not This |
|----------|----------|
| `<objective>` | `## Objective` |
| `<process>` | `## Process` |
| `<success_criteria>` | `## Success Criteria` |
| `<essential_principles>` | `## Core Principles` |
| `<platform_notes>` | `## Platform-Specific Notes` |

Keep markdown formatting *within* XML content (bold, lists, code blocks are fine inside tags).
