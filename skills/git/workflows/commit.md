# Workflow: Git Commit

<process>
1. Check git status: `git status`
2. Check recent commits for style: `git log --oneline -5`
3. Review changes: `git diff HEAD`
4. Stage relevant files (avoid: .env, credentials, large binaries)
5. **Verify the staged set** — run `git status` (or `git diff --cached --stat`) and confirm what's about to be committed matches intent. IDE/tooling processes can place files under your named paths between the initial status check and `git add`; explicit-path staging is necessary but not sufficient.
6. Write commit message following repository convention
7. Create commit using HEREDOC format

**If on main/master:** Create a feature branch first:
```bash
git checkout -b feat/description-of-changes
```

**Stage files:**
```bash
git add path/to/specific/file.ts   # Prefer specific files
# Avoid: git add -A or git add . (may include unintended files)
git status                         # Confirm staged set before commit
```

**Commit:**
```bash
git commit -m "$(cat <<'EOF'
type(scope): description

- Detail if needed

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```
</process>

<success_criteria>
- Correct files staged (no .env, credentials, generated files)
- Commit message follows repo convention
- Commit created successfully
- Not on main/master branch
</success_criteria>
