---
description: Refactor code in a specified file or area for clarity, performance, or maintainability
argument-hint: [file-path or description of what to refactor]
---

<objective>
Refactor "$ARGUMENTS" to improve code quality without changing behavior.
</objective>

<process>
1. Read the target code completely
2. Run existing tests to establish baseline (must all pass)
3. Identify specific issues:
   - Duplicated logic that can be extracted
   - Long functions that do too many things
   - Unclear variable/function names
   - Complex conditionals that can be simplified
   - Missing abstractions or over-engineering
4. Make ONE refactoring at a time
5. Run tests after EACH change — stop if any test fails
6. Repeat until all identified issues addressed
</process>

<success_criteria>
- All tests passing before and after refactoring
- Code is cleaner: shorter functions, better names, less duplication
- No behavior changes introduced
- Diff is reviewable (not a complete rewrite)
</success_criteria>
