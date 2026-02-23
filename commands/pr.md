---
description: Create a pull request for the current branch using gh CLI
allowed-tools: Bash(git log:*), Bash(git diff:*), Bash(git push:*), Bash(gh pr create:*), Bash(gh pr view:*), Bash(ls:*), Bash(cat:*)
---

<objective>
Create a GitHub pull request for the current branch.
</objective>

<context>
Current branch: !`git branch --show-current`
Commits: !`git log main..HEAD --oneline`
Changed files: !`git diff main...HEAD --stat`
</context>

<process>
1. Check for PR template: `ls .github/PULL_REQUEST_TEMPLATE* 2>/dev/null`
2. Ensure changes are pushed
3. Create PR with gh CLI using template structure if found
4. Output the PR URL
</process>

<success_criteria>
PR created and URL returned.
</success_criteria>
