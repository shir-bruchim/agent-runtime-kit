---
description: Full ship workflow — commit, push, open a pull request, and auto-review in one step
---

<objective>
Complete the full git workflow: stage + commit + push + create PR + auto-review.

Use when you've finished a feature or fix and want to ship it for review in one command.
</objective>

<context>
Current status: !`git status`
Current branch: !`git branch --show-current`
Recent commits: !`git log --oneline -5`
</context>

<process>

### Phase 1 — Create PR

Run in sequence — stop if any step fails:

1. **Verify prerequisites**
   - `gh auth status` — abort if not authenticated
   - Confirm current branch is not `main` or `master`
2. **Review changes**: Check `git status` and `git diff` for staged/unstaged
3. **Stage**: `git add` the relevant changed files
4. **Commit**: Write a conventional commit message (`type(scope): description`)
5. **Push**: `git push -u origin <current-branch>`
6. **Create PR**: `gh pr create` with title from commit, structured body:
   ```
   ## Summary
   - <what changed>
   - <why / motivation>

   ## Test plan
   - [ ] <specific thing to verify>
   - [ ] All existing tests pass
   ```
7. **Capture PR number** from output

### Phase 2 — Auto-Review

After PR creation, load `skills/pr-review/` and run the review:

8. **Fetch the diff**: `gh pr diff <number>`
9. **Analyze across 5 dimensions**: correctness, security, best practices, test coverage, code quality
10. **Output review report** with CRITICAL/Warning/Suggestion tiers

</process>

<success_criteria>
- All steps completed without errors
- PR URL returned to user
- Review report produced with per-dimension status
- Critical issues (if any) called out prominently

## Example output
```
PR Created
URL: https://github.com/org/repo/pull/42
Title: feat(auth): add JWT refresh token rotation
Branch: feat/auth → main

PR Review: feat(auth): add JWT refresh token rotation (#42)

Warnings:
- src/auth.py:23 — No test for invalid token path

Looks Good:
- Password hashed with bcrypt
- JWT expiry set correctly

Verdict: APPROVE
```
</success_criteria>

<when_not_to_use>
- Uncommitted work you're not sure about → use `/commit` first, review, then `/push`
- Direct pushes to main → create a feature branch first
- Work in progress → commit with `wip:` prefix and skip PR
</when_not_to_use>
