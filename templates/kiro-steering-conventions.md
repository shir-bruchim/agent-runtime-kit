---
inclusion: auto
---

# Project Conventions — Agent Runtime Kit

> This steering file is auto-included in all Kiro conversations.
> Edit it to match your project's actual setup.

## Project Context

<!-- Replace with a brief description of your project -->
This is a [describe your project here].

Primary language: **TypeScript** (or Python / Go / etc.)
Framework: [your framework]

## Coding Standards

- Names reflect purpose: `getUserByEmail()` not `getUser()`
- Functions do one thing; return early on validation failure
- No magic numbers — use named constants
- Comments explain **why**, not **what**

## Test Command

```bash
# Run all tests
npm test

# Run a single test file
npm test -- path/to/test.spec.ts
```

## Build / Dev

```bash
# Start dev server
npm run dev

# Build for production
npm run build
```

## Safety Rules

- Never commit `.env` files or secrets
- Always use environment variables for credentials
- Validate at system boundaries (user input, external APIs)
- No debug `console.log` in committed code

## Where Overrides Live

| Platform | Project overrides |
|----------|------------------|
| Kiro | `.kiro/steering/*.md` |
| Claude Code | `.claude/rules/*.md` |
| Cursor | `.cursor/rules/*.mdc` |
| All agents | `AGENTS.md` |

Installed from [Agent Runtime Kit](https://github.com/shir-bruchim/agent-runtime-kit).
Profiles: CORE (default) / FULL — see `PROFILES.md`.
