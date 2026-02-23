# Workflow: Resume from Handoff

<purpose>
Load a handoff file and restore context to continue interrupted work.
</purpose>

<process>

<step name="find_handoff">
Find handoff files:
```bash
find . -name ".continue-here*.md" -type f
```
</step>

<step name="load_context">
Read the handoff file completely.
Then load all @referenced files.
Run context scan to check current git state.
</step>

<step name="confirm_state">
Present to user:
"Found handoff from [date].
Status: [status from handoff]
Next step: [next step from handoff]

Ready to resume, or want to review the plan first?"
</step>

<step name="resume_work">
Continue from the exact point in the handoff.
If handoff says "next step: Task 2 in 01-02-PLAN.md" → load that plan and continue from Task 2.
</step>

<step name="clean_up_handoff">
After resuming successfully, delete or archive the handoff file:
```bash
rm .planning/phases/{phase}/.continue-here-{phase}-{plan}.md
```
</step>

</process>

<success_criteria>
Context fully restored. Work resumed from exact stopping point.
Handoff file cleaned up after successful resume.
</success_criteria>
