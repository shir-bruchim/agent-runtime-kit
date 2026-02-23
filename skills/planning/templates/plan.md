# Plan Template (PLAN.md = Executable Prompt)

This template IS the plan. When filled out, it becomes the prompt the agent executes.

Save as `.planning/phases/{phase-name}/{phase}-{plan}-PLAN.md`

```markdown
# Plan: [Short description]

**Phase:** [Phase name]
**Plan:** [Phase-Plan number, e.g., 01-02]

## Objective

[2-3 sentences: What we're building and why. This becomes the execution goal.]

## Context

@.planning/BRIEF.md
@.planning/ROADMAP.md
@[relevant existing file 1]
@[relevant existing file 2]

## Tasks

### Task 1: [Name] — [File path]
- **Action:** [Specific action — create/modify/delete + what]
- **Why:** [Why this step is needed]
- **Depends on:** Nothing / Task N
- **Risk:** Low / Medium / High
- **Done when:** [Specific verifiable condition]

### Task 2: [Name] — [File path]
- **Action:** [Specific action]
- **Why:** [Why this step is needed]
- **Depends on:** Task 1
- **Risk:** Low
- **Done when:** [Verifiable condition]

### Task 3: [Name] — [File path]
- **Action:** [Specific action]
- **Why:** [Why]
- **Depends on:** Task 2
- **Risk:** Low
- **Done when:** [Verifiable condition]

## Verification

Before creating SUMMARY.md, verify:
- [ ] [Specific test or check]
- [ ] [Another verification]
- [ ] All tests pass: `[test command]`

## Success Criteria

- [ ] [Specific measurable outcome 1]
- [ ] [Specific measurable outcome 2]
- [ ] No regressions in [related area]

## Output

Create `.planning/phases/{phase}/{phase}-{plan}-SUMMARY.md` when complete.
```

<real_world_example>
## Example: Stripe Integration Plan

```markdown
# Plan: Stripe Webhook Handler

**Phase:** 02-billing
**Plan:** 02-02

## Objective

Create the Stripe webhook handler that keeps subscription status in sync.
This is the core of the billing system — Stripe notifies us of subscription events
and we update our database accordingly.

## Context

@.planning/BRIEF.md
@.planning/ROADMAP.md
@supabase/migrations/004_subscriptions.sql
@src/lib/stripe.ts

## Tasks

### Task 1: Create webhook handler — src/app/api/webhooks/stripe/route.ts
- **Action:** Create POST handler with Stripe signature verification
- **Why:** Server must verify webhook authenticity before processing
- **Depends on:** Nothing
- **Risk:** High — signature verification is security-critical
- **Done when:** Handler validates signatures and returns 200

### Task 2: Handle checkout.session.completed — same file
- **Action:** On successful checkout, upsert subscription record in DB
- **Why:** Payment completed = user should have Pro access immediately
- **Depends on:** Task 1
- **Risk:** Medium
- **Done when:** subscription table updated with correct status

### Task 3: Handle subscription cancellation — same file
- **Action:** Handle customer.subscription.deleted, update status to "canceled"
- **Why:** User cancelled = remove Pro access at period end
- **Depends on:** Task 2
- **Risk:** Low
- **Done when:** Status updated correctly on cancel event

## Verification

- [ ] Stripe CLI test: `stripe trigger checkout.session.completed`
- [ ] DB shows updated subscription record
- [ ] Run: `npm test src/app/api/webhooks/stripe/route.test.ts`
- [ ] No 500 errors in webhook handler

## Success Criteria

- [ ] All three Stripe events handled correctly
- [ ] Webhook signature verification working
- [ ] Tests passing with >80% coverage
- [ ] No regression in existing auth routes

## Output

Create: `.planning/phases/02-billing/02-02-SUMMARY.md`
```
</real_world_example>
