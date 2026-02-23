# Simple Skill Template

Copy this template and fill in the sections:

```yaml
---
name: your-skill-name
description: What this skill does and when to use it. Be specific about triggers.
---

<objective>
One paragraph describing what this skill accomplishes and why it exists.
</objective>

<quick_start>
The most common use case, immediately actionable. Skip explanation and get to the point.
</quick_start>

<process>
1. First step — specific action
2. Second step — specific action
3. Third step — specific action
4. Verify result
</process>

<success_criteria>
- [ ] Specific measurable outcome 1
- [ ] Specific measurable outcome 2
- [ ] Works correctly in the target context
</success_criteria>
```

**Cursor .mdc equivalent:**
```yaml
---
description: What this skill does and when to use it.
globs: ["**/*"]     # Adjust to target file types
alwaysApply: false  # true if always relevant
---

<same content body>
```
