# Workflow: Create Pull Request

<process>
1. Ensure changes are pushed: `git push`
2. Check for PR template:
   ```bash
   ls .github/PULL_REQUEST_TEMPLATE* 2>/dev/null
   ls .github/PULL_REQUEST_TEMPLATE/ 2>/dev/null
   ```
3. Get diff summary: `git diff main...HEAD --stat`
4. Get commit history: `git log main..HEAD --oneline`
5. Create PR with gh CLI:
   ```bash
   gh pr create --title "type(scope): description" --body "$(cat <<'EOF'
   ## Summary
   - [What this PR does]
   
   ## Test plan
   - [ ] [Test 1]
   - [ ] [Test 2]
   
   ## Changes
   - [file]: [what changed]
   EOF
   )"
   ```
6. Output the PR URL
</process>

<success_criteria>
PR created. URL returned to user. Title follows repo convention. Body uses template if available.
</success_criteria>
