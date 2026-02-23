# Workflow: Get Guidance

<purpose>
Help the user decide which planning approach fits their situation.
Use when the user says "help", "guidance", or isn't sure where to start.
</purpose>

<process>

<step name="assess_situation">
Ask:
"What are you working on? Give me a brief description and I'll recommend the right approach."

Listen for signals:
- "New project / greenfield" → full brief + roadmap
- "Existing project, new feature" → PRD + plan
- "I know what to build, just need a plan" → skip to plan-phase
- "Refactor / tech debt" → plan-phase directly
- "Not sure if I should build this" → brief only, no roadmap yet
</step>

<step name="recommend">
Based on what they describe, recommend one of:

**Option A: Full project setup** (new greenfield project)
"Let's create a brief + roadmap. This takes ~10 minutes and gives you a clear path from start to first release."
→ Route to create-brief.md, then create-roadmap.md

**Option B: Feature planning** (adding to existing project)
"Let's write a PRD first to nail the requirements, then create an implementation plan."
→ Route to create-prd.md, then plan-phase.md

**Option C: Direct planning** (you know what to build)
"Let's write the execution plan directly. I'll ask a few questions to make it precise."
→ Route to plan-phase.md

**Option D: Brief only** (validate the idea first)
"Let's write a brief to capture the vision. We can plan later once the idea is solid."
→ Route to create-brief.md
</step>

<step name="confirm_and_route">
"Does that approach work for you, or would you prefer something different?"
Wait for confirmation, then route to the appropriate workflow.
</step>

</process>

<success_criteria>
User understands the recommended approach and agrees to proceed.
Routed to the correct workflow with clear context.
</success_criteria>
