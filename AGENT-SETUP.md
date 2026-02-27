# AGENT-SETUP.md

> **For AI Agents**: Read this file completely before taking any action. It contains everything you need to install this kit correctly.

---

## Overview

This is the Agent Runtime Kit — a universal collection of skills, rules, subagents, and commands for AI coding assistants.

You will install the CORE profile into the user's global configuration (`~/.claude/` for Claude Code, `~/.cursor/` for Cursor). The default install is **global** (available in all projects). Project-specific overrides go in `.claude/rules/` or `.cursor/rules/`.

The process:
0. **Obtain the files** — Clone shallow to `/tmp`, work from there, clean up after
1. **Detect your platform** — Claude Code, Cursor, or both?
2. **Generate a plan** — Run `check-kit-updates.sh` for a per-file action plan
3. **Review the plan** — User can SKIP or MERGE specific files before install
4. **Install** — Run `install-kit.sh` from the plan (atomic, resumable)
5. **Verify** — Confirm everything is in place

Do not skip any step. The only time to ask the user for input: a changed file needs a decision (action = `CHANGED` — default is replace, but offer them the option to SKIP/MERGE).

---

## Step 0: Obtain the Kit Files

**Token-efficient flow — always use this when invoked via URL:**

```bash
# Clean up any previous attempt, then clone shallow (minimal data transfer)
rm -rf /tmp/agent-runtime-kit
git clone --depth 1 https://github.com/shir-bruchim/agent-runtime-kit /tmp/agent-runtime-kit
KIT_DIR="/tmp/agent-runtime-kit"
```

After installation completes successfully, clean up:
```bash
rm -rf /tmp/agent-runtime-kit
```

**If you are already inside the cloned repo:**
```bash
KIT_DIR="$(pwd)"
# Do NOT delete $KIT_DIR at the end in this case
```

**If git is unavailable** (Cursor without terminal access): fetch files via raw URL:
```
Base: https://raw.githubusercontent.com/shir-bruchim/agent-runtime-kit/main/
```
Fetch each needed file individually and write to its destination.

> **Token efficiency:** Do NOT read `scripts/check-kit-updates.sh` or `scripts/install-kit.sh` into your context. They are shell scripts for execution only. Run them and act on their output.

---

## Step 1: Detect Your Platform

Determine which AI platform you are running on.

### You are Claude Code if:
- You have `Bash`, `Read`, `Write`, `Edit`, `Glob`, `Grep`, `Task` tools
- Configuration lives in `~/.claude/` (user-level) or `.claude/` (project-level)

### You are Cursor if:
- You are running inside VS Code with the Cursor extension
- Configuration lives in `~/.cursor/rules/` (user-level) or `.cursor/rules/` (project)
- Rules are `.mdc` files with frontmatter (`description`, `globs`, `alwaysApply`)

### Detection logic:
```
IF Task tool available AND can write to ~/.claude/ → Claude Code
IF .cursor/ directory exists OR running in Cursor workspace → Cursor
IF both available → both
IF neither → default to Claude Code
```

Record your platform. Pass it to `--platform` in Step 2.

---

## Step 2: Generate the Plan

Run the check script with CORE profile (default) and your detected platform:

```bash
# CORE profile (recommended — smaller, high-signal):
"${KIT_DIR}/scripts/check-kit-updates.sh" \
  --profile core \
  --platform auto \
  --project-dir "$(pwd)" \
  > /tmp/kit-plan.json

cat /tmp/kit-plan.json
```

| `status` value | Meaning | Action |
|----------------|---------|--------|
| `UP_TO_DATE` | Nothing changed since last install | **Stop. Nothing to do.** |
| `FIRST_INSTALL` | No previous install recorded | Proceed to Step 3 |
| `NEEDS_UPDATE` | New or changed files exist | Review the `"files"` array, proceed to Step 3 |

**To install the FULL profile instead:**
```bash
"${KIT_DIR}/scripts/check-kit-updates.sh" --profile full --platform auto \
  --project-dir "$(pwd)" > /tmp/kit-plan.json
```

**Profile summary:**

| | CORE | FULL |
|-|------|------|
| Skills | extend-agent, git, testing, debugging, security | + planning, tdd, api-design, spec-interview, implement-jira-ticket |
| Rules | base-conventions, security, testing | + git-workflow, performance, infrastructure |
| Commands | commit, push, pr, ship, review, test | + debug, refactor, spec-interview, generate-prd, implement-jira-ticket |
| Subagents | reviewer, tester, git-ops, security | + architect, planner, db-expert, doc-writer, refactorer |

See `PROFILES.md` for full details.

---

## Step 3: Review and Edit the Plan (Optional)

The plan JSON lists every file with an `action`:
- `NEW` — will install
- `IDENTICAL` — will skip (already up to date)
- `CHANGED` — **will replace by default**
- `SKIP` — user-set: skip this file
- `MERGE` — user-set: leave file as-is, user merges manually

**For CHANGED files:** the installer replaces them by default. If you want to keep or merge a specific file, edit `/tmp/kit-plan.json` and change its `"action"` to `"SKIP"` or `"MERGE"` before running install.

Present a summary to the user before installing:
```
Install plan:
  ✓ 12 files — new (will install)
  ~ 3 files  — already up to date (will skip)
  ⚠  2 files  — changed (will replace by default)

If you want to keep any changed file, I can mark it SKIP or MERGE.
Proceed with install?
```

---

## Step 4: Install from the Plan

```bash
# Install all NEW and CHANGED files (atomic, resumable):
"${KIT_DIR}/scripts/install-kit.sh" \
  --plan /tmp/kit-plan.json \
  --project-dir "$(pwd)"

# If interrupted, resume exactly where it stopped:
"${KIT_DIR}/scripts/install-kit.sh" \
  --plan /tmp/kit-plan.json \
  --project-dir "$(pwd)" \
  --resume

# Preview without writing anything:
"${KIT_DIR}/scripts/install-kit.sh" \
  --plan /tmp/kit-plan.json \
  --dry-run
```

**For Cursor platform:** The installer automatically generates `.mdc` files with correct frontmatter (`alwaysApply: true` for CORE rules, `alwaysApply: false` for skills). No manual transformation needed.

**What gets installed where:**

| Item | Claude Code (global) | Cursor (global) |
|------|---------------------|-----------------|
| Skills | `~/.claude/skills/` | `~/.cursor/rules/skill-*.mdc` |
| Subagents | `~/.claude/agents/` | (same format, `.claude/agents/`) |
| Commands | `~/.claude/commands/` | (Cursor reads as on-demand rules) |
| Rules | `.claude/rules/` (project) | `~/.cursor/rules/*.mdc` |
| Security hooks | `~/.claude/hooks/` | N/A (use alwaysApply rules) |
| Language conventions | `.claude/rules/` (project) | `.cursor/rules/` (project) |
| AGENTS.md | Project root | Project root |
| GEMINI.md | Project root | Project root |

---

## Step 5: Opt-in Enhancements (Claude Code only)

These are **never installed automatically**. Ask the user if they want them before proceeding.

### Security Hooks (OPT-IN)

Hooks that block destructive shell commands and protect sensitive file paths.

**Enable via install script (recommended):**
```bash
"${KIT_DIR}/scripts/check-kit-updates.sh" \
  --profile core \
  --platform claude \
  --hooks \
  > /tmp/kit-plan.json
"${KIT_DIR}/scripts/install-kit.sh" --plan /tmp/kit-plan.json
```

**Or install manually:**
```bash
mkdir -p ~/.claude/hooks
cp "${KIT_DIR}/hooks/block-dangerous-commands.sh" ~/.claude/hooks/
cp "${KIT_DIR}/hooks/protect-files.sh" ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh
```

Then add to `~/.claude/settings.json` under `"hooks"` (merge if section already exists):
```json
"PreToolUse": [
  {
    "matcher": "Bash",
    "hooks": [{"type": "command", "command": "~/.claude/hooks/block-dangerous-commands.sh", "timeout": 10000}]
  },
  {
    "matcher": "Write|Edit",
    "hooks": [{"type": "command", "command": "~/.claude/hooks/protect-files.sh", "timeout": 10000}]
  }
]
```

Configure protected paths by creating `~/.claude/protected-paths.txt` (one path prefix per line).

### Skill Routing (OPT-IN, FULL profile)

Generates a compact routing table that auto-loads the right skill for each task.

```bash
# Preview:
python3 "${KIT_DIR}/scripts/compile-claude-routing.py" --dry-run

# Install globally:
python3 "${KIT_DIR}/scripts/compile-claude-routing.py" --target global --profile full
```

---

## Step 6: Verify

### Claude Code:
```bash
ls ~/.claude/skills/     # Should contain: extend-agent git testing debugging security (+ more if FULL)
ls ~/.claude/agents/     # Should contain: reviewer.md tester.md git-ops.md security.md (+ more if FULL)
ls ~/.claude/commands/   # Should contain: commit.md push.md pr.md ship.md review.md test.md (+ more if FULL)
ls ~/.claude/hooks/      # Should contain: block-dangerous-bash.sh protect-files.sh
```

### Cursor:
```bash
ls ~/.cursor/rules/      # Should contain: skill-*.mdc, base-conventions.mdc, security.mdc, testing.mdc
```

---

## Step 7: Cleanup and Report

If you cloned to `/tmp/agent-runtime-kit`, remove it now:
```bash
rm -rf /tmp/agent-runtime-kit
```

Then report to the user:

```
✅ Agent Runtime Kit installed successfully.

Platform: [Claude Code / Cursor / both]
Profile: CORE (or FULL)
Project language: [detected language]

Installed (global):
- [N] skills → ~/.claude/skills/ (or ~/.cursor/rules/)
- [N] subagents → ~/.claude/agents/
- [N] commands → ~/.claude/commands/

Installed (project):
- [N] rules → .claude/rules/
- [N] language conventions → .claude/rules/
- AGENTS.md → project root
- GEMINI.md → project root

Available immediately:
- Commands: /commit, /push, /pr, /ship, /review, /test
- Subagents: reviewer, tester, git-ops, security
- Skills: extend-agent, git, testing, debugging, security

To upgrade to FULL profile later:
  scripts/check-kit-updates.sh --profile full | scripts/install-kit.sh
```

---

## MCP Servers (OPT-IN Only)

MCP is **never installed by default**. If the user wants MCP server integration, direct them to `mcp/SETUP.md`. Do not install any MCP server without explicit user request.

---

## Manual Cursor Transform (Fallback)

If the install script is unavailable and you must transform manually:

For each `skills/*/SKILL.md` → `.cursor/rules/skill-<name>.mdc`:
1. Remove SKILL.md YAML frontmatter
2. Add Cursor frontmatter:
   ```yaml
   ---
   description: <from SKILL.md description field>
   globs: []
   alwaysApply: false
   ---
   ```
3. Keep all XML tags and content

For `rules/*.md` → `.cursor/rules/<name>.mdc`:
- Same transform, but set `alwaysApply: true` for CORE rules (base-conventions, security, testing)

---

## Selective Installation

If you don't want to install everything, edit `/tmp/kit-plan.json` before running install — change any file's `action` to `SKIP`.

Or install manually:

### Minimal (rules only):
```bash
cp rules/base-conventions.md .claude/rules/
cp languages/<your-lang>/conventions.md .claude/rules/
```

### Developer workflow:
```bash
# Skills: git, debugging, testing
# Commands: commit, push, pr, ship
# Subagents: reviewer, tester, git-ops
```

---

## Updating

Re-run this setup. The check script compares by commit SHA — if nothing changed, it exits immediately (`UP_TO_DATE`). Otherwise it generates a new plan with only the changed files.

```bash
git clone --depth 1 https://github.com/shir-bruchim/agent-runtime-kit /tmp/agent-runtime-kit
/tmp/agent-runtime-kit/scripts/check-kit-updates.sh --profile core > /tmp/kit-plan.json
/tmp/agent-runtime-kit/scripts/install-kit.sh --plan /tmp/kit-plan.json
rm -rf /tmp/agent-runtime-kit
```

---

## Troubleshooting

**Skills not loading (Claude Code):**
- Confirm `~/.claude/skills/<name>/SKILL.md` exists
- Run `/help` to see loaded skills

**Hooks not firing:**
- Validate JSON: `jq . ~/.claude/settings.json`
- Check executable: `ls -la ~/.claude/hooks/*.sh`
- Test with: `claude --debug`

**Cursor rules not applying:**
- Check frontmatter is valid YAML
- `alwaysApply: true` for always-on rules
- `globs:` pattern must match the file you're editing

**Clone fails (no git):**
- Use raw URL fetch (see Step 0 fallback)

---

## Reference: CORE Profile Files

### Skills (global)
```
skills/extend-agent/    Meta: create skills, commands, hooks, subagents
skills/git/             Git workflows
skills/testing/         Test writing
skills/debugging/       Systematic debugging
skills/security/        Security review + hooks
```

### Subagents (global)
```
subagents/reviewer.md   Code review
subagents/tester.md     Test writing
subagents/git-ops.md    Git operations (haiku model)
subagents/security.md   Security analysis
```

### Commands (global)
```
commands/commit.md      /commit
commands/push.md        /push
commands/pr.md          /pr
commands/ship.md        /ship
commands/review.md      /review
commands/test.md        /test
```

### Rules (project-level)
```
rules/base-conventions.md   Code style, naming, structure
rules/security.md           Security practices
rules/testing.md            Test standards
```

### Languages (project-level — detected automatically)
```
languages/python/           conventions, testing, database
languages/nodejs/           conventions, testing
languages/typescript/       conventions, testing
languages/go/               conventions, testing
languages/cpp/              conventions, testing
languages/java/             conventions
```

### Templates (project-level)
```
templates/AGENTS.md                     Copilot + Gemini context
templates/GEMINI.md                     Gemini CLI context
templates/.github/copilot-instructions.md   GitHub Copilot customization
```