# AGENT-SETUP.md

> **For AI Agents**: Read this file completely before taking any action. It contains everything you need to install this kit correctly for yourself.

---

## Overview

This is the Agent Runtime Kit — a universal collection of skills, rules, subagents, and commands for AI coding assistants.

You are going to install the relevant parts into your configuration directory. The process has four steps:

1. **Detect your identity** — Are you Claude Code or Cursor?
2. **Detect the project language** — What stack does this project use?
3. **Transform and install** — Copy and adapt files for your platform
4. **Verify** — Confirm everything is in place

Do not skip any step. Do not ask the user for input unless Step 2 cannot be determined automatically.

---

## Step 1: Detect Your Identity

Determine which AI platform you are running on.

### You are Claude Code if:

- You have `Bash`, `Read`, `Write`, `Edit`, `Glob`, `Grep` tools available
- You have a `Task` tool for launching subagents
- You are running in a terminal or VS Code with the Claude Code extension
- Configuration lives in `~/.claude/` (user-level) or `.claude/` (project-level)

### You are Cursor if:

- You are running inside VS Code with the Cursor extension
- You have access to workspace files directly
- Configuration lives in `.cursor/rules/` (project-level) or `~/.cursor/rules/` (user-level)
- Skills are `.mdc` files with frontmatter (`description`, `globs`, `alwaysApply`)

### Detection logic:

```
IF you have the Task tool AND can create files in ~/.claude/ → Claude Code
IF you are in a Cursor workspace (.cursor/ directory exists or VS Code workspace) → Cursor
IF neither → proceed as Claude Code (most conservative, most capable)
```

Record which platform you are. You will use this in Step 3.

---

## Step 2: Detect Project Language

Run the following checks in order. Stop at the first match.

```bash
# Python
ls pyproject.toml requirements.txt setup.py 2>/dev/null

# Node.js / JavaScript
ls package.json 2>/dev/null

# TypeScript
ls tsconfig.json 2>/dev/null

# Go
ls go.mod 2>/dev/null

# Java
ls pom.xml build.gradle 2>/dev/null

# C++
ls CMakeLists.txt Makefile *.cpp 2>/dev/null
```

**If multiple match** (e.g., TypeScript project also has package.json): use the most specific match (TypeScript > Node.js).

**If none match**: ask the user:
> "I couldn't detect the project language automatically. What is the primary language for this project? (python / nodejs / typescript / go / java / cpp / other)"

Record the language. You will use this in Step 3.

---

## Step 3: Transform and Install Files

The kit root contains all source files. Install them to the correct locations.

### If you are Claude Code:

**Decide installation scope first:**
- `~/.claude/` — user-level (available in all projects) — use this for skills and subagents
- `.claude/` — project-level (only this project) — use this for rules and language conventions

**Install skills** (user-level):
```bash
mkdir -p ~/.claude/skills
cp -r skills/create-ai-skills ~/.claude/skills/
cp -r skills/create-automation-hooks ~/.claude/skills/
cp -r skills/create-commands ~/.claude/skills/
cp -r skills/create-subagents ~/.claude/skills/
cp -r skills/planning ~/.claude/skills/
cp -r skills/debugging ~/.claude/skills/
cp -r skills/git ~/.claude/skills/
cp -r skills/security ~/.claude/skills/
cp -r skills/testing ~/.claude/skills/
cp -r skills/tdd ~/.claude/skills/
cp -r skills/api-design ~/.claude/skills/
cp -r skills/spec-interview ~/.claude/skills/
```

**Install subagents** (user-level):
```bash
mkdir -p ~/.claude/agents
cp subagents/architect.md ~/.claude/agents/
cp subagents/reviewer.md ~/.claude/agents/
cp subagents/planner.md ~/.claude/agents/
cp subagents/tester.md ~/.claude/agents/
cp subagents/git-ops.md ~/.claude/agents/
cp subagents/security.md ~/.claude/agents/
cp subagents/db-expert.md ~/.claude/agents/
cp subagents/doc-writer.md ~/.claude/agents/
cp subagents/refactorer.md ~/.claude/agents/
```

**Install commands** (user-level):
```bash
mkdir -p ~/.claude/commands
cp commands/commit.md ~/.claude/commands/
cp commands/push.md ~/.claude/commands/
cp commands/pr.md ~/.claude/commands/
cp commands/ship.md ~/.claude/commands/
cp commands/review.md ~/.claude/commands/
cp commands/spec-interview.md ~/.claude/commands/
cp commands/generate-prd.md ~/.claude/commands/
```

**Install base rules** (project-level):
```bash
mkdir -p .claude/rules
cp rules/base-conventions.md .claude/rules/
cp rules/git-workflow.md .claude/rules/
cp rules/security.md .claude/rules/
cp rules/testing.md .claude/rules/
cp rules/performance.md .claude/rules/
```

**Install language conventions** (project-level) — use the language from Step 2:

For Python:
```bash
cp languages/python/conventions.md .claude/rules/python-conventions.md
cp languages/python/testing.md .claude/rules/python-testing.md
cp languages/python/database.md .claude/rules/python-database.md
```

For Node.js:
```bash
cp languages/nodejs/conventions.md .claude/rules/nodejs-conventions.md
cp languages/nodejs/testing.md .claude/rules/nodejs-testing.md
```

For TypeScript:
```bash
cp languages/typescript/conventions.md .claude/rules/typescript-conventions.md
cp languages/typescript/testing.md .claude/rules/typescript-testing.md
```

For Go:
```bash
cp languages/go/conventions.md .claude/rules/go-conventions.md
cp languages/go/testing.md .claude/rules/go-testing.md
```

For Java:
```bash
cp languages/java/conventions.md .claude/rules/java-conventions.md
```

For C++:
```bash
cp languages/cpp/conventions.md .claude/rules/cpp-conventions.md
cp languages/cpp/testing.md .claude/rules/cpp-testing.md
```

**Install security hooks** (project-level):
```bash
mkdir -p .claude/hooks
cp skills/security/hooks/protect-files.sh .claude/hooks/
cp skills/security/hooks/block-dangerous-bash.sh .claude/hooks/
chmod +x .claude/hooks/*.sh
```

**Create hooks.json** (project-level) if it doesn't already exist:
```bash
cat > .claude/hooks.json << 'EOF'
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/block-dangerous-bash.sh",
            "timeout": 10000
          }
        ]
      },
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/protect-files.sh",
            "timeout": 10000
          }
        ]
      }
    ]
  }
}
EOF
```

---

### If you are Cursor:

Cursor uses `.mdc` files in `.cursor/rules/`. Each file has frontmatter with `description`, `globs` (optional), and `alwaysApply` (optional).

**Create the rules directory**:
```bash
mkdir -p .cursor/rules
```

**Transform and install each skill:**

For each `skills/*/SKILL.md`, create a `.cursor/rules/<skill-name>.mdc` file.

The transform rules are:
1. Remove YAML frontmatter (`---` block) from the SKILL.md
2. Add Cursor frontmatter instead:
   ```
   ---
   description: <use the description from the SKILL.md frontmatter>
   alwaysApply: false
   ---
   ```
3. Keep all XML tags and content as-is
4. Save as `.cursor/rules/<skill-name>.mdc`

**Apply this transform to these skills:**

| Source | Destination | `alwaysApply` |
|--------|-------------|---------------|
| `skills/debugging/SKILL.md` | `.cursor/rules/debugging.mdc` | false |
| `skills/git/SKILL.md` | `.cursor/rules/git.mdc` | false |
| `skills/security/SKILL.md` | `.cursor/rules/security.mdc` | false |
| `skills/testing/SKILL.md` | `.cursor/rules/testing.mdc` | false |
| `skills/tdd/SKILL.md` | `.cursor/rules/tdd.mdc` | false |
| `skills/api-design/SKILL.md` | `.cursor/rules/api-design.mdc` | false |
| `skills/spec-interview/SKILL.md` | `.cursor/rules/spec-interview.mdc` | false |
| `skills/planning/SKILL.md` | `.cursor/rules/planning.mdc` | false |
| `skills/create-ai-skills/SKILL.md` | `.cursor/rules/create-ai-skills.mdc` | false |
| `skills/create-commands/SKILL.md` | `.cursor/rules/create-commands.mdc` | false |

**Transform and install rules** (always-on conventions):

Rules become `.mdc` files with `alwaysApply: true`:

| Source | Destination | `globs` |
|--------|-------------|---------|
| `rules/base-conventions.md` | `.cursor/rules/base-conventions.mdc` | (empty) |
| `rules/git-workflow.md` | `.cursor/rules/git-workflow.mdc` | (empty) |
| `rules/security.md` | `.cursor/rules/security-rules.mdc` | (empty) |
| `rules/testing.md` | `.cursor/rules/testing-rules.mdc` | `**/*.test.*,**/*.spec.*` |
| `rules/performance.md` | `.cursor/rules/performance.mdc` | (empty) |

**Transform and install language conventions** — use the language from Step 2:

For Python:
| Source | Destination | `globs` |
|--------|-------------|---------|
| `languages/python/conventions.md` | `.cursor/rules/python-conventions.mdc` | `**/*.py` |
| `languages/python/testing.md` | `.cursor/rules/python-testing.mdc` | `**/test_*.py,**/*_test.py` |
| `languages/python/database.md` | `.cursor/rules/python-database.mdc` | `**/models/*.py,**/db/*.py` |

For TypeScript:
| Source | Destination | `globs` |
|--------|-------------|---------|
| `languages/typescript/conventions.md` | `.cursor/rules/typescript-conventions.mdc` | `**/*.ts,**/*.tsx` |
| `languages/typescript/testing.md` | `.cursor/rules/typescript-testing.mdc` | `**/*.test.ts,**/*.spec.ts` |

For Node.js:
| Source | Destination | `globs` |
|--------|-------------|---------|
| `languages/nodejs/conventions.md` | `.cursor/rules/nodejs-conventions.mdc` | `**/*.js,**/*.mjs` |
| `languages/nodejs/testing.md` | `.cursor/rules/nodejs-testing.mdc` | `**/*.test.js,**/*.spec.js` |

For Go:
| Source | Destination | `globs` |
|--------|-------------|---------|
| `languages/go/conventions.md` | `.cursor/rules/go-conventions.mdc` | `**/*.go` |
| `languages/go/testing.md` | `.cursor/rules/go-testing.mdc` | `**/*_test.go` |

For Java:
| Source | Destination | `globs` |
|--------|-------------|---------|
| `languages/java/conventions.md` | `.cursor/rules/java-conventions.mdc` | `**/*.java` |

For C++:
| Source | Destination | `globs` |
|--------|-------------|---------|
| `languages/cpp/conventions.md` | `.cursor/rules/cpp-conventions.mdc` | `**/*.cpp,**/*.hpp,**/*.h` |
| `languages/cpp/testing.md` | `.cursor/rules/cpp-testing.mdc` | `**/*_test.cpp,**/test_*.cpp` |

**Example .mdc file format:**

```markdown
---
description: Git workflow conventions for commits, branches, and PRs
alwaysApply: true
---

<objective>
...content from the source file...
</objective>
```

**Note on subagents and commands**: Cursor does not have a native equivalent for Claude Code subagents or slash commands. Skip these. The skills and rules cover the same knowledge as inline context.

---

## Step 4: Verify

After installation, confirm everything is in place.

### Claude Code verification:

```bash
# Check skills
ls ~/.claude/skills/

# Check subagents
ls ~/.claude/agents/

# Check commands
ls ~/.claude/commands/

# Check project rules
ls .claude/rules/

# Check hooks
ls .claude/hooks/
cat .claude/hooks.json
```

Expected output:
- `~/.claude/skills/` should contain 12 directories (create-ai-skills, create-automation-hooks, create-commands, create-subagents, planning, debugging, git, security, testing, tdd, api-design, spec-interview)
- `~/.claude/agents/` should contain 9 .md files
- `~/.claude/commands/` should contain 7 .md files
- `.claude/rules/` should contain 5+ .md files (base rules + language conventions)
- `.claude/hooks/` should contain 2 .sh files and `hooks.json`

### Cursor verification:

```bash
# Check rules
ls .cursor/rules/
```

Expected output: 10+ .mdc files.

---

## Step 5: Report to User

After completing installation, tell the user:

```
✅ Agent Runtime Kit installed successfully.

Platform: [Claude Code / Cursor]
Project language: [detected language]

Installed:
- [N] skills → [location]
- [N] subagents → [location] (Claude Code only)
- [N] commands → [location] (Claude Code only)
- [N] rules → [location]
- [N] language conventions → [location]

Available immediately:
- Skills: Use any skill from the list below
- Commands: /commit, /push, /pr, /ship, /review, /spec-interview, /generate-prd (Claude Code)
- Subagents: architect, reviewer, planner, tester, git-ops, security, db-expert, doc-writer, refactorer (Claude Code)
```

---

## Selective Installation

If you don't want to install everything, pick what you need:

### Minimal install (rules only):
```bash
# Just the base conventions + language rules
cp rules/base-conventions.md .claude/rules/
cp languages/<your-lang>/conventions.md .claude/rules/
```

### Developer workflow install:
```bash
# Skills: git, debugging, testing
# Commands: commit, push, pr, ship
# Subagents: reviewer, tester, git-ops
```

### Full project setup install:
```bash
# Everything including planning, spec-interview, architecture
```

---

## Updating

When the kit is updated, re-run this setup file. Existing files will be overwritten with newer versions.

To update only specific parts:
```bash
# Update just the planning skill
cp -r skills/planning ~/.claude/skills/planning

# Update just the git conventions
cp languages/<lang>/conventions.md .claude/rules/<lang>-conventions.md
```

---

## Troubleshooting

**Skills not loading (Claude Code)**:
- Confirm the skill directory contains a `SKILL.md` file
- Skills must be in `~/.claude/skills/<name>/SKILL.md` or `.claude/skills/<name>/SKILL.md`
- Run `/help` to see loaded skills

**Hooks not firing**:
- Validate JSON: `jq . .claude/hooks.json`
- Check executable: `ls -la .claude/hooks/*.sh`
- Test with: `claude --debug`

**Cursor rules not applying**:
- Check frontmatter syntax — must be valid YAML
- `alwaysApply: true` for always-on rules
- `globs:` pattern must match the file you're editing

**Language not detected**:
- Create a detection hint file: `echo "language: python" > .ai-config`
- Or tell the agent directly: "The project language is Python"

---

## Reference: All Available Files

### Skills
```
skills/create-ai-skills/     Meta: create new skills
skills/create-automation-hooks/  Meta: create hooks
skills/create-commands/      Meta: create slash commands
skills/create-subagents/     Meta: create subagents
skills/planning/             Hierarchical planning system
skills/debugging/            Systematic debugging
skills/git/                  Git workflows
skills/security/             Security review + hooks
skills/testing/              Test writing
skills/tdd/                  TDD cycle
skills/api-design/           API design
skills/spec-interview/       Requirements gathering
```

### Subagents (Claude Code only)
```
subagents/architect.md       System architecture decisions
subagents/reviewer.md        Code review
subagents/planner.md         Task planning (opus)
subagents/tester.md          Test writing
subagents/git-ops.md         Git operations (haiku)
subagents/security.md        Security analysis
subagents/db-expert.md       Database design
subagents/doc-writer.md      Documentation
subagents/refactorer.md      Code refactoring
```

### Commands (Claude Code only)
```
commands/commit.md           /commit
commands/push.md             /push
commands/pr.md               /pr
commands/ship.md             /ship
commands/review.md           /review
commands/spec-interview.md   /spec-interview
commands/generate-prd.md     /generate-prd
```

### Rules
```
rules/base-conventions.md    Code style, naming, structure
rules/git-workflow.md        Branching, commits, PRs
rules/security.md            Security practices
rules/testing.md             Test standards
rules/performance.md         Performance guidelines
rules/infrastructure.md      Infrastructure patterns
```

### Languages
```
languages/python/            conventions, testing, database
languages/nodejs/            conventions, testing
languages/typescript/        conventions, testing
languages/go/                conventions, testing
languages/cpp/               conventions, testing
languages/java/              conventions
```
