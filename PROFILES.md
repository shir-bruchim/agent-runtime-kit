# Installation Profiles

Two profiles balance context budget against completeness. **CORE is the default.**

---

## CORE (Default)

High-signal, low-token footprint. Install this unless you know you need FULL.

| Category | Included |
|----------|---------|
| **Skills** | `extend-agent`, `git`, `testing`, `debugging`, `security` |
| **Rules** | `base-conventions`, `security`, `testing` |
| **Commands** | `commit`, `push`, `pr`, `ship`, `review`, `test` |
| **Subagents** | `reviewer`, `tester`, `git-ops`, `security` |
| **Language pack** | Detected language only (e.g., `typescript/conventions.md` + `typescript/testing.md`) |

**What CORE excludes (by design):**
- `planning`, `tdd`, `api-design`, `spec-interview`, `implement-jira-ticket` skills
- `git-workflow`, `performance`, `infrastructure` rules (use if your project needs them)
- `architect`, `planner`, `db-expert`, `doc-writer`, `refactorer` subagents
- `debug`, `refactor`, `spec-interview`, `generate-prd`, `implement-jira-ticket` commands

---

## FULL (Opt-in)

Everything in CORE, plus:

| Category | Added |
|----------|-------|
| **Skills** | `planning`, `tdd`, `api-design`, `spec-interview`, `implement-jira-ticket` |
| **Rules** | `git-workflow`, `performance`, `infrastructure` |
| **Commands** | `debug`, `refactor`, `spec-interview`, `generate-prd`, `implement-jira-ticket` |
| **Subagents** | `architect`, `planner`, `db-expert`, `doc-writer`, `refactorer` |

---

## Precedence Rules

1. **Project-level overrides global.** Files in `.claude/rules/` or `.cursor/rules/` take precedence over `~/.claude/` equivalents on name collision.
2. **Specific overrides generic.** A project's `typescript-conventions.md` beats a global one.
3. **No duplication.** If a convention is in `CLAUDE.md` or `.cursorrules`, do NOT also install it as a rule file. Rule files are for content not already in the main config.
4. **Skills are routers; workflows hold detail.** Keep `SKILL.md` lean — detailed steps belong in `workflows/` subdirectories.
5. **MCP is always opt-in.** Nothing in MCP is installed by either profile; see `mcp/SETUP.md`.

---

## Install Commands

```bash
# CORE install (global, auto-detect platform):
scripts/check-kit-updates.sh --profile core | scripts/install-kit.sh

# FULL install:
scripts/check-kit-updates.sh --profile full | scripts/install-kit.sh

# Cursor-only install:
scripts/check-kit-updates.sh --profile core --platform cursor | scripts/install-kit.sh

# Both Claude + Cursor:
scripts/check-kit-updates.sh --profile full --platform both | scripts/install-kit.sh

# Dry run (preview without writing):
scripts/check-kit-updates.sh --profile core | scripts/install-kit.sh --dry-run
```

---

## Per-File Decisions

When the installer generates a plan JSON, every file has an `action` field:

| Action | Meaning |
|--------|---------|
| `NEW` | File doesn't exist at destination — will install |
| `IDENTICAL` | File matches kit version — will skip |
| `CHANGED` | File differs — installer replaces by default |
| `SKIP` | User-set: skip this file |
| `MERGE` | User-set: installer leaves file, user merges manually |

To keep or merge a specific file instead of replacing it, edit the plan JSON before running install:

```bash
# Generate plan
scripts/check-kit-updates.sh --profile core > /tmp/kit-plan.json

# Edit: change "action":"CHANGED" to "action":"SKIP" for files you want to keep
$EDITOR /tmp/kit-plan.json

# Install with your choices applied
scripts/install-kit.sh --plan /tmp/kit-plan.json
```