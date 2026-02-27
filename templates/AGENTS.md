# AGENTS.md — Project AI Agent Instructions

> This file is read by GitHub Copilot, Gemini CLI, and other AI agents that support AGENTS.md.
> It is installed from the [Agent Runtime Kit](https://github.com/shir-bruchim/agent-runtime-kit).
> Edit it to match your project's actual commands and conventions.

---

## Coding Conventions

Follow `base-conventions.md` (no magic numbers, early returns, functions do one thing).
Follow `security.md` (parameterized queries, no hardcoded secrets, validate at boundaries).
Follow `testing.md` (AAA pattern, name tests as sentences, test edge cases).

If this project has a `CLAUDE.md` or `.cursor/rules/` directory, those take precedence.

---

## Language

<!-- Replace with your project's language -->
Primary language: **TypeScript** (or Python / Go / etc.)

Follow the conventions in `.claude/rules/` or `.cursor/rules/` for this language.

---

## Test Command

```bash
# Replace with your project's actual test command
npm test
# or: pytest / go test ./... / cargo test
```

Run tests before committing. All tests must pass.

---

## Lint / Format

```bash
# Replace with your project's actual lint/format commands
npm run lint
npm run format
```

---

## Validation Checklist

Before marking work complete:
- [ ] All tests pass
- [ ] No new lint errors
- [ ] No hardcoded credentials or secrets
- [ ] No `console.log` / `print` debug statements left in
- [ ] PR description explains what and why

---

## Safety

- Never commit `.env` files or credential files
- Use environment variables for secrets
- Validate all user input at system boundaries

---

## Where Overrides Live

| Platform | Project overrides |
|----------|------------------|
| Claude Code | `.claude/rules/*.md` |
| Cursor | `.cursor/rules/*.mdc` |
| All agents | This file (`AGENTS.md`) |

See `PROFILES.md` in the kit for CORE vs FULL profile details.