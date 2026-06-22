# Installation Profiles

Two profiles balance context budget against completeness. **CORE is the default.**

---

## CORE (Default)

High-signal, low-token footprint. Install this unless you know you need FULL.

| Category | Included |
|----------|---------|
| **Skills** | `extend-agent`, `git`, `testing`, `debugging`, `security`, `strategic-compact` (17 total in kit) |
| **Rules** | `base-conventions`, `security`, `testing` (7 total in kit — 4 path-scoped) |
| **Commands** | `build-fix`, `commit`, `push`, `pr`, `ship`, `test` (6 total in kit) |
| **Subagents** | `reviewer`, `tester`, `git-ops`, `security` (15 total in kit — 4 with memory: user) |
| **Language pack** | Detected language only (e.g., `python/conventions.md` + `python/testing.md` + `python/database.md` + `python/async.md`) |

**What CORE excludes (by design):**
- `planning`, `api-design`, `implement-jira-ticket` and other specialized skills
- `git-workflow`, `performance` (path-scoped), `infrastructure` (path-scoped), `patterns` (path-scoped) rules
- `architect`, `planner`, `db-expert`, `doc-writer`, `refactorer` subagents
- Note: TDD is now a workflow in `testing/workflows/tdd.md`, spec-interview is in `planning/workflows/spec-interview.md`, security-review workflows are in `security/workflows/`

---

## FULL (Opt-in)

Everything in CORE, plus:

| Category | Added |
|----------|-------|
| **Skills** | `planning`, `api-design`, `implement-jira-ticket`, `design-doc-mermaid`, `web-deep-search`, `verification-loop`, `pr-review` |
| **Rules** | `git-workflow`, `performance` (path-scoped), `infrastructure` (path-scoped), `patterns` (path-scoped) |
| **Commands** | None — all commands now in CORE |
| **Subagents** | `architect`, `planner`, `db-expert`, `doc-writer`, `refactorer`, `tdd-guide`, `web-research` |

### [ADVANCED] — Autonomous Agent Pipeline

| Category | Included |
|----------|---------|
| **Skills** | `ralph-orchestrator` (with 4 workflows: full-pipeline, execute-only, from-prd, check-status) |
| **Agents** | `ralph-coder`, `ralph-tester` |
| **Commands** | `ralph-convert-prd` |

Ralph orchestrates complete feature development: spec-interview -> PRD -> atomic user stories -> parallel batch execution via coder/tester subagents with worktree isolation. See `skills/ralph-orchestrator/SKILL.md` for full documentation.

---

## Opt-in Enhancements

Neither profile installs these by default. Enable explicitly when needed.

### [OPT-IN] — Session, Productivity, and Research Hooks

| Category | Included |
|----------|---------|
| **Session Hooks** | `session-start.sh`, `session-end.sh`, `pre-compact.sh` |
| **Productivity Hooks** | `concise-mode.sh`, `concise-toggle.sh`, `delegate-first.sh`, `suggest-compact.sh` |
| **Scripts** | `statusline.sh` |
| **Commands** | `concise` |
| **Templates** | `settings-template.json` |

### Security Hooks

Blocks destructive shell commands and protects sensitive file paths. Source in `hooks/`.

```bash
# Enable during install:
scripts/check-kit-updates.sh --profile core --hooks > /tmp/kit-plan.json
scripts/install-kit.sh --plan /tmp/kit-plan.json

# Or add --hooks to any profile install
```

### Skill Routing

Generates a compact routing table (~200 tokens) that teaches the agent which skill to
load for a given task. Useful when you use multiple FULL skills regularly.

```bash
# Preview:
python3 scripts/compile-claude-routing.py --dry-run

# Write to global context (~/.claude/CLAUDE_ROUTING.md):
python3 scripts/compile-claude-routing.py --target global --profile full

# Write into current project's CLAUDE.md:
python3 scripts/compile-claude-routing.py --target project --project-dir .
```

Why opt-in? Context budget. CORE keeps every token free for actual work. Enable routing
only when the table's auto-routing value exceeds its context cost.

---

## Tagged Opt-ins

Add with `--tags python,stack` during install. These are independent of CORE/FULL.

### [PYTHON] — Python Language Pack

| Category | Included |
|----------|---------|
| **Language Files** | `conventions.md`, `testing.md`, `database.md`, `async.md` (in `languages/python/`) |
| **Agents** | `python-debugger`, `fastapi-specialist` (in `languages/python/agents/`) |

### [STACK] — Infrastructure Pack

| Category | Included |
|----------|---------|
| **Skills** | `postgres-patterns`, `docker-patterns`, `deployment-patterns` |
| **Agents** | `aws-specialist`, `k8s-specialist` |

---

## Precedence Rules

1. **Project-level overrides global.** Files in `.claude/rules/`, `.cursor/rules/`, or `.kiro/steering/` take precedence over `~/.claude/` equivalents on name collision.
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

# CORE + security hooks (opt-in):
scripts/check-kit-updates.sh --profile core --hooks | scripts/install-kit.sh

# FULL + security hooks:
scripts/check-kit-updates.sh --profile full --hooks | scripts/install-kit.sh

# Cursor-only install:
scripts/check-kit-updates.sh --profile core --platform cursor | scripts/install-kit.sh

# Both Claude + Cursor:
scripts/check-kit-updates.sh --profile full --platform both | scripts/install-kit.sh

# Dry run (preview without writing):
scripts/check-kit-updates.sh --profile core | scripts/install-kit.sh --dry-run

# Enable skill routing (FULL-only, opt-in):
python3 scripts/compile-claude-routing.py --target global --profile full
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