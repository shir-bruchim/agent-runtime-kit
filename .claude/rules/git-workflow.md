# Git Workflow Conventions

## Branch Strategy

```
main          → Always deployable, protected
feat/*        → New features
fix/*         → Bug fixes
refactor/*    → Refactoring without behavior changes
chore/*       → Dependency updates, CI changes
docs/*        → Documentation only
```

**Never commit directly to main.** Always work in a branch.

## Commit Messages (Conventional Commits)

```
type(scope): short description (50 chars max)

Optional body explaining WHY, not WHAT (72 chars per line)

Optional footers
```

**Types:**
- `feat` — New feature visible to users
- `fix` — Bug fix
- `refactor` — Code change with no behavior change
- `test` — Adding or updating tests
- `docs` — Documentation only
- `chore` — Build, CI, dependency updates
- `perf` — Performance improvements

**Good commit messages:**
```
feat(auth): add JWT refresh token rotation

Refresh tokens now rotate on every use to prevent replay attacks.
The old token is invalidated immediately after issuing a new one.

Closes #142
```

**Bad commit messages:**
```
fix bug
WIP
updates
```

## Pull Request Conventions

- **Small PRs**: One concern per PR. Large PRs get poor reviews.
- **Self-review first**: Read your own diff before requesting review
- **Description required**: What, why, how to test
- **Link issues**: "Closes #42" in description auto-closes the issue
- **Don't merge your own PRs**: Get at least one review

## Rebasing vs Merging

- **Rebase** feature branches onto main before merging (clean linear history)
- **Merge** when merging feature to main (preserves the branch structure)
- **Never rebase** pushed commits (rewrites shared history)

## Protected Files (Never Commit)

- `.env*` files (use `.env.example` with placeholder values)
- `*.pem`, `*.key`, credential files
- Editor config files (`.idea/`, `.vscode/` — add to `.gitignore`)
- Build artifacts (`dist/`, `build/`, `__pycache__/`)
