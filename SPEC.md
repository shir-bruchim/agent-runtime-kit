# SPEC: Agent Runtime Kit — Team Distribution Package

## Problem Statement

The agent-runtime-kit repo contains 17 skills, 15 subagents, 7 commands, 7 rules, 10 hooks, 6 language packs, and routing config — all designed to give Claude Code (and Cursor) a shared source of truth for coding standards, review patterns, and development workflows.

Today, installation is manual: a developer pastes the GitHub URL into Claude Code and follows AGENT-SETUP.md. There's no mechanism to:
- Distribute the kit across a 50-person R&D team automatically
- Notify developers when the kit is updated
- Enforce that PRs were authored using kit standards
- Let GitHub reviewer agents (CI) apply the same rules during PR review
- Allow per-repo profile customization while maintaining a single upstream source

## Target Users

- 50 R&D developers using Claude Code (and some Cursor) daily
- Team leads who configure per-repo profiles
- CI pipeline (GitHub Actions) acting as reviewer agent on PRs
- The kit maintainer(s) who publish updates

## Requirements

### R1: Private Distribution Package

- Move the kit to a **new private repo** under the team's GitHub org (e.g., `sensai-org/agent-runtime-kit`)
- The repo is the single source of truth — all developers and CI pull from it
- Semver releases (GitHub Releases with tags: `v3.2.0`, `v3.3.0`, etc.)
- Developers can pin to a version or track `latest`

### R2: Onboarding Install (One-Time Setup)

- A shell script (`scripts/team-install.sh`) that developers run once during onboarding
- Installs the kit globally (`~/.claude/skills/`, `~/.claude/agents/`, `~/.claude/commands/`, `~/.claude/hooks/`)
- Configures the **session-start hook** to auto-check for updates on every Claude Code session
- Accepts `--profile`, `--tags`, `--platform` flags (defaults: `core`, no tags, `auto`)
- Reads a **per-repo config file** (`.agent-kit.json`) if present, to determine project-specific profile/tags
- Must work on macOS and Linux

### R3: Auto-Update on Session Start

- A **session-start hook** (`hooks/kit-update-check.sh`) runs every time Claude Code starts
- Checks the upstream repo for new releases (compares local version vs remote latest tag)
- If update available: shows a diff summary and prompts the developer to approve
- Respects the version pin if set (`~/.claude/.agent-kit-state.json` → `"pinned_version": "v3.2.0"`)
- Rate-limited: checks at most once per hour (caches last check timestamp)
- Zero-impact if up to date (exits in <1 second)

### R4: Slack Notification on Release

- A **GitHub Actions workflow** (`release-notify.yml`) triggers on new GitHub Release
- Posts to a configured Slack channel (webhook URL stored as repo secret)
- Message includes: version, changelog summary, what changed (skills/rules/hooks), install command
- Optional: tags specific team handles based on what changed (e.g., `@backend-team` if Python rules changed)

### R5: Per-Repo Configuration

- Projects can include `.agent-kit.json` at their root:
  ```json
  {
    "profile": "full",
    "tags": ["python", "stack"],
    "version": "v3.3.0",
    "overrides": {
      "skip": ["skills/ralph-orchestrator"],
      "extra_rules": [".claude/rules/project-specific.md"]
    }
  }
  ```
- The install script and update hook read this file when run inside a project directory
- If no `.agent-kit.json`, falls back to developer's global config
- Individual devs can override via `~/.claude/.agent-kit-state.json` overrides

### R6: CI Reviewer Agent (GitHub Actions)

- A **reusable GitHub Actions workflow** (`kit-review.yml`) that any repo can add to their CI
- On PR: checks out the kit at the version specified in `.agent-kit.json` (or latest)
- Runs kit rules as validation:
  - Validates code against `rules/*.md` conventions (via a linting/check script)
  - Runs the `pr-review` skill's checklist against the PR diff
  - Posts review comments on the PR via GitHub API
- **Blocks merge** if critical violations found (configurable severity threshold)
- The workflow is published as a **reusable workflow** so repos just add:
  ```yaml
  jobs:
    kit-review:
      uses: sensai-org/agent-runtime-kit/.github/workflows/kit-review.yml@v3.3.0
      secrets: inherit
  ```

### R7: Rollback Mechanism

- `scripts/team-install.sh --rollback` reverts to the previous installed version
- State file tracks the last 3 installed versions for rollback
- CI workflow pins to a specific version tag (not `main`), so rollback = change the tag

### R8: Version Enforcement in CI

- The CI reviewer workflow checks that the developer's kit version matches the repo's `.agent-kit.json` version
- If a developer's Claude Code session used an older kit version, the CI can detect this via:
  - A `.kit-version` marker file committed with the PR (optional, lightweight)
  - Or by validating the code against the current kit rules regardless of what the dev used
- Configurable enforcement level: `warn` (comment on PR) or `block` (fail the check)

## Verification Environment

- Shell: bash/zsh on macOS (developer machines) and bash on Ubuntu (GitHub Actions runners)
- GitHub: private repo in org, GitHub Actions, GitHub Releases, Slack webhook
- No external dependencies beyond git, bash, curl, jq, python3 (already available)
- No package managers (npm, pip) — pure shell + markdown distribution

## Architecture Overview

```
sensai-org/agent-runtime-kit (private, versioned)
  ├── (existing kit files: skills/, subagents/, commands/, rules/, hooks/, etc.)
  ├── scripts/
  │   ├── team-install.sh          ← NEW: one-time onboarding installer
  │   ├── check-kit-updates.sh     ← EXISTING: enhanced for version tags
  │   └── install-kit.sh           ← EXISTING: enhanced for rollback state
  ├── hooks/
  │   └── kit-update-check.sh      ← NEW: session-start update checker
  ├── .github/workflows/
  │   ├── ci.yml                   ← EXISTING: kit self-validation
  │   ├── release-notify.yml       ← NEW: Slack notification on release
  │   └── kit-review.yml           ← NEW: reusable PR reviewer workflow
  └── templates/
      └── agent-kit.json           ← NEW: template for per-repo config
```

Developer's machine after install:
```
~/.claude/
  ├── skills/         ← from kit
  ├── agents/         ← from kit
  ├── commands/       ← from kit
  ├── hooks/
  │   └── kit-update-check.sh  ← auto-check on session start
  └── .agent-kit-state.json    ← version, pin, rollback history
```

## Out of Scope

- Cursor-specific distribution (focus on Claude Code; Cursor gets files via same mechanism but no hooks)
- Building a web UI or dashboard for kit management
- Auto-merging updates without developer approval
- MCP server distribution (remains opt-in manual per mcp/SETUP.md)

## Open Questions

1. What GitHub org name for the private repo? (used `sensai-org` as placeholder)
2. Which Slack channel for release notifications?
3. Should the CI reviewer use Claude API directly (expensive but smart) or rule-based checks (cheap but rigid)?
4. Should `.kit-version` be committed with PRs, or should CI validate rules independently?