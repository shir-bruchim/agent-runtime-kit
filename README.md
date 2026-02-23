# 🤖 Agent Runtime Kit

> A universal, production-ready configuration kit for AI agents. Works with Claude Code, Cursor, and any AI that can read files.

---

## What This Is

A curated collection of skills, rules, subagents, commands, and language conventions that you clone once and use everywhere.

**Philosophy:**
- **Universal** — one file, works for both Claude Code and Cursor
- **Self-configuring** — the agent reads `AGENT-SETUP.md` and installs itself
- **Production-ready** — battle-tested patterns from real projects
- **Self-extending** — meta-skills let you create new skills from within

---

## Quick Start

Paste this URL into your AI agent's chat:

```
https://github.com/shir-bruchim/agent-runtime-kit
```

That's it. The agent reads the README, fetches `AGENT-SETUP.md`, detects what platform it's running on (Claude Code or Cursor), detects your project language, checks for any existing files that would conflict, and installs everything in the right places.

No cloning. No manual steps.

---

## What's Inside

```
agent-runtime-kit/
├── AGENT-SETUP.md          # AI self-configuration instructions
├── README.md               # This file
│
├── skills/                 # Reusable skill modules (SKILL.md format)
│   ├── extend-agent/       # Meta: create skills, commands, hooks, subagents
│   ├── planning/           # Project planning hierarchy
│   ├── debugging/          # Systematic debugging
│   ├── git/                # Git workflows
│   ├── security/           # Security reviews + hooks
│   ├── testing/            # Test writing
│   ├── tdd/                # Test-driven development
│   ├── api-design/         # API design patterns
│   └── spec-interview/     # Requirements gathering
│
├── subagents/              # Specialized AI subagents
│   ├── architect.md        # Architecture decisions
│   ├── reviewer.md         # Code review
│   ├── planner.md          # Task planning
│   ├── tester.md           # Test writing
│   ├── git-ops.md          # Git operations
│   ├── security.md         # Security analysis
│   ├── db-expert.md        # Database design
│   ├── doc-writer.md       # Documentation
│   └── refactorer.md       # Code refactoring
│
├── commands/               # Slash commands
│   ├── commit.md           # /commit
│   ├── push.md             # /push
│   ├── pr.md               # /pr
│   ├── ship.md             # /ship (commit + push + PR)
│   ├── review.md           # /review
│   ├── test.md             # /test (auto-detect and run tests)
│   ├── debug.md            # /debug [issue]
│   ├── refactor.md         # /refactor [target]
│   ├── spec-interview.md   # /spec-interview
│   └── generate-prd.md     # /generate-prd
│
├── rules/                  # Project-level conventions
│   ├── base-conventions.md
│   ├── git-workflow.md
│   ├── security.md
│   ├── testing.md
│   ├── performance.md
│   └── infrastructure.md
│
├── languages/              # Language-specific conventions
│   ├── python/             # conventions, testing, database
│   ├── nodejs/             # conventions, testing
│   ├── typescript/         # conventions, testing
│   ├── go/                 # conventions, testing
│   ├── cpp/                # conventions, testing
│   └── java/               # conventions
│
├── mcp/
│   ├── recommended-servers.json  # MCP server list
│   └── SETUP.md                  # Setup guide per platform
│
├── templates/
│   └── full-setup-example.md     # Complete setup walkthrough
│
└── docs/
    ├── CUSTOMIZATION.md          # How to extend the kit
    ├── BEST-PRACTICES.md         # Design principles
    └── TROUBLESHOOTING.md        # Common issues and fixes
```

---

## For Humans: Manual Installation

### Claude Code

Copy the files you want into `~/.claude/` (user-level) or `.claude/` (project-level):

```bash
# Install skills
cp -r skills/* ~/.claude/skills/

# Install subagents
cp -r subagents/* ~/.claude/agents/

# Install commands
cp -r commands/* ~/.claude/commands/

# Install rules (project-level)
mkdir -p .claude/rules
cp rules/* .claude/rules/

# Install language conventions (pick your stack)
cp languages/python/* .claude/rules/
```

### Cursor

Transform skills to `.mdc` format and place in `.cursor/rules/`:

```bash
mkdir -p .cursor/rules

# Each skill's SKILL.md becomes a .mdc file
# See AGENT-SETUP.md § Cursor Installation for the exact transform
```

---

## For Agents: Automatic Installation

Read `AGENT-SETUP.md`. It contains step-by-step instructions for:

1. Detecting your identity (Claude Code vs Cursor)
2. Detecting the project language
3. Transforming and installing the right files
4. Verifying the installation

---

## Skills Reference

| Skill | What It Does | Key Files |
|-------|-------------|-----------|
| `extend-agent/` | Create skills, commands, hooks, or subagents | SKILL.md + references + workflows |
| `planning/` | Hierarchical project planning | SKILL.md + 6 templates + 8 workflows |
| `debugging/` | Systematic bug investigation | SKILL.md |
| `git/` | Commit, push, PR workflows | SKILL.md + 3 workflow files |
| `security/` | Security review + blocking hooks | SKILL.md + 4 hook scripts |
| `testing/` | Test strategy and writing (Python + Node.js examples) | SKILL.md |
| `tdd/` | Red-green-refactor cycle (Python + Node.js examples) | SKILL.md |
| `api-design/` | REST API design (FastAPI + Express examples) | SKILL.md |
| `spec-interview/` | Requirements gathering | SKILL.md + spec template |

### Meta-Skill: `extend-agent/`

One unified skill that creates any extension type:

| Creates | Format | Platform |
|---------|--------|---------|
| Skills | `SKILL.md` | Claude Code |
| Rules | `.mdc` | Cursor |
| Commands | `commands/*.md` | Claude Code |
| Hooks | `hooks.json` entries | Claude Code |
| Subagents | `agents/*.md` | Claude Code + Cursor |

---

## Subagents Reference

Subagents work in **both Claude Code and Cursor**. Both platforms read from `.claude/agents/` (or `.cursor/agents/` for Cursor).

| Subagent | Model | Tools (Claude Code) | Use For |
|----------|-------|---------------------|---------|
| `architect` | opus | Read, Grep, Glob | Architecture decisions |
| `reviewer` | sonnet | Read, Grep, Glob, Bash | Code review |
| `planner` | opus | Read, Grep, Glob | Task planning |
| `tester` | sonnet | Read, Write, Edit, Bash | Writing tests |
| `git-ops` | haiku | Bash, Read | Git operations |
| `security` | sonnet | Read, Grep, Glob, Bash | Security analysis |
| `db-expert` | sonnet | Read, Write, Edit, Bash | Database design |
| `doc-writer` | sonnet | Read, Write, Edit | Documentation |
| `refactorer` | sonnet | Read, Write, Edit, Grep, Glob | Refactoring |

**Claude Code**: invoked automatically by description or by user request.
**Cursor**: invoke explicitly with `/subagent-name` (e.g., `/reviewer check this PR`).

---

## Commands Reference

| Command | Description |
|---------|-------------|
| `/commit` | Stage and commit with conventional commit format |
| `/push` | Push current branch to remote |
| `/pr` | Create pull request with template |
| `/ship` | Full workflow: commit + push + PR |
| `/review` | Code review of recent changes |
| `/test` | Auto-detect and run the project's test suite |
| `/debug [issue]` | Systematic root-cause analysis for an issue |
| `/refactor [target]` | Improve code quality without changing behavior |
| `/spec-interview` | Interactive requirements gathering |
| `/generate-prd` | Generate product requirements document |

---

## Planning System

The planning skill creates a `.planning/` directory with a hierarchy:

```
.planning/
├── BRIEF.md          # Problem statement + goals
├── ROADMAP.md        # High-level milestones
├── RESEARCH.md       # Research findings (optional)
└── phases/
    ├── 01-foundation-PLAN.md
    ├── 01-foundation-SUMMARY.md
    ├── 02-features-PLAN.md
    └── ...
```

**Key principles:**
- Plans degrade at 40-50% context, not 80%
- Maximum 2-3 tasks per PLAN.md
- Each task includes: exact file paths, Action/Why/Depends on/Risk/Done when

---

## MCP Servers

`mcp/recommended-servers.json` contains configuration for:

- **github** — PR/issue management
- **filesystem** — File operations outside project
- **postgres** — Database introspection
- **atlassian** — Jira/Confluence integration
- **brave-search** — Web search
- **memory** — Persistent knowledge graph
- **mermaid** — Diagram generation

See the file for Claude Code vs Cursor installation instructions.

---

## Contributing

1. Fork this repo
2. Add your skill/subagent/command to the appropriate directory
3. Follow the patterns in existing files (XML tags, YAML frontmatter)
4. Submit a PR

Use `/spec-interview` to gather requirements before building anything significant.

---

**Version:** 2.0.0
**Compatible With:** Claude Code (Claude 4.5+), Cursor 0.40+
**Last Updated:** 2026-02-23
