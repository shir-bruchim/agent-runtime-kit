---
description: Full ship workflow — commit, push, and open a pull request in one step
---

<objective>
Complete the full git workflow: stage + commit + push + create PR.

Use when you've finished a feature or fix and want to ship it for review in one command.
</objective>

<context>
Current status: !`git status`
Current branch: !`git branch --show-current`
Recent commits: !`git log --oneline -5`
</context>

<process>
Run in sequence — stop if any step fails:

1. **Review changes**: Check `git status` and `git diff` for what's staged
2. **Stage**: `git add` the relevant changed files
3. **Commit**: Write a conventional commit message (`type(scope): description`)
4. **Push**: `git push -u origin <current-branch>`
5. **Create PR**: `gh pr create` with title from commit, template body
6. **Output PR URL**
</process>

<success_criteria>
- All three steps completed without errors
- PR URL returned to user
- PR title matches the commit message

## Example output
```
✅ Staged: 3 files changed
✅ Committed: feat(auth): add JWT refresh token rotation
✅ Pushed: origin feature/auth
✅ PR created: https://github.com/org/repo/pull/42
🎉 Ready for review!
```
</success_criteria>

<when_not_to_use>
- Uncommitted work you're not sure about → use `/commit` first, review, then `/push`
- Direct pushes to main → create a feature branch first
- Work in progress → commit with `wip:` prefix and skip PR
</when_not_to_use>
