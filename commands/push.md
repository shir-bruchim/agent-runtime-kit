---
description: Push current branch to remote, creating upstream tracking if needed
allowed-tools: Bash(git push:*), Bash(git status:*), Bash(git branch:*)
---

<objective>
Push commits to remote repository.
</objective>

<context>
Current branch: !`git branch --show-current`
Status: !`git status`
</context>

<process>
1. Check current branch (refuse if on main/master)
2. Push with upstream tracking:
   ```bash
   git push -u origin $(git branch --show-current)
   ```
   Or if already tracking: `git push`
3. Confirm push succeeded
</process>

<success_criteria>
Push succeeded. Remote branch updated or created with upstream tracking.
</success_criteria>
