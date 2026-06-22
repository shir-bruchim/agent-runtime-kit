# Agent Runtime Kit

> A universal, production-ready configuration kit for AI agents. Works with Claude Code, Cursor, GitHub Copilot, Gemini CLI, and Kiro.

---

## What This Is

A curated collection of skills, rules, subagents, commands, and language conventions that you clone once and use everywhere.

**Philosophy:**
- **Universal** — works for Claude Code, Cursor, Copilot, Gemini, and Kiro
- **Self-configuring** — the agent reads `AGENT-SETUP.md` and installs itself
- **CORE by default** — small, high-signal. Opt into FULL for the full toolkit
- **Self-extending** — meta-skills let you create new skills from within

---

## Quick Start

Paste this URL into your AI agent's chat:

```
https://github.com/shir-bruchim/agent-runtime-kit
```

The agent reads the README, fetches `AGENT-SETUP.md`, detects your platform, selects the CORE profile, and installs into `~/.claude/` (global). No cloning. No manual steps.

**Or use the scripts directly (after cloning):**

```bash
# CORE install — global, auto-detect platform (recommended):
scripts/check-kit-updates.sh --profile core > /tmp/kit-plan.json
scripts/install-kit.sh --plan /tmp/kit-plan.json

# FULL install:
scripts/check-kit-updates.sh --profile full > /tmp/kit-plan.json
scripts/install-kit.sh --plan /tmp/kit-plan.json

# Cursor only:
scripts/check-kit-updates.sh --profile core --platform cursor > /tmp/kit-plan.json
scripts/install-kit.sh --plan /tmp/kit-plan.json
```

See `PROFILES.md` for profile details and per-file decision (SKIP/MERGE) instructions.

---

## Profiles

| | CORE (default) | FULL |
|-|----------------|------|
| Skills | extend-agent, git, testing, debugging, security, strategic-compact | + planning, api-design, implement-jira-ticket, design-doc-mermaid, web-deep-search, verification-loop, pr-review |
| Rules | base-conventions, security, testing | + git-workflow, performance(path-scoped), infrastructure(path-scoped), patterns(path-scoped) |
| Commands | commit, push, pr, ship, test, build-fix | (none — commands now in CORE) |
| Subagents | reviewer, tester, git-ops, security | + architect, planner, db-expert, doc-writer, refactorer, tdd-guide, web-research, aws-specialist, k8s-specialist |

**Tagged opt-ins** (add with `--tags`):

| Tag | What It Adds |
|-----|-------------|
| `[PYTHON]` | `languages/python/` — conventions, testing, database, async language files + python-debugger, fastapi-specialist agents |
| `[STACK]` | postgres-patterns, docker-patterns, deployment-patterns skills + aws-specialist, k8s-specialist agents |
| `[ADVANCED]` | ralph-orchestrator skill + ralph-coder, ralph-tester agents — autonomous PRD-to-code pipeline |
| `[OPT-IN]` | Session hooks, concise mode, delegate-first, statusline, settings template |

CORE is ~60% smaller than FULL. Use CORE unless you need the extras. See `PROFILES.md`.

---

## What's Inside

```
agent-runtime-kit/
├── AGENT-SETUP.md          # AI self-configuration instructions
├── PROFILES.md             # CORE vs FULL profile definitions
├── README.md               # This file
│
├── skills/                 # Reusable skill modules (SKILL.md format)
│   ├── extend-agent/       # Meta: create skills, commands, hooks, subagents  [CORE]
│   ├── debugging/          # Systematic debugging                              [CORE]
│   ├── git/                # Git workflows                                     [CORE]
│   ├── security/           # Security reviews + hooks + workflows              [CORE]
│   ├── testing/            # Test writing + TDD workflow                       [CORE]
│   ├── strategic-compact/  # Context management + /compact guidance            [CORE]
│   ├── planning/           # Project planning + spec-interview workflow        [FULL]
│   ├── api-design/         # API design patterns                               [FULL]
│   ├── implement-jira-ticket/ # Jira ticket implementation                    [FULL]
│   ├── design-doc-mermaid/ # Mermaid diagrams + design documents              [FULL]
│   ├── web-deep-search/    # Web research via WebSearch + WebFetch (3 modes)  [FULL]
│   ├── verification-loop/  # Multi-phase verification system                  [FULL]
│   └── pr-review/          # Structured PR review (5 dimensions)              [FULL]
│   ├── postgres-patterns/  # PostgreSQL schema, indexing, optimization        [STACK]
│   ├── docker-patterns/    # Docker builds, Compose, security                [STACK]
│   ├── deployment-patterns/# CI/CD, health checks, rollback                  [STACK]
│   └── ralph-orchestrator/ # Autonomous PRD-to-code pipeline                 [ADVANCED]
│       └── workflows/      # full-pipeline, execute-only, from-prd, check-status
│
├── languages/              # Language-specific packs (tagged opt-in)
│   └── python/
│       ├── conventions.md       # Framework selection, project structure  [PYTHON]
│       ├── testing.md           # pytest, fixtures, mocking              [PYTHON]
│       ├── database.md          # SQLAlchemy, Alembic, connection pools  [PYTHON]
│       ├── async.md             # asyncio, concurrent patterns           [PYTHON]
│       └── agents/
│           ├── python-debugger.md   # Hypothesis-driven debugging        [PYTHON]
│           └── fastapi-specialist.md # FastAPI patterns, DI, Pydantic v2 [PYTHON]
│
├── subagents/              # Specialized AI subagents
│   ├── reviewer.md         # Code review                                       [CORE]
│   ├── tester.md           # Test writing                                      [CORE]
│   ├── git-ops.md          # Git operations                                    [CORE]
│   ├── security.md         # Security analysis                                 [CORE]
│   ├── architect.md        # Architecture decisions                            [FULL]
│   ├── planner.md          # Task planning                                     [FULL]
│   ├── db-expert.md        # Database design                                   [FULL]
│   ├── doc-writer.md       # Documentation                                     [FULL]
│   ├── refactorer.md       # Code refactoring                                  [FULL]
│   ├── tdd-guide.md        # Test-driven development                           [FULL]
│   ├── web-research.md       # Web research via WebSearch + WebFetch          [FULL]
│   ├── aws-specialist.md  # AWS Lambda, SQS, S3, IAM                         [STACK]
│   ├── k8s-specialist.md  # Kubernetes, Helm, HPA, RBAC                      [STACK]
│   ├── ralph-coder.md     # Ralph: implements production code per story       [ADVANCED]
│   └── ralph-tester.md    # Ralph: writes tests + verification per story      [ADVANCED]
│
├── commands/               # Slash commands (Claude Code)
│   ├── build-fix.md        # /build-fix                                        [CORE]
│   ├── commit.md           # /commit                                           [CORE]
│   ├── pr.md               # /pr                                               [CORE]
│   ├── push.md             # /push                                             [CORE]
│   ├── ship.md             # /ship (commit + push + PR + auto-review)          [CORE]
│   └── test.md             # /test                                             [CORE]
│
├── rules/                  # Project-level conventions
│   ├── base-conventions.md                                                     [CORE]
│   ├── security.md                                                             [CORE]
│   ├── testing.md          # Path-scoped to test/ directories                 [CORE]
│   ├── git-workflow.md                                                         [FULL]
│   ├── performance.md      # Path-scoped                                      [FULL]
│   ├── infrastructure.md   # Path-scoped                                      [FULL]
│   └── patterns.md         # Path-scoped, common design patterns               [FULL]
│
├── templates/              # Source templates for AI agent generation
│   ├── AGENTS.md           # Copilot + Gemini context file template
│   ├── GEMINI.md           # Gemini CLI project context template
│   ├── kiro-steering-conventions.md  # Kiro steering file template
│   ├── settings-template.json  # Recommended Claude Code settings            [OPT-IN]
│   └── .github/
│       └── copilot-instructions.md
│
├── mcp/
│   ├── recommended-servers.json  # OPT-IN MCP server configs
│   └── SETUP.md                  # Setup guide per platform
│
├── hooks/                        # OPT-IN hooks (--hooks flag)
│   ├── block-dangerous-commands.sh  # Block destructive shell commands          [SECURITY]
│   ├── block-dangerous-bash.sh      # Compatibility alias for above             [SECURITY]
│   ├── block-dangerous-read.sh      # Block reads of secrets, keys, credentials [SECURITY]
│   ├── protect-files.sh             # Block writes to protected paths           [SECURITY]
│   ├── session-start.sh             # Load previous session context             [OPT-IN]
│   ├── session-end.sh               # Save session summary on exit              [OPT-IN]
│   ├── pre-compact.sh               # Log compaction events                     [OPT-IN]
│   ├── suggest-compact.sh           # Suggest /compact at tool-call threshold   [OPT-IN]
│   ├── concise-mode.sh              # Brief response style (UserPromptSubmit)   [OPT-IN]
│   ├── concise-toggle.sh            # Toggle concise mode on/off                [OPT-IN]
│   └── delegate-first.sh            # Remind to use subagents first             [OPT-IN]
│
├── routing/
│   └── skill-rules.json          # Routing rules for compile-claude-routing.py
│
├── scripts/
│   ├── check-kit-updates.sh      # Generate install plan
│   ├── install-kit.sh            # Execute install plan
│   ├── compile-claude-routing.py  # Generate skill routing table
│   ├── generate-cursor-mdc.sh    # Generate Cursor .mdc files
│   └── statusline.sh             # Terminal status bar (model, branch, context)  [OPT-IN]
│
└── docs/
    ├── CUSTOMIZATION.md          # How to extend the kit
    ├── BEST-PRACTICES.md         # Design principles
    └── TROUBLESHOOTING.md        # Common issues and fixes
```

---

## For Humans: Manual Installation

### Claude Code

```bash
# Global install (recommended — available in all projects)
cp -r skills/extend-agent skills/git skills/testing skills/debugging skills/security skills/strategic-compact ~/.claude/skills/
cp subagents/reviewer.md subagents/tester.md subagents/git-ops.md subagents/security.md ~/.claude/agents/
cp commands/commit.md commands/push.md commands/pr.md commands/ship.md \
   commands/build-fix.md commands/test.md ~/.claude/commands/

# Project-level rules (CORE)
mkdir -p .claude/rules
cp rules/base-conventions.md rules/security.md rules/testing.md .claude/rules/
cp languages/python/*.md .claude/rules/  # or typescript, nodejs, go, etc.
```

### Cursor

Generate `.mdc` files automatically:

```bash
# After cloning:
bash scripts/generate-cursor-mdc.sh --kit-dir . --dest-dir ~/.cursor/rules --profile core
```

Or install project-level:

```bash
bash scripts/generate-cursor-mdc.sh --kit-dir . --dest-dir .cursor/rules --profile core
```

### Kiro

Kiro uses steering files (`.kiro/steering/*.md`) for project conventions and `.kiro/settings/mcp.json` for MCP servers.

```bash
# Project-level steering (recommended):
mkdir -p .kiro/steering
cp templates/kiro-steering-conventions.md .kiro/steering/conventions.md

# Rules as steering files:
cp rules/base-conventions.md .kiro/steering/base-conventions.md
cp rules/security.md .kiro/steering/security.md
cp rules/testing.md .kiro/steering/testing.md
```

Kiro steering files support frontmatter for inclusion control:
- `inclusion: auto` — always included (default)
- `inclusion: fileMatch` + `fileMatchPattern` — included when matching files are open
- `inclusion: manual` — included via `#` context key in chat

---

## For Agents: Automatic Installation

Read `AGENT-SETUP.md`. It contains step-by-step instructions for:

1. Cloning to `/tmp` (token-efficient, auto-cleaned after install)
2. Running `check-kit-updates.sh --profile core` to generate a plan
3. Reviewing the plan (SKIP/MERGE any file you want to keep)
4. Running `install-kit.sh` from the plan

---

## Skills Reference

| Skill | Profile | What It Does |
|-------|---------|-------------|
| `extend-agent/` | CORE | Create skills, commands, hooks, or subagents — includes cross-platform frontmatter guide |
| `debugging/` | CORE | Systematic bug investigation |
| `git/` | CORE | Commit, push, PR workflows |
| `security/` | CORE | Security review + blocking hooks + deep-review and setup-hooks workflows |
| `testing/` | CORE | Test strategy and writing + TDD workflow + LocalStack integration references |
| `strategic-compact/` | CORE | Context management + strategic /compact guidance |
| `planning/` | FULL | Hierarchical project planning + spec-interview workflow |
| `api-design/` | FULL | REST API design patterns |
| `implement-jira-ticket/` | FULL | End-to-end Jira ticket implementation |
| `design-doc-mermaid/` | FULL | Mermaid diagrams and design documents |
| `web-deep-search/` | FULL | Web research via built-in WebSearch + WebFetch (3 depth modes) |
| `verification-loop/` | FULL | Multi-phase verification system |
| `pr-review/` | FULL | Structured PR review across 5 dimensions |
| `postgres-patterns/` | STACK | PostgreSQL schema, indexing, query optimization |
| `docker-patterns/` | STACK | Docker builds, Compose, container security |
| `deployment-patterns/` | STACK | CI/CD, health checks, rollback strategies |
| `ralph-orchestrator/` | ADVANCED | Autonomous PRD-to-code pipeline with parallel batch execution |

---

## Subagents Reference

| Subagent | Profile | Model | Memory | Preloaded Skills | Use For |
|----------|---------|-------|--------|------------------|---------|
| `reviewer` | CORE | sonnet | user | git, testing, security | Code review |
| `tester` | CORE | sonnet | user | testing | Writing tests |
| `git-ops` | CORE | haiku | - | - | Git operations |
| `security` | CORE | sonnet | user | security | Security analysis |
| `architect` | FULL | opus | - | - | Architecture decisions |
| `planner` | FULL | opus | - | - | Task planning |
| `db-expert` | FULL | sonnet | user | postgres-patterns | Database design |
| `doc-writer` | FULL | sonnet | - | - | Documentation |
| `refactorer` | FULL | sonnet | - | - | Refactoring |
| `tdd-guide` | FULL | sonnet | - | testing | Test-driven development |
| `web-research` | FULL | sonnet | - | web-deep-search | Web research via WebSearch + WebFetch |
| `aws-specialist` | STACK | sonnet | - | - | AWS infrastructure (Lambda, SQS, S3) |
| `k8s-specialist` | STACK | sonnet | - | - | Kubernetes (Deployments, Helm, HPA) |
| `python-debugger` | PYTHON | sonnet | - | - | Hypothesis-driven Python debugging |
| `fastapi-specialist` | PYTHON | sonnet | - | - | FastAPI patterns, DI, Pydantic v2 |
| `ralph-coder` | ADVANCED | sonnet | - | - | Implements production code per user story |
| `ralph-tester` | ADVANCED | sonnet | - | - | Writes tests + runs verification per story |

**Claude Code**: invoked automatically by description or by user request.
**Cursor**: invoke explicitly with `/subagent-name` (e.g., `/reviewer check this PR`).

---

## Commands Reference

| Command | Profile | Description |
|---------|---------|-------------|
| `/build-fix` | CORE | Incrementally fix build errors |
| `/commit` | CORE | Stage and commit with conventional commit format |
| `/pr` | CORE | Create pull request with template |
| `/push` | CORE | Push current branch to remote |
| `/ship` | CORE | Full workflow: commit + push + PR + auto-review |
| `/test` | CORE | Auto-detect and run the project's test suite |

---

## Project Overrides

Project-level files always win over global defaults:

| Platform | Location | Purpose |
|----------|----------|---------|
| Claude Code | `.claude/rules/*.md` | Project-specific rules |
| Cursor | `.cursor/rules/*.mdc` | Project-specific rules |
| Kiro | `.kiro/steering/*.md` | Project-specific steering files |
| All agents | `AGENTS.md` | Copilot + Gemini context |
| Gemini CLI | `GEMINI.md` | Gemini project context |
| GitHub Copilot | `.github/copilot-instructions.md` | Copilot behavior |

Templates for these files are in `templates/` and installed project-scope during setup.

---

## MCP Servers (Opt-in)

MCP is **never installed by default**. See `mcp/SETUP.md` for the full list and setup instructions.

Quick reference — supported servers:

| Server | What It Enables |
|--------|----------------|
| `github` | PRs, issues, code search (use docker/remote, not deprecated npm) |
| `atlassian` | Jira + Confluence (remote SSE, no local install) |
| `postgres` | DB introspection (read-only) |
| `websearch` | Web search via Tavily |
| `context7` | Up-to-date library docs and code examples (by Upstash) |
| `mermaid` | Diagram rendering |
| `sentry` | Error tracking |
| `groundcover` | Cloud-native observability |
| `filesystem` | File access outside project (use sparingly) |

---

## Opt-in Enhancements

These features are never installed by default. Enable them explicitly when you need them.

### Session Hooks (OPT-IN)

Session continuity across conversations. Saves summaries on exit, loads context on start, logs compaction events.

```bash
# Install session hooks:
cp hooks/session-start.sh hooks/session-end.sh hooks/pre-compact.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/session-*.sh ~/.claude/hooks/pre-compact.sh
```

See `templates/settings-template.json` for the hooks registration JSON.

### Concise Mode (OPT-IN)

Toggle brief 1-3 sentence responses. Useful for rapid iteration.

```bash
cp hooks/concise-mode.sh hooks/concise-toggle.sh ~/.claude/hooks/
cp commands/concise.md ~/.claude/commands/
chmod +x ~/.claude/hooks/concise-*.sh
# Then use: /concise on | /concise off
```

### Delegate-First (OPT-IN)

Reminds the agent to check for specialized subagents before starting work.

```bash
cp hooks/delegate-first.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/delegate-first.sh
```

### Status Line (OPT-IN)

Terminal status bar showing model, branch, context usage with progress bar.

```bash
cp scripts/statusline.sh ~/.claude/scripts/
chmod +x ~/.claude/scripts/statusline.sh
# Add to settings.json: "statusLine": {"type": "command", "command": "~/.claude/scripts/statusline.sh"}
```

### Skill Routing (FULL-only)

Generates a compact routing table that teaches the agent which skill to load for a given task. Adds ~200 tokens of context — worth it once you use multiple skills regularly.

```bash
# Preview what would be generated:
python3 scripts/compile-claude-routing.py --dry-run

# Write to ~/.claude/CLAUDE_ROUTING.md (global):
python3 scripts/compile-claude-routing.py --target global --profile full

# Or append to the current project's CLAUDE.md:
python3 scripts/compile-claude-routing.py --target project --project-dir .
```

The output is delimited and idempotent — re-running replaces the previous block.

### Security Hooks (OPT-IN)

Hooks that block destructive shell commands, prevent reading secrets, and protect sensitive file paths. Source lives in `hooks/`.

```bash
# Include hooks in your install plan:
scripts/check-kit-updates.sh --profile core --hooks > /tmp/kit-plan.json
scripts/install-kit.sh --plan /tmp/kit-plan.json

# Or install manually:
mkdir -p ~/.claude/hooks
cp hooks/block-dangerous-commands.sh hooks/block-dangerous-bash.sh \
   hooks/block-dangerous-read.sh hooks/protect-files.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh
```

Then register in `~/.claude/settings.json`:
```json
"PreToolUse": [
  {
    "matcher": "Bash",
    "hooks": [{"type": "command", "command": "~/.claude/hooks/block-dangerous-commands.sh", "timeout": 10000}]
  },
  {
    "matcher": "Read",
    "hooks": [{"type": "command", "command": "~/.claude/hooks/block-dangerous-read.sh", "timeout": 10000}]
  },
  {
    "matcher": "Write|Edit|NotebookEdit",
    "hooks": [{"type": "command", "command": "~/.claude/hooks/protect-files.sh", "timeout": 10000}]
  }
]
```

Configure protected paths in `~/.claude/protected-paths.txt` (one prefix per line).
Configure blocked read paths in `~/.claude/blocked-read-paths.txt` (one path per line).

---

## Contributing

1. Fork this repo
2. Add your skill/subagent/command to the appropriate directory
3. Follow the patterns in existing files (XML tags, YAML frontmatter)
4. Mark new items `[CORE]` or `[FULL]` in your PR description
5. Submit a PR

Use `/spec-interview` to gather requirements before building anything significant.

---

**Version:** 3.1.0
**Compatible With:** Claude Code (Claude 4.5+), Cursor 0.40+, GitHub Copilot, Gemini CLI, Kiro
**Last Updated:** 2026-03-16