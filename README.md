# Agent Runtime Kit

> A universal, production-ready configuration kit for AI agents. Works with Claude Code, Cursor, GitHub Copilot, and Gemini CLI.

---

## What This Is

A curated collection of skills, rules, subagents, commands, and language conventions that you clone once and use everywhere.

**Philosophy:**
- **Universal** — works for Claude Code, Cursor, Copilot, and Gemini
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
| Skills | extend-agent, git, testing, debugging, security | + planning, tdd, api-design, spec-interview, implement-jira-ticket |
| Rules | base-conventions, security, testing | + git-workflow, performance, infrastructure |
| Commands | commit, push, pr, ship, review, test | + debug, refactor, spec-interview, generate-prd, implement-jira-ticket |
| Subagents | reviewer, tester, git-ops, security | + architect, planner, db-expert, doc-writer, refactorer |

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
│   ├── security/           # Security reviews + hooks                          [CORE]
│   ├── testing/            # Test writing                                      [CORE]
│   ├── planning/           # Project planning hierarchy                        [FULL]
│   ├── tdd/                # Test-driven development                           [FULL]
│   ├── api-design/         # API design patterns                               [FULL]
│   ├── spec-interview/     # Requirements gathering                            [FULL]
│   └── implement-jira-ticket/ # Jira ticket implementation                    [FULL]
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
│   └── refactorer.md       # Code refactoring                                  [FULL]
│
├── commands/               # Slash commands (Claude Code)
│   ├── commit.md           # /commit                                           [CORE]
│   ├── push.md             # /push                                             [CORE]
│   ├── pr.md               # /pr                                               [CORE]
│   ├── ship.md             # /ship (commit + push + PR)                        [CORE]
│   ├── review.md           # /review                                           [CORE]
│   ├── test.md             # /test                                             [CORE]
│   ├── debug.md            # /debug [issue]                                    [FULL]
│   ├── refactor.md         # /refactor [target]                                [FULL]
│   ├── spec-interview.md   # /spec-interview                                   [FULL]
│   ├── generate-prd.md     # /generate-prd                                     [FULL]
│   └── implement-jira-ticket.md # /implement-jira-ticket                       [FULL]
│
├── rules/                  # Project-level conventions
│   ├── base-conventions.md                                                     [CORE]
│   ├── security.md                                                             [CORE]
│   ├── testing.md                                                              [CORE]
│   ├── git-workflow.md                                                         [FULL]
│   ├── performance.md                                                          [FULL]
│   └── infrastructure.md                                                       [FULL]
│
├── languages/              # Language-specific conventions (detected auto)
│   ├── python/             # conventions, testing, database
│   ├── nodejs/             # conventions, testing
│   ├── typescript/         # conventions, testing
│   ├── go/                 # conventions, testing
│   ├── cpp/                # conventions, testing
│   └── java/               # conventions
│
├── templates/              # Source templates for AI agent generation
│   ├── AGENTS.md           # Copilot + Gemini context file template
│   ├── GEMINI.md           # Gemini CLI project context template
│   └── .github/
│       └── copilot-instructions.md
│
├── mcp/
│   ├── recommended-servers.json  # OPT-IN MCP server configs
│   └── SETUP.md                  # Setup guide per platform
│
├── hooks/                        # OPT-IN security hooks (--hooks flag)
│   ├── block-dangerous-commands.sh  # Block destructive shell commands
│   ├── block-dangerous-bash.sh      # Compatibility alias for above
│   └── protect-files.sh             # Block writes to protected paths
│
├── routing/
│   └── skill-rules.json          # Routing rules for compile-claude-routing.py
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
cp -r skills/extend-agent skills/git skills/testing skills/debugging skills/security ~/.claude/skills/
cp subagents/reviewer.md subagents/tester.md subagents/git-ops.md subagents/security.md ~/.claude/agents/
cp commands/commit.md commands/push.md commands/pr.md commands/ship.md \
   commands/review.md commands/test.md ~/.claude/commands/

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
| `extend-agent/` | CORE | Create skills, commands, hooks, or subagents |
| `debugging/` | CORE | Systematic bug investigation |
| `git/` | CORE | Commit, push, PR workflows |
| `security/` | CORE | Security review + blocking hooks |
| `testing/` | CORE | Test strategy and writing |
| `planning/` | FULL | Hierarchical project planning |
| `tdd/` | FULL | Red-green-refactor cycle |
| `api-design/` | FULL | REST API design patterns |
| `spec-interview/` | FULL | Requirements gathering |
| `implement-jira-ticket/` | FULL | End-to-end Jira ticket implementation |

---

## Subagents Reference

| Subagent | Profile | Model | Use For |
|----------|---------|-------|---------|
| `reviewer` | CORE | sonnet | Code review |
| `tester` | CORE | sonnet | Writing tests |
| `git-ops` | CORE | haiku | Git operations |
| `security` | CORE | sonnet | Security analysis |
| `architect` | FULL | opus | Architecture decisions |
| `planner` | FULL | opus | Task planning |
| `db-expert` | FULL | sonnet | Database design |
| `doc-writer` | FULL | sonnet | Documentation |
| `refactorer` | FULL | sonnet | Refactoring |

**Claude Code**: invoked automatically by description or by user request.
**Cursor**: invoke explicitly with `/subagent-name` (e.g., `/reviewer check this PR`).

---

## Commands Reference

| Command | Profile | Description |
|---------|---------|-------------|
| `/commit` | CORE | Stage and commit with conventional commit format |
| `/push` | CORE | Push current branch to remote |
| `/pr` | CORE | Create pull request with template |
| `/ship` | CORE | Full workflow: commit + push + PR |
| `/review` | CORE | Code review of recent changes |
| `/test` | CORE | Auto-detect and run the project's test suite |
| `/debug [issue]` | FULL | Systematic root-cause analysis |
| `/refactor [target]` | FULL | Improve code quality without changing behavior |
| `/spec-interview` | FULL | Interactive requirements gathering |
| `/generate-prd` | FULL | Generate product requirements document |
| `/implement-jira-ticket` | FULL | Implement a Jira ticket end-to-end |

---

## Project Overrides

Project-level files always win over global defaults:

| Platform | Location | Purpose |
|----------|----------|---------|
| Claude Code | `.claude/rules/*.md` | Project-specific rules |
| Cursor | `.cursor/rules/*.mdc` | Project-specific rules |
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
| `mermaid` | Diagram rendering |
| `sentry` | Error tracking |
| `groundcover` | Cloud-native observability |
| `filesystem` | File access outside project (use sparingly) |

---

## Opt-in Enhancements (FULL-only)

These features are never installed by default. Enable them explicitly when you need them.

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

Hooks that block destructive shell commands and protect sensitive file paths. Source lives in `hooks/`.

```bash
# Include hooks in your install plan:
scripts/check-kit-updates.sh --profile core --hooks > /tmp/kit-plan.json
scripts/install-kit.sh --plan /tmp/kit-plan.json

# Or install manually:
mkdir -p ~/.claude/hooks
cp hooks/block-dangerous-commands.sh hooks/block-dangerous-bash.sh hooks/protect-files.sh ~/.claude/hooks/
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
    "matcher": "Write|Edit",
    "hooks": [{"type": "command", "command": "~/.claude/hooks/protect-files.sh", "timeout": 10000}]
  }
]
```

Configure protected paths in `~/.claude/protected-paths.txt` (one prefix per line).

---

## Contributing

1. Fork this repo
2. Add your skill/subagent/command to the appropriate directory
3. Follow the patterns in existing files (XML tags, YAML frontmatter)
4. Mark new items `[CORE]` or `[FULL]` in your PR description
5. Submit a PR

Use `/spec-interview` to gather requirements before building anything significant.

---

**Version:** 2.2.0
**Compatible With:** Claude Code (Claude 4.5+), Cursor 0.40+, GitHub Copilot, Gemini CLI
**Last Updated:** 2026-02-27