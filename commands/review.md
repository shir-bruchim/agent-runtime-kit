---
description: Review current code changes for quality, correctness, and security
---

<objective>
Review all changes in the current working tree for quality, correctness, security, and best practices.
</objective>

<context>
Changes: !`git diff HEAD`
Files changed: !`git diff --name-only HEAD`
</context>

<process>
1. Examine each changed file
2. Check for: correctness, edge cases, security issues, error handling
3. Rate findings: Critical / High / Medium / Low
4. Provide specific file:line references for all issues
5. Suggest actionable fixes
</process>

<success_criteria>
All changed files reviewed with severity-rated, actionable feedback.
</success_criteria>
