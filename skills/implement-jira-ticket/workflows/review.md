# Workflow: Code Review and Verification

Run this after implementation is approved, before declaring the ticket done.

<process>

## Step 1: Re-Read the Jira Ticket

Go back to the original Jira ticket and verify every line:

- [ ] All acceptance criteria are met
- [ ] All requirements from the description are addressed
- [ ] Any linked instruction pages or URLs were followed
- [ ] Nothing in the ticket description was missed

If you find a gap: implement it, then re-verify.

## Step 2: Self-Review the Code

Read through every file you changed:

**Code quality checks:**
- [ ] No function complexity > O(n) (document and flag any exceptions)
- [ ] DB reads/writes are batched where possible — no unnecessary round trips
- [ ] No unused functions, parameters, or imports
- [ ] No dead code paths
- [ ] Error handling is consistent with existing patterns
- [ ] Comments explain WHY, not WHAT

**Architecture checks:**
- [ ] Single responsibility: each DB repository handles exactly one table
- [ ] No cross-table logic in a repository that belongs in the service/logic layer
- [ ] Existing naming conventions followed exactly
- [ ] No feature flags or backwards-compatibility hacks unless the ticket requires them

## Step 3: Check for Leftover Artifacts

```bash
# Search for debug prints or TODO comments you may have left
grep -rn "print(" --include="*.py" .
grep -rn "TODO\|FIXME\|HACK\|XXX" --include="*.py" .
grep -rn "import pdb\|breakpoint()" --include="*.py" .
```

Remove any found debug artifacts.

## Step 4: Update README (if needed)

If the implementation:
- Adds a new publicly visible feature
- Changes configuration options
- Adds or changes environment variables
- Changes the API surface

Then update `README.md` with:
- New functionality description
- Configuration changes
- Environment variable additions

## Step 5: Completion Checklist

Before reporting complete:

- [ ] Feature branch created from develop: `feature/{JIRA-ID}`
- [ ] Implementation plan was approved by user
- [ ] All code changes implemented per plan (no ping-pong)
- [ ] Existing patterns followed (studied end-to-end examples)
- [ ] Single responsibility maintained (1 repo per table)
- [ ] No functions > O(n) complexity
- [ ] All existing tests pass
- [ ] Unit tests created for all new functions
- [ ] Integration tests created (if behavior/DB state changed)
- [ ] No unused code, params, or imports
- [ ] Jira ticket fully addressed (every acceptance criterion checked)
- [ ] README updated (if significant behavior change)
- [ ] Ready for commit: `git diff --stat`

</process>

<next_steps>

After verification is complete:

```bash
# Review what you changed
git diff

# Commit changes
# Use /commit skill or:
git add -p
git commit -m "feat(scope): description of what was done

Implements {JIRA-ID}: [brief summary]"

# Create PR
# Use /pr skill or:
gh pr create --title "feat: [summary]" --body "Closes {JIRA-ID}"
```

</next_steps>