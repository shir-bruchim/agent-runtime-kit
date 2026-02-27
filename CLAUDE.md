# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A configuration kit — no build steps, no dependencies, no test suite. All files are Markdown (`.md`) or shell scripts (`.sh`). Contributing means adding or editing those files and following the format contracts below.

## Branch and Commit Conventions

- Never commit directly to `main`. Use `feat/*`, `fix/*`, `docs/*`, `chore/*` branches.
- Conventional commits: `feat(scope): description`, `fix(scope): description`, etc.
- PRs should be small and single-concern.

## Architecture: How the Kit Works

The repo distributes configuration files to AI agents. There are two destinations:

| Source in repo | Installed to | Scope |
|----------------|-------------|-------|
| `skills/*/SKILL.md` | `~/.claude/skills/` | Global (all projects) |
| `subagents/*.md` | `~/.claude/agents/` | Global |
| `commands/*.md` | `~/.claude/commands/` | Global |
| `skills/security/hooks/*.sh` | `~/.claude/hooks/` | Global |
| `rules/*.md` + `languages/**/*.md` | Project `CLAUDE.md` or `.claude/rules/` | Per-project |

**`AGENT-SETUP.md`** is the self-install instruction file — when a user pastes the GitHub URL into Claude, the agent reads this file and follows its steps to detect platform (Claude Code vs Cursor) and install files in the right locations.

**`scripts/`** contains shell automation for the install process (`check-kit-updates.sh` compares the last-installed commit SHA and outputs a JSON plan; `install-kit.sh` executes the plan atomically with resume support).

## File Format Contracts

**Skills (`skills/*/SKILL.md`)** must have:
```yaml
---
name: skill-name
description: When to use this skill. Specific enough to auto-trigger.
---
```
Body uses XML tags (`<essential_principles>`, `<intake>`, `<routing>`, `<success_criteria>`), **not** markdown headings. Simple skills are a single file; complex skills add `workflows/`, `references/`, `templates/` subdirs with a router pattern in the main SKILL.md.

**Subagents (`subagents/*.md`)** must have:
```yaml
---
name: name
description: When Claude should automatically invoke this agent.
tools: Read, Write, Edit, ...
model: sonnet|opus|haiku
---
```
Subagents cannot use `AskUserQuestion` — they run isolated and return a single result.

**Commands (`commands/*.md`)** must have:
```yaml
---
description: Short description (appears in /help)
argument-hint: [optional-arg]
---
```

## Key Design Principles

- **Minimum tokens**: Skills should be lean. Merge related content rather than adding new files. Consolidate instead of proliferate.
- **Rules vs CLAUDE.md**: For new project installations, prefer adding key conventions to the project's existing `CLAUDE.md` rather than creating separate `.claude/rules/` files. Only create rule files for content not already in `CLAUDE.md`.
- **Hooks are global**: Security hooks (`block-dangerous-bash.sh`, `protect-files.sh`) belong in `~/.claude/hooks/` and `~/.claude/settings.json` (global), not project-level `.claude/hooks.json`. The source scripts live in `skills/security/hooks/` for distribution.
- **No `.claude/` in this repo**: Project-level `.claude/` config for this repo is not committed. The kit distributes TO other projects' `.claude/` folders; it doesn't need its own.
- **Don't read install scripts into context**: `scripts/check-kit-updates.sh` and `scripts/install-kit.sh` are for shell execution only. Run them with Bash; don't read them into Claude's context.

## Adding New Content

- **New skill**: Follow the SKILL.md format. Use `skills/extend-agent/` (the meta-skill) to generate it if needed. Add to the skills table in `README.md`.
- **New subagent**: Follow subagent format. Update `README.md` subagents table.
- **New command**: Follow command format. Update `README.md` commands table.
- **New language pack**: Add `languages/<lang>/conventions.md` and optionally `testing.md`, `database.md`. Update `AGENT-SETUP.md` language detection section.
- **Hook scripts**: Place in `skills/security/hooks/` and update install instructions in `AGENT-SETUP.md`.
