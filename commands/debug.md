---
description: Start systematic debugging of an issue using the debugging skill
argument-hint: [error message or issue description]
---

<objective>
Debug "$ARGUMENTS" using systematic root-cause analysis.
</objective>

<process>
1. Activate the debugging skill's investigation protocol
2. Gather evidence: exact error, reproduction steps, actual vs expected
3. Map the execution path to identify where failure occurs
4. Form 2-3 hypotheses with supporting evidence
5. Test each hypothesis systematically (one change at a time)
6. Identify root cause with evidence
7. Implement minimal fix and verify it resolves the issue
</process>

<success_criteria>
- Root cause identified with evidence (not just "it works now")
- Fix implemented and verified against original reproduction steps
- No regressions introduced
</success_criteria>
