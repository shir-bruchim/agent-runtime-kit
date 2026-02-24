# AGENT-SETUP.md

> **For AI Agents**: Read this file completely before taking any action. It contains everything you need to install this kit correctly for yourself.

---

## Overview

This is the Agent Runtime Kit — a universal collection of skills, rules, subagents, and commands for AI coding assistants.

You are going to install the relevant parts into your configuration directory. The process:

0. **Obtain the files** — Clone or fetch from GitHub (if invoked via URL)
1. **Detect your identity** — Are you Claude Code or Cursor?
2. **Detect the project language** — What stack does this project use?
3. **Check for conflicts** — Scan what already exists before touching anything
4. **Transform and install** — Copy and adapt files, resolving conflicts
5. **Verify** — Confirm everything is in place

Do not skip any step. The only times to ask the user for input: language can't be detected (Step 2), or a conflict needs a decision (Step 3).

---

## Step 0: Obtain the Kit Files

**If the user pasted a GitHub URL** (e.g., `https://github.com/shir-bruchim/agent-runtime-kit`):

Clone into a temporary directory and work from there:

```bash
git clone https://github.com/shir-bruchim/agent-runtime-kit /tmp/agent-runtime-kit
KIT_DIR="/tmp/agent-runtime-kit"
```

Use `$KIT_DIR` as your source path for all subsequent steps.

**If you are already inside the cloned repo directory:**

```bash
KIT_DIR="$(pwd)"
```

**If you cannot run git** (Cursor without terminal access): fetch each file from the raw GitHub URL:

```
Base: https://raw.githubusercontent.com/shir-bruchim/agent-runtime-kit/main/
Example: https://raw.githubusercontent.com/shir-bruchim/agent-runtime-kit/main/skills/debugging/SKILL.md
```

Fetch each needed file and write it to its destination path.

---

### Script Fast Path (use this whenever the repo is cloned)

Once `$KIT_DIR` is set, use the built-in scripts instead of running Steps 1–4 manually.
The scripts handle everything: conflict detection, language detection, atomicity, and resume.

**Step A — Generate a comparison plan (fast, cached by commit SHA):**

```bash
"${KIT_DIR}/scripts/check-kit-updates.sh" \
  --project-dir "$(pwd)" \
  > /tmp/kit-plan.json

cat /tmp/kit-plan.json
```

Read the JSON output:

| `status` value | What it means | Action |
|----------------|---------------|--------|
| `UP_TO_DATE` | Commit SHA matches last install — nothing changed | **Stop here. Nothing to do.** |
| `FIRST_INSTALL` | No previous install recorded | Proceed to Step B |
| `NEEDS_UPDATE` | Kit has new/changed files | Review the `"files"` array, proceed to Step B |

If `"needs_update": false` → **skip Steps 1–5 entirely**.

**Step B — Install from the plan (atomic, resumable):**

```bash
# Install all NEW and CHANGED files:
"${KIT_DIR}/scripts/install-kit.sh" \
  --plan /tmp/kit-plan.json \
  --project-dir "$(pwd)"

# If the process was interrupted, resume exactly where it stopped:
"${KIT_DIR}/scripts/install-kit.sh" \
  --plan /tmp/kit-plan.json \
  --project-dir "$(pwd)" \
  --resume

# Preview without writing anything:
"${KIT_DIR}/scripts/install-kit.sh" \
  --plan /tmp/kit-plan.json \
  --dry-run
```

**For CHANGED files** the install script replaces them by default. If you want to keep or merge a specific file instead of replacing it, edit `/tmp/kit-plan.json` and change its `"action"` to `"SKIP"` or `"MERGE"` before running install.

After install succeeds → **jump to Step 5 (Verify)**.

> **Token efficiency note:** Do NOT read `scripts/check-kit-updates.sh` or `scripts/install-kit.sh`
> into your context. They are shell scripts for execution only — not instructions for you.
> Run them with Bash and act on their JSON output.

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

Record which platform you are. You will use this in Step 4 (install).

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

Record the language. You will use this in Step 4 (install).

---

## Step 3: Check for Conflicts

Before installing anything, scan the destination directories and compare with kit files. This prevents silently overwriting work the user already has.

### 3a — Scan existing destinations

Check all target locations for already-existing files:

```bash
# Claude Code
ls ~/.claude/skills/ 2>/dev/null
ls ~/.claude/agents/ 2>/dev/null
ls ~/.claude/commands/ 2>/dev/null
ls .claude/rules/ 2>/dev/null

# Cursor
ls .cursor/rules/ 2>/dev/null
ls .cursor/agents/ 2>/dev/null
```

### 3b — For each file you plan to install

Run this logic for every file before writing it:

```
Does destination file exist?
├── No  → INSTALL (proceed normally)
└── Yes →
    Are the files identical?
    ├── Yes → SKIP — log "✓ Already up to date: [path]"
    └── No  →
        Show the user a summary of what differs, then ask:
        > "[filename] already exists and has local changes. What would you like to do?
        >  1. Replace with kit version  (overwrites your local file)
        >  2. Keep existing  (skip this file)
        >  3. Merge  (I'll show you both and combine them)
        >  4. Show full diff first"
        Wait for answer before proceeding.
```

**Do not batch these questions.** Ask about each conflict as you encounter it. If the user says "replace all" or "keep all", apply that choice to the remaining files without asking again.

### 3c — Detect functionally equivalent files with different names

Before installing each skill, subagent, or command from the kit, also scan for files that do the same job under a different name.

**How to detect a functional duplicate:**
1. Read the kit file's `description:` field from its YAML frontmatter
2. Read the `description:` field of every existing file in the same destination directory
3. If two descriptions are semantically similar (same purpose, same domain), flag it

**Example:**
- Kit has: `reviewer.md` — `description: Expert code reviewer. Use after code changes...`
- User has: `code-review.md` — `description: Reviews code for quality and security...`
- These do the same thing → flag it

When a functional duplicate is found, ask:

> "You already have '[existing-name].md' which seems to do the same thing as '[kit-name].md' from the kit.
>
> Your file: [description line]
> Kit file: [description line]
>
> What would you like to do?
> 1. Keep both files (different names, both available)
> 2. Replace your file with the kit version  (rename + overwrite)
> 3. Merge the kit content into your existing file
> 4. Keep only your file, skip the kit version
> 5. Delete your file and install the kit version"

Wait for the user's answer before proceeding.

### 3d — Build an install plan

After scanning everything, before writing a single file, present a summary:

```
Install plan:
  ✓ 12 files — new (will install)
  ~ 3 files  — already up to date (will skip)
  ⚠ 2 files  — conflict (awaiting your decision):
      - ~/.claude/agents/reviewer.md  (differs from kit version)
      - ~/.claude/commands/commit.md  (differs from kit version)
  ? 1 file   — possible duplicate:
      - ~/.claude/agents/code-review.md may duplicate reviewer.md

Resolve conflicts above, then I'll proceed with the install.
```

Only start writing files after all conflicts are resolved.

---

## Step 4: Transform and Install Files

The kit root contains all source files. Install them to the correct locations.

### If you are Claude Code:

**Decide installation scope first:**
- `~/.claude/` — user-level (available in all projects) — use this for skills and subagents
- `.claude/` — project-level (only this project) — use this for rules and language conventions

**Install skills** (user-level):
```bash
mkdir -p ~/.claude/skills
cp -r skills/extend-agent ~/.claude/skills/
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

**Install base rules:**

> **Prefer the main agent config file over rule files.** For Claude Code, add conventions to the
> project's `CLAUDE.md` (or create one). For Cursor, add to `.cursorrules`. Only create separate
> `.claude/rules/` files for project-specific overrides that shouldn't apply globally.
> Universal rules (security, testing, base conventions) are already in your global `~/.claude/`
> from the user-level install — no need to duplicate them per project.

```bash
# Only if conventions not already in CLAUDE.md / .cursorrules:
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

**Install security hooks globally** (runs in every project, not just this one):
```bash
mkdir -p ~/.claude/hooks
cp skills/security/hooks/protect-files.sh ~/.claude/hooks/
cp skills/security/hooks/block-dangerous-bash.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh
```

Then add to `~/.claude/settings.json` under `"hooks"` (merge if section already exists):
```json
"PreToolUse": [
  {
    "matcher": "Bash",
    "hooks": [{"type": "command", "command": "~/.claude/hooks/block-dangerous-bash.sh", "timeout": 10000}]
  },
  {
    "matcher": "Write|Edit",
    "hooks": [{"type": "command", "command": "~/.claude/hooks/protect-files.sh", "timeout": 10000}]
  }
]
```

> **Project-level hooks** (optional — if you also want hooks scoped to this project only):
```bash
mkdir -p .claude/hooks
cp skills/security/hooks/protect-files.sh .claude/hooks/
cp skills/security/hooks/block-dangerous-bash.sh .claude/hooks/
chmod +x .claude/hooks/*.sh
```
Then create `.claude/hooks.json` using `$CLAUDE_PROJECT_DIR/.claude/hooks/<script>.sh` as the command paths.

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
| `skills/extend-agent/SKILL.md` | `.cursor/rules/extend-agent.mdc` | false |

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

### Install subagents (both platforms)

Cursor subagents use the **same file format and path** as Claude Code. Install them to `.cursor/agents/` or `.claude/agents/` (Cursor reads both):

```bash
mkdir -p .cursor/agents
cp subagents/architect.md .cursor/agents/
cp subagents/reviewer.md .cursor/agents/
cp subagents/planner.md .cursor/agents/
cp subagents/tester.md .cursor/agents/
cp subagents/security.md .cursor/agents/
cp subagents/db-expert.md .cursor/agents/
cp subagents/doc-writer.md .cursor/agents/
cp subagents/refactorer.md .cursor/agents/
cp subagents/git-ops.md .cursor/agents/
```

**Invoke Cursor subagents with `/name`** (e.g., `/reviewer check this PR`).

**Frontmatter differences:** The `tools:` field in subagent files is Claude Code-specific and ignored by Cursor. To make a Cursor-specific read-only subagent, add `readonly: true` to the frontmatter.

### Commands for Cursor

Cursor does not have `/slash` commands. Copy command files as on-demand rules instead:

```bash
mkdir -p .cursor/rules
for f in commands/*.md; do
  name=$(basename $f .md)
  # Add Cursor frontmatter and save as .mdc
  echo "---\ndescription: $(head -3 $f | grep description | cut -d: -f2-)\nalwaysApply: false\n---\n" > ".cursor/rules/${name}.mdc"
  tail -n +6 "$f" >> ".cursor/rules/${name}.mdc"
done
```

---

## Cursor: Plan Mode

Cursor has a built-in **Plan Mode** (accessible via the mode selector in Cursor's chat). It:

- Asks clarifying questions before implementing
- Researches your codebase to understand context
- Generates an implementation plan for you to review
- Waits for your approval before building

**This is complementary to, not a replacement for, the `.planning/` file hierarchy.** Use Cursor's Plan Mode for initial discovery; use `.planning/` files for persistent, shareable project planning that survives across sessions and agents.

**Recommendation:**
1. Use Cursor's Plan Mode to explore options and get a plan
2. Save the agreed plan to `.planning/phases/XX-phase-PLAN.md`
3. Reference that file in future sessions for continuity

---

## Skill → .mdc Transformation Example

### Source (Claude Code): `skills/debugging/SKILL.md`
```yaml
---
name: debugging
description: Deep analysis debugging mode. Use when standard troubleshooting fails or issues require systematic root cause analysis.
---

<objective>
Methodical debugging using scientific method...
</objective>
```

### Result (Cursor): `.cursor/rules/debugging.mdc`
```yaml
---
description: Deep analysis debugging mode. Use when standard troubleshooting fails or issues require systematic root cause analysis.
globs: []
alwaysApply: false
---

<objective>
Methodical debugging using scientific method...
</objective>
```

**What changed:**
- Removed `name:` field (Cursor doesn't use it)
- Added `globs: []` (empty = on-demand, not file-triggered)
- Added `alwaysApply: false` (activate when asked, not always)
- File extension: `.md` → `.mdc`
- File location: `skills/<name>/SKILL.md` → `.cursor/rules/<name>.mdc`

**For always-on rules** (base-conventions, security rules): set `alwaysApply: true` and optionally add `globs`.

---

## Step 5: Verify

After installation, confirm everything is in place.

### Claude Code verification:

```bash
# Check skills
ls ~/.claude/skills/

# Check subagents
ls ~/.claude/agents/

# Check commands
ls ~/.claude/commands/

# Check global hooks
ls ~/.claude/hooks/
```

Expected output:
- `~/.claude/skills/` should contain 10 directories (extend-agent, planning, debugging, git, security, testing, tdd, api-design, spec-interview, implement-jira-ticket)
- `~/.claude/agents/` should contain 9 .md files
- `~/.claude/commands/` should contain 11 .md files
- `~/.claude/hooks/` should contain `block-dangerous-bash.sh` and `protect-files.sh`
- `~/.claude/settings.json` should have `PreToolUse` hooks configured

### Cursor verification:

```bash
# Check rules
ls .cursor/rules/
```

Expected output: 10+ .mdc files.

---

## Step 6: Report to User

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
skills/extend-agent/         Meta: create skills, commands, hooks, and subagents
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
