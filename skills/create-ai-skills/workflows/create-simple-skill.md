# Workflow: Create Simple Skill

<purpose>
Build a single-file skill for a focused, well-defined task.
</purpose>

<process>

<step name="gather_intent">
Ask the user:
1. What task should this skill help with?
2. When should it be invoked? (describe the trigger)
3. What language/platform is it for?
4. Should it work for Claude Code, Cursor, or both?
</step>

<step name="determine_skill_type">
Based on the answers, decide: simple single file or router pattern?

**Choose simple if:**
- Single, well-defined task
- Linear workflow (no branching)
- Content will fit under 300 lines

**Choose router if:**
- Multiple distinct use cases
- Deep domain knowledge needed
- Reusable templates or scripts required

If router: redirect to `create-router-skill.md` workflow.
</step>

<step name="create_skill_file">
Determine installation path:
- Claude Code: `.claude/skills/<name>/SKILL.md` or `~/.claude/skills/<name>/SKILL.md`
- Cursor: `.cursor/rules/<name>.mdc` or `~/.cursor/rules/<name>.mdc`
- Universal (in this kit): `skills/<name>/SKILL.md`

Write the skill file with this structure:
```yaml
---
name: skill-name
description: Clear description of what it does and when to use it.
---

<objective>
What this skill accomplishes.
</objective>

<quick_start>
Most common use case, immediately actionable.
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
</step>

<step name="verify">
Review the created skill:
- [ ] YAML frontmatter is valid
- [ ] Description clearly states WHAT and WHEN
- [ ] No markdown headings in body (use XML tags)
- [ ] Process steps are actionable
- [ ] Success criteria are measurable
- [ ] Content is under 300 lines
</step>

</process>

<success_criteria>
Skill file exists and is immediately usable by an AI agent.
</success_criteria>
