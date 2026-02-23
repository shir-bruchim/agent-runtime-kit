---
name: debugging
description: Deep analysis debugging mode for complex issues. Activates methodical investigation with evidence gathering, hypothesis testing, and rigorous verification. Use when standard troubleshooting fails or issues require systematic root cause analysis.
---

<objective>
Methodical debugging using scientific method: gather evidence, form hypotheses, test systematically, verify fixes. Treats code you wrote with MORE skepticism than unfamiliar code — cognitive bias about "how it should work" is the enemy of debugging.
</objective>

<core_principle>
VERIFY, DON'T ASSUME. Every hypothesis must be tested. Every fix must be validated. No solutions without evidence.

Code you designed or wrote is guilty until proven innocent. Your intent doesn't matter — only the code's actual behavior.
</core_principle>

<evidence_gathering>
Before proposing any solution:

**A. Document Current State**
- What is the EXACT error message?
- What are the EXACT reproduction steps?
- What is ACTUAL vs EXPECTED output?
- When did this start?

**B. Map the System**
- Trace execution path from entry point to failure
- Identify all components involved
- Read relevant source files completely (don't skim)
- Note all dependencies, imports, configurations

**C. Gather External Knowledge (when needed)**
- Search for exact error messages
- Check library/framework docs for intended behavior
- Look for known issues, breaking changes, version quirks
</evidence_gathering>

<root_cause_analysis>
**A. Form Hypotheses**
List possible causes with evidence:
1. [Hypothesis] — because [specific evidence]
2. [Hypothesis] — because [specific evidence]

**B. Test Each Hypothesis**
For each:
- What would prove this true?
- What would prove this false?
- Design minimal test
- Document results

**C. Eliminate or Confirm**
Don't proceed until: which hypothesis is supported by evidence? What evidence contradicts others?
</root_cause_analysis>

<solution_development>
Only after confirming root cause:

1. **Design** — What is the MINIMAL change that addresses the root cause?
2. **Implement** — Make the change with verification logging if needed
3. **Test** — Does the original issue still occur? Run reproduction steps. Check for regressions.
</solution_development>

<critical_rules>
1. NO DRIVE-BY FIXES: If you can't explain WHY a change works, don't make it
2. ONE VARIABLE: Change one thing at a time, verify, then proceed
3. COMPLETE READS: Don't skim code. Read entire relevant files.
4. CHASE DEPENDENCIES: If libraries/configs/external systems are involved, investigate those too
5. QUESTION PREVIOUS WORK: Maybe the earlier "fix" was wrong. Re-examine with fresh eyes
</critical_rules>

<output_format>
```markdown
## Issue: [Problem Description]

### Evidence
[Exact errors, behaviors, outputs observed]

### Investigation
[What you checked, found, and ruled out]

### Root Cause
[The actual underlying problem + evidence]

### Solution
[What you changed and WHY it addresses the root cause]

### Verification
[How you confirmed it works and doesn't break anything else]
```
</output_format>

<success_criteria>
- [ ] Root cause identified with evidence (not just "it works now")
- [ ] Fix verified against original reproduction steps
- [ ] Adjacent functionality checked for regressions
- [ ] Can explain the solution to another developer
- [ ] Would pass code review scrutiny
</success_criteria>

<reference_index>
All in `references/`:
- **debugging-mindset.md** — Cognitive biases, first-principles thinking
- **hypothesis-testing.md** — Forming and testing falsifiable hypotheses
- **investigation-techniques.md** — Binary search, minimal reproduction, rubber duck
- **verification-patterns.md** — What "verified" actually means
</reference_index>
