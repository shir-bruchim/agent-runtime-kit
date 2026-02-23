---
description: Full ship workflow — commit, push, and open a pull request in one step
---

<objective>
Complete the full git workflow: stage + commit + push + create PR.
</objective>

<context>
Current status: !`git status`
Current branch: !`git branch --show-current`
Recent commits: !`git log --oneline -5`
</context>

<process>
Run in sequence:
1. Stage and commit (following conventional commits format)
2. Push to remote with upstream tracking
3. Create pull request with gh CLI
4. Output PR URL
</process>

<success_criteria>
All three steps completed. PR URL returned to user.
</success_criteria>
