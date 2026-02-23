# Full Setup Example

How to use agent-runtime-kit to configure your AI agent in a new project.

## Step 1: Tell Your Agent

```
"Use https://github.com/shir-bruchim/agent-runtime-kit to set yourself up 
in this [Python FastAPI / Node.js / Go] project."
```

The agent reads AGENT-SETUP.md and handles the rest.

## Step 2: What the Agent Does

### For Claude Code, the agent creates:

```
your-project/
├── CLAUDE.md                    # Project context (assembled from rules/)
├── .claude/
│   ├── settings.json            # Agent settings
│   ├── skills/
│   │   ├── debugging/           # → From skills/debugging/
│   │   ├── git/                 # → From skills/git/
│   │   ├── security/            # → From skills/security/
│   │   ├── testing/             # → From skills/testing/
│   │   ├── planning/            # → From skills/planning/
│   │   ├── create-ai-skills/    # → From skills/create-ai-skills/
│   │   ├── create-automation-hooks/
│   │   ├── create-commands/
│   │   └── create-subagents/
│   ├── agents/
│   │   ├── architect.md         # → From subagents/architect.md
│   │   ├── reviewer.md          # → From subagents/reviewer.md
│   │   ├── planner.md           # → From subagents/planner.md
│   │   ├── tester.md            # → From subagents/tester.md
│   │   ├── git-ops.md           # → From subagents/git-ops.md
│   │   ├── security.md          # → From subagents/security.md
│   │   ├── db-expert.md         # → From subagents/db-expert.md
│   │   └── refactorer.md        # → From subagents/refactorer.md
│   ├── commands/
│   │   ├── commit.md            # → /commit
│   │   ├── push.md              # → /push
│   │   ├── pr.md                # → /pr
│   │   ├── ship.md              # → /ship
│   │   └── review.md            # → /review
│   └── hooks.json               # Safety hooks (optional)
```

### For Cursor, the agent creates:

```
your-project/
├── .cursor/
│   ├── rules/
│   │   ├── base-conventions.mdc       # alwaysApply: true
│   │   ├── security.mdc               # alwaysApply: true
│   │   ├── git-workflow.mdc           # alwaysApply: false
│   │   ├── debugging.mdc              # alwaysApply: false
│   │   ├── python-conventions.mdc     # globs: ["**/*.py"]
│   │   └── testing.mdc                # alwaysApply: false
│   └── mcp.json                       # MCP server config
```

## Step 3: The CLAUDE.md Structure

For a Python FastAPI project, CLAUDE.md would look like:

```markdown
# Project Context

## Overview
[Project name and description — AI fills this in]

## Tech Stack
- Python 3.11 + FastAPI
- SQLAlchemy 2.0 + PostgreSQL
- pytest for testing
- Docker for containerization

## Key Conventions
[Content assembled from rules/base-conventions.md]
[Content assembled from languages/python/conventions.md]

## Skills Available
- `/commit` — Stage and commit changes
- `/push` — Push to remote
- `/pr` — Create pull request
- `/ship` — Full commit + push + PR
- `/review` — Code review

## Subagents Available
- `architect` — System design decisions
- `reviewer` — Code review
- `planner` — Implementation planning
- `tester` — Test writing
- `git-ops` — Git operations
- `security` — Security review
- `db-expert` — Database queries and schema
```

## Customization After Setup

**Add project-specific rules to CLAUDE.md:**
```markdown
## Project-Specific Rules
- All API endpoints require authentication (use `get_current_user` dependency)
- Database migrations must include downgrade() implementation
- All new endpoints require integration tests
```

**Add team conventions:**
```markdown
## Team Conventions
- PR reviews required from @team-lead for auth changes
- Deployment: push to staging branch, validate, then main
- Use issue numbers in commit messages: fix(auth): ... Closes #42
```
