---
name: create-commands
description: Expert guidance for creating reusable commands for AI agents. Covers Claude Code slash commands (.claude/commands/) and Cursor command equivalents. Use when creating /commands, understanding command structure, YAML frontmatter, dynamic context loading, or argument handling.
---

<objective>
Commands are reusable prompt templates that trigger workflows with a short invocation. They standardize team workflows and let agents execute complex, multi-step operations consistently.

**Claude Code:** Slash commands — invoke with `/command-name [args]`
**Cursor:** No native slash command system; use `.cursor/rules/` with `alwaysApply: false` as on-demand rules, or prompt templates stored in the project
</objective>

<quick_start>
**Create a Claude Code command:**

1. Create `.claude/commands/` directory (project) or `~/.claude/commands/` (personal)
2. Create `command-name.md`
3. Add YAML frontmatter + XML-structured body
4. Invoke with `/command-name [args]`

**Minimal example** (`.claude/commands/review.md`):
```yaml
---
description: Review current code changes for quality and correctness
---

<objective>Review all changes in the current working tree.</objective>
<process>
1. Run `git diff` to see all changes
2. Review each changed file for correctness, style, and edge cases
3. Report findings with file:line references
</process>
<success_criteria>All changed files reviewed with actionable feedback.</success_criteria>
```
</quick_start>

<command_structure>
## Command File Anatomy

```yaml
---
description: What the command does (shown in /help)        # Required
argument-hint: [optional-arg]                              # Optional
allowed-tools: Bash(git add:*), Bash(git commit:*)         # Optional
---

<objective>
What to accomplish and why. Use $ARGUMENTS if command takes input.
</objective>

<context>
Current state: !`git status`
Relevant file: @package.json
</context>

<process>
1. First step
2. Second step
3. Verify
</process>

<success_criteria>
Definition of done.
</success_criteria>
```

## YAML Fields

| Field | Required | Purpose |
|-------|----------|---------|
| `description` | Yes | Shown in /help. What does this do? |
| `argument-hint` | No | Hints for what args to pass |
| `allowed-tools` | No | Restricts which tools Claude can use |

## Required XML Tags

- `<objective>` — What and why
- `<process>` — Numbered steps
- `<success_criteria>` — Definition of done

## Optional XML Tags

- `<context>` — Load dynamic state with `!``command``` or `@file`
- `<verification>` — Checks before marking complete
- `<testing>` — Test commands to run
- `<output>` — Files created/modified
</command_structure>

<arguments>
## Handling Arguments

**All arguments as string (`$ARGUMENTS`):**
```yaml
---
description: Fix issue by number
argument-hint: [issue-number]
---
<objective>Fix issue #$ARGUMENTS following project conventions.</objective>
```
**Usage:** `/fix-issue 123`

**Positional arguments ($1, $2, $3):**
```yaml
---
description: Review PR with priority
argument-hint: <pr-number> <priority>
---
<objective>Review PR #$1 with priority $2.</objective>
```
**Usage:** `/review-pr 456 high`

**No arguments** (operates on current context):
```yaml
---
description: Create git commit for current changes
---
<context>Status: !`git status`</context>
```
**Usage:** `/commit`
</arguments>

<dynamic_context>
## Dynamic Context Loading

Execute commands in context using `!` prefix (no space before backtick):

```markdown
<context>
Git status: !`git status`
Recent commits: !`git log --oneline -5`
Package info: @package.json
</context>
```

Commands execute at invocation time. Output is included in the expanded prompt.

**Note:** In documentation, a space may appear after `!` to prevent execution. In actual command files, there is NO space between `!` and the backtick.
</dynamic_context>

<cursor_equivalent>
## Cursor Equivalents

Cursor doesn't have slash commands, but you can achieve similar results:

**On-demand rules** (must be explicitly requested):
```yaml
---
description: When asked to create a git commit, follow this workflow
globs: []
alwaysApply: false
---

<process>
1. Run git status to see changes
2. Stage relevant files
3. Write commit message following conventional commits
4. Create commit with Co-authored-by trailer
</process>
```

**Stored prompt templates:**
Create a `prompts/` directory with markdown files the agent can reference when asked to perform specific tasks. Not auto-invoked like slash commands, but reusable.
</cursor_equivalent>

<common_patterns>
## Common Command Patterns

**Git operations (with tool restrictions):**
```yaml
---
description: Stage and commit changes
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*)
---

<context>Status: !`git status`
Changes: !`git diff HEAD`
Recent: !`git log --oneline -5`</context>

<process>
1. Review all changes
2. Stage relevant files
3. Write commit message following repo convention
4. Create commit
</process>
<success_criteria>Commit created with descriptive message.</success_criteria>
```

**Code analysis:**
```yaml
---
description: Review code for security vulnerabilities
---
<objective>Review code for OWASP Top 10 vulnerabilities.</objective>
<process>
1. Scan for SQL injection, XSS, authentication issues
2. Report findings with severity (Critical/High/Medium/Low)
3. Suggest specific remediations
</process>
<success_criteria>All major vulnerability types checked with actionable fixes.</success_criteria>
```
</common_patterns>

<success_criteria>
A well-structured command:
- Has `description` field (appears in /help)
- Uses XML structure in body
- Has objective, process, success_criteria
- Uses `$ARGUMENTS` only when user input is needed
- Tool restrictions applied when appropriate
- Dynamic context loaded for state-dependent tasks
</success_criteria>
