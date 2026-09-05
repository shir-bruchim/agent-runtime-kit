---
name: git-workflow
description: Git branching strategy, conventional commit messages, PR conventions, rebase vs merge guidance, and protected files list.
---

# Git Workflow

- **Never commit directly to `main`** — always branch: `feat/*`, `fix/*`, `refactor/*`, `chore/*`, `docs/*`.
- **Conventional commits:** `type(scope): summary` (≤50 chars). Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `perf`. Body explains WHY, not WHAT. Footer `Closes #142` to auto-close.
- **PRs:** one concern each; self-review your diff first; description says what/why/how-to-test; don't merge your own PR.
- **Rebase** feature branches onto main before merging (linear history); **never rebase pushed commits**.
- **Splitting a big PR that shares a schema/deps change:** a slice can't be both independent-off-main AND individually integration-green. Either **stack** the slices, or land the shared **schema+deps as one foundational PR first**, then cut independent slices off it.

## Never commit
`.env*` (commit `.env.example` with placeholders), `*.pem`/`*.key`/credentials, editor config (`.idea/`, `.vscode/`), build artifacts (`dist/`, `build/`, `__pycache__/`).