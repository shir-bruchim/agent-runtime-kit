# GEMINI.md — Project Context for Gemini CLI

> This file provides project context to Gemini CLI (gemini --context GEMINI.md).
> Edit it to match your project's actual setup.

---

## Project Context

<!-- Replace with a brief description of your project -->
This is a [describe your project here].

Primary language: **TypeScript** (or Python / Go / etc.)
Framework: [your framework]

---

## Coding Standards

- Follow conventions in `.claude/rules/` or `.cursor/rules/`
- Names reflect purpose: `getUserByEmail()` not `getUser()`
- Functions do one thing; return early on validation failure
- No magic numbers — use named constants
- Comments explain **why**, not **what**

---

## Test Command

```bash
# Run all tests
npm test

# Run a single test file
npm test -- path/to/test.spec.ts
```

---

## Build / Dev

```bash
# Start dev server
npm run dev

# Build for production
npm run build
```

---

## Safety Rules

- Never commit `.env` files or secrets
- Always use environment variables for credentials
- Validate at system boundaries (user input, external APIs)
- No debug `console.log` in committed code

---

## Key Files

<!-- List important files Gemini should know about -->
- `src/` — application source
- `tests/` — test files
- `.env.example` — required environment variables (copy to `.env`)

---

## Installed from Agent Runtime Kit

Profiles: CORE (default) / FULL — see `PROFILES.md`.
Full kit docs: https://github.com/shir-bruchim/agent-runtime-kit