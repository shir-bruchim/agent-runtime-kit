# GitHub Copilot Instructions

> This file customizes Copilot's behavior for this repository.
> See also: `AGENTS.md` for full project context shared across AI agents.

---

## Code Style

- Names reflect purpose (`getUserByEmail`, not `getUser`)
- Functions do one thing; split if you need "and" to describe it
- Early returns reduce nesting — validate first, happy path last
- No magic numbers — use named constants
- TypeScript strict mode always on (or equivalent for your language)

## Testing

- Tests follow AAA: Arrange / Act / Assert
- Name tests as sentences: `test_user_cannot_login_with_expired_token`
- Test edge cases: empty input, boundaries, error conditions
- All tests must pass before suggesting a completion

## Safety

- Never suggest hardcoded API keys, passwords, or tokens
- Use parameterized queries — never string-interpolated SQL
- Validate user input at system boundaries
- No `eval()`, no command injection, no XSS

## Workflow

- Conventional commits: `feat(scope): description`, `fix(scope): description`
- Branch names: `feat/*`, `fix/*`, `chore/*`
- Never push directly to `main`

---

For full project context, see `AGENTS.md` in the project root.