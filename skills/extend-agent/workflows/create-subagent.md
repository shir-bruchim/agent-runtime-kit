# Create Subagent Workflow

<objective>
Build a specialist AI subagent for Claude Code or Cursor. Subagents run in isolated contexts, cannot interact with users, and return a final result.
</objective>

<platform_compatibility>
Subagents work in BOTH Claude Code and Cursor:
- **Claude Code**: `.claude/agents/<name>.md` (or `~/.claude/agents/` for global)
- **Cursor**: `.cursor/agents/<name>.md` (or `.claude/agents/` — Cursor reads both)
- **Invocation**: Claude Code routes automatically by description; Cursor uses `/name` syntax

Frontmatter differences:
| Field | Claude Code | Cursor |
|-------|-------------|--------|
| `name` | ✅ Required | ✅ Required |
| `description` | ✅ Required | ✅ Required |
| `model` | `sonnet/opus/haiku/inherit` | `fast/inherit/<model-id>` |
| `tools` | ✅ Restricts tool access | Ignored by Cursor |
| `readonly` | Ignored | ✅ Read-only mode |
| `is_background` | Ignored | ✅ Background execution |
</platform_compatibility>

<steps>
1. **Name and describe the subagent**
   - `name`: lowercase-with-hyphens (must be unique)
   - `description`: Include trigger words — "Use when [specific condition]"

2. **Choose model**
   - `haiku` — Fast, simple tasks (git ops, formatting, parsing)
   - `sonnet` — Most tasks (code review, analysis, generation) — DEFAULT
   - `opus` — Complex reasoning (architecture, planning, multi-file analysis)

3. **Apply least-privilege tools** (Claude Code)
   - Read-only analysis: `tools: Read, Grep, Glob`
   - Code generation: `tools: Read, Write, Edit`
   - Full access: `tools: Read, Write, Edit, Bash, Grep, Glob`

4. **Write the system prompt** using XML structure:
   - `<role>` — Who the agent is
   - `<focus_areas>` — What to prioritize
   - `<workflow>` — Step-by-step process
   - `<constraints>` — NEVER/MUST/ALWAYS rules
   - `<output_format>` — How to structure deliverables

5. **Test with a representative prompt**
</steps>

<template>
```yaml
---
name: specialist-name
description: Expert [domain] specialist. Use when [specific trigger condition].
tools: Read, Grep, Glob, Bash
model: sonnet
---

<role>
You are a [domain] specialist focused on [specific area].
</role>

<focus_areas>
- Priority one
- Priority two
- Priority three
</focus_areas>

<workflow>
1. [First thing to do]
2. [Second thing to do]
3. [How to format and return results]
</workflow>

<constraints>
- NEVER modify files without explicit instructions
- ALWAYS include file:line references in findings
- Report only verified issues, not theoretical ones
</constraints>

<output_format>
## [Summary Title]

### [Section 1]
- [finding with file:line reference]

### Summary
[N] issues found.
</output_format>
```
</template>

<cursor_notes>
For Cursor subagents, invoke with `/specialist-name` in the chat. Cursor will delegate the task to the subagent's isolated context. The subagent returns its output to the main chat.

To make a read-only Cursor subagent:
```yaml
---
name: analyzer
description: Analyzes code without modifying anything
model: inherit
readonly: true
---
```
</cursor_notes>

<success_criteria>
- Subagent has `name` and `description` (minimum required)
- Description clearly states when to use it (triggers routing)
- Tools restricted to minimum needed (least privilege)
- System prompt uses XML structure
- Model matches task complexity
- Tested with `/name` (Cursor) or automatic routing (Claude Code)
</success_criteria>
