# Workflow: Convert Skill to Cursor Format

<purpose>
Transform a universal SKILL.md file into Cursor's .mdc format.
</purpose>

<process>

<step name="read_source">
Read the source SKILL.md file.
Note:
- The `name:` field value
- The `description:` field value
- What files/languages it applies to (for globs)
- Whether it should always apply or be on-demand
</step>

<step name="determine_globs">
Based on skill content, choose appropriate globs:

| Skill Type | Globs |
|------------|-------|
| General coding conventions | `["**/*"]` |
| Python-specific | `["**/*.py"]` |
| TypeScript/JavaScript | `["**/*.ts", "**/*.tsx", "**/*.js", "**/*.jsx"]` |
| Go | `["**/*.go"]` |
| C++ | `["**/*.cpp", "**/*.hpp", "**/*.h"]` |
| Testing files | `["**/*test*", "**/*spec*"]` |
| API/route files | `["**/api/**", "**/routes/**"]` |
| All files (no filter) | `[]` or `["**/*"]` |
</step>

<step name="determine_always_apply">
Choose `alwaysApply`:
- `true` → Coding standards, project conventions, always-relevant rules
- `false` → Task-specific skills, language-specific patterns, on-demand help
</step>

<step name="create_mdc_file">
Create the `.mdc` file:

```yaml
---
description: <copy description from SKILL.md>
globs: <determined above>
alwaysApply: <determined above>
---

<copy entire body of SKILL.md, removing only the name: field>
```

Save to `.cursor/rules/<skill-name>.mdc` in the target project.
</step>

<step name="handle_router_skills">
For router skills with subdirectories:

Cursor doesn't natively support the router pattern with subdirectory loading.

**Option A (Inline):** Merge SKILL.md + most important reference/workflow into single .mdc file.
Best for skills with 1-2 workflows and light reference content.

**Option B (Multiple Rules):** Create separate .mdc files for each workflow:
- `<skill>-main.mdc` (principles + routing)  
- `<skill>-create.mdc` (create workflow)
- `<skill>-audit.mdc` (audit workflow)
Best for complex skills with multiple distinct workflows.

**Option C (Reference Pointer):** Create single .mdc that references the universal kit:
```
See the full skill at: skills/<skill-name>/ in your agent-runtime-kit.
Load the relevant workflow file before proceeding.
```
Best when you want to keep using the universal kit files.
</step>

</process>

<success_criteria>
- .mdc file created with valid frontmatter
- description is clear and actionable
- globs match the files this rule should apply to
- alwaysApply is set correctly
- Content body is intact and correct
</success_criteria>
