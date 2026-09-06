---
name: testing
description: Universal testing standards — what to test, naming, AAA structure, test pyramid, edge cases, and the 80% coverage default.
---

# Testing Standards

- **Test what matters:** business logic, edge cases, error conditions, integration points. Not getters/setters, framework code, generated code.
- **Test-first for non-trivial changes:** write the failing test, confirm it fails (red), then minimal code to pass (green), then refactor. The red step is non-optional. Skip only for pure config/dep bumps, trivial one-liners covered by the suite, or throwaway spikes — and say so.
- **Name as behavior:** `test_user_cannot_login_with_expired_token`, not `test_login`.
- **AAA structure** (Arrange / Act / Assert). Share arrange-phase setup via fixtures/factories taking `**overrides` — don't copy-paste it.
- **Pyramid:** many unit (fast, isolated) · some integration (real DB, mocked external APIs) · few E2E (critical paths only).
- **Edge cases:** empty inputs, boundary values, invalid types, concurrency, idempotency.
- **Coverage:** 80% is a default, not the goal — critical paths and error conditions matter more than the number.

Pytest/Jest/Go specifics and the full TDD loop live in the lazy `testing` skill.
