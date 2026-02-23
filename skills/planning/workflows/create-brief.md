# Workflow: Create Brief

<purpose>
Create a project vision document that captures what we're building and why.
This is the only human-focused document — everything else is for the agent.
</purpose>

<process>

<step name="gather_vision">
Ask the user conversationally (not all at once):
1. What are we building? (one sentence)
2. Why does this need to exist? (the problem)
3. What does success look like?
4. Any hard constraints? (tech stack, timeline, dependencies)
5. What are we explicitly NOT building?
</step>

<step name="confirm_and_create">
After gathering context, confirm:
"Ready to create the brief, or do you want to add more context?"

Create `.planning/` directory if needed:
```bash
mkdir -p .planning
```

Write `.planning/BRIEF.md` using `templates/brief.md`.
Keep under 50 lines. This is a reference, not a novel.
</step>

<step name="offer_next">
```
Brief created: .planning/BRIEF.md

What's next?
1. Create roadmap now (recommended — commits brief + roadmap together)
2. Review/edit brief first
3. Done for now
```
</step>

</process>

<anti_patterns>
- Don't write a business plan or requirements spec
- Don't add sections beyond: problem, success criteria, constraints, out of scope
- Don't estimate timelines
- Don't list stakeholders or team members
</anti_patterns>

<success_criteria>
BRIEF.md exists with problem, success criteria, constraints, and out-of-scope.
Under 50 lines. Readable in 2 minutes.
</success_criteria>
