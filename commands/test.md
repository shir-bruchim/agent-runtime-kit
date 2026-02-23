---
description: Detect and run the project's test suite
---

<objective>
Auto-detect the test framework and run tests for the current project.
</objective>

<context>
Project files: !`ls package.json pyproject.toml go.mod Makefile 2>/dev/null`
</context>

<process>
1. Detect test framework from project files:
   - `package.json` with jest/vitest → `npm test` or `npx vitest`
   - `pyproject.toml` or `pytest.ini` → `pytest -v`
   - `go.mod` → `go test ./...`
   - `Makefile` with test target → `make test`
2. Run the detected test command
3. Report: total tests, passed, failed, any errors
4. If tests fail, show the failing test names and error messages
</process>

<success_criteria>
- Test command detected and executed
- Results clearly reported (pass/fail counts)
- Failing tests shown with error messages
</success_criteria>
