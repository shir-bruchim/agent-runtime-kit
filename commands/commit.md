---
description: Stage and commit all changes with a conventional commit message
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git commit:*)
---

<objective>
Create a git commit for current changes following conventional commits format.
</objective>

<context>
Current status: !`git status`
Changes: !`git diff HEAD`
Recent commits: !`git log --oneline -5`
Current branch: !`git branch --show-current`
</context>

<process>
1. Review all changes from the context above
2. If on main/master: create a feature branch first: `git checkout -b type/description`
3. Stage relevant files (avoid .env, credentials, generated files)
4. Write commit message following conventional commits:
   - `feat(scope): description` for new features
   - `fix(scope): description` for bug fixes
   - `refactor(scope): description` for refactoring
5. Create commit with Co-Authored-By trailer
</process>

<success_criteria>
- Correct files staged
- Commit message follows repo convention
- Commit created successfully
- Not on main/master branch
</success_criteria>
