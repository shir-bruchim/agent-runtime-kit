---
name: create-subagents
description: Expert guidance for creating specialist subagents and context agents for AI coding tools. Covers Claude Code agent files (.claude/agents/) and Cursor context equivalents. Use when creating specialized agents, writing agent system prompts, configuring tool access, or orchestrating multi-agent workflows.
---

<objective>
Subagents are specialized AI instances with focused roles, limited tool access, and domain-specific instructions. They enable delegation — the main agent orchestrates while specialists do focused work.

**Claude Code:** Agent files in `.claude/agents/*.md` — invoked automatically by description matching or explicitly by the user.
**Cursor:** No native agent system; use `.cursor/rules/*.mdc` to define specialist personas that activate on matching files, or use MCP tools as external agents.
</objective>

<quick_start>
**Minimal Claude Code subagent** (`.claude/agents/code-reviewer.md`):

```yaml
---
name: code-reviewer
description: Expert code reviewer. Use after code changes to review for quality, security, and best practices.
tools: Read, Grep, Glob, Bash
model: sonnet
---

<role>
You are a senior code reviewer focused on quality, security, and maintainability.
</role>

<focus_areas>
- Code correctness and edge cases
- Security vulnerabilities (OWASP Top 10)
- Performance bottlenecks
- Code style and readability
</focus_areas>

<output_format>
Findings with file:line references, severity (Critical/High/Medium/Low), and specific fix suggestions.
</output_format>
```
</quick_start>

<configuration>
## YAML Frontmatter Fields

```yaml
---
name: agent-name          # lowercase-with-hyphens, unique
description: ...          # When to use this agent (triggers auto-selection)
tools: Read, Grep, Glob   # Optional: restrict tools (least privilege)
model: sonnet             # Optional: sonnet|opus|haiku|inherit
color: blue               # Optional: UI color hint
---
```

**Model selection guidance:**
- `haiku` — Simple, fast, high-volume tasks (parsing, formatting)
- `sonnet` — Most tasks (code review, writing, analysis) — DEFAULT
- `opus` — Complex reasoning, architectural decisions, long tasks
- `inherit` — Use same model as main conversation

**Tool restriction (least privilege):**
```yaml
tools: Read, Grep, Glob        # Analysis only — can't modify files
tools: Read, Write, Edit       # Can modify but not execute
tools: Bash, Read, Write, Edit # Full access (use sparingly)
```
</configuration>

<execution_model>
## Critical Constraint: Subagents Cannot Interact with Users

Subagents run in isolated contexts. They:
- ✅ Can use tools: Read, Write, Edit, Bash, Grep, Glob
- ✅ Can access MCP servers
- ❌ **Cannot use AskUserQuestion** — no user interaction
- ❌ **Cannot present options and wait** — must complete autonomously
- ❌ User never sees intermediate steps — only the final output

**Design pattern:**
```
Main chat: Ask user → get decision → pass to subagent
Subagent:  Execute autonomously → return result
Main chat: Present result to user → ask next question
```
</execution_model>

<system_prompt_guidelines>
## Writing Effective Agent System Prompts

**Use pure XML structure:**
```yaml
---
name: security-reviewer
description: Reviews code for security vulnerabilities
tools: Read, Grep, Glob
model: sonnet
---

<role>
Senior security engineer specializing in application security.
</role>

<focus_areas>
- SQL injection and NoSQL injection
- XSS (reflected, stored, DOM-based)
- Authentication and authorization flaws
- Sensitive data exposure
</focus_areas>

<workflow>
1. Read all modified files completely
2. Identify vulnerabilities by category
3. Rate severity: Critical/High/Medium/Low
4. Suggest specific remediations with code examples
</workflow>

<constraints>
- NEVER suggest "sanitize input" without showing exactly how
- ALWAYS provide file:line references for findings
- Report only real issues, not theoretical ones without evidence
</constraints>

<output_format>
## Security Review: [Summary]

### Critical (must fix before merge)
- [file:line] — [issue] — [fix]

### High
...

### Summary
[X] issues found: [N] critical, [M] high, [P] medium
</output_format>
```

**Good vs bad descriptions:**
```yaml
# BAD — too generic, won't route well
description: A helpful assistant that helps with code

# GOOD — specific triggers, clear scope
description: Expert code reviewer for security and quality. Use proactively after code changes, before PRs, or when asked to review.
```

**XML tags for agents:**
| Tag | Purpose |
|-----|---------|
| `<role>` | Who the agent is |
| `<focus_areas>` | What to prioritize |
| `<workflow>` | Step-by-step process |
| `<constraints>` | NEVER/MUST/ALWAYS rules |
| `<output_format>` | How to structure deliverables |
| `<success_criteria>` | When the task is complete |
</system_prompt_guidelines>

<cursor_equivalent>
## Cursor: Context Agents via Rules

Cursor doesn't have agent files, but `.cursor/rules/*.mdc` can define specialist personas:

```yaml
---
description: Act as a security reviewer when reviewing code changes
globs: ["src/**/*.py", "src/**/*.ts"]
alwaysApply: false
---

When performing code review, adopt the security reviewer persona:

<role>Senior security engineer reviewing for vulnerabilities.</role>

<focus_areas>
- OWASP Top 10 vulnerabilities
- Authentication and authorization
- Input validation and sanitization
</focus_areas>

<output_format>
Report findings with file:line and severity rating.
</output_format>
```

**Key difference:** Cursor rules activate based on file patterns or being always-on, not by agent description matching. The user explicitly invokes the behavior by describing what they want.

**Cursor + MCP for true delegation:**
Use MCP tools to delegate to external services or specialized models when Cursor's native capabilities aren't enough.
</cursor_equivalent>

<reference_index>
All in `references/`:

- **orchestration-patterns.md** — Sequential, parallel, hierarchical patterns
- **writing-agent-prompts.md** — Prompt engineering for agents
- **error-handling.md** — Common failure modes and recovery
- **context-management.md** — Memory architecture and context strategies
</reference_index>

<success_criteria>
A well-configured subagent:
- Valid YAML frontmatter (name + description minimum)
- Clear role definition
- Appropriate tool restrictions (least privilege)
- Description optimized for automatic routing
- XML-structured system prompt
- Tested on representative tasks
- Model matches task complexity
</success_criteria>
