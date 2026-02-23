# Core Principles for AI Skills

## 1. Skills Are Prompts

Everything you know about writing good prompts applies to skills:
- Be clear and specific about what you want
- Give context but don't over-explain
- Structure information logically
- State the goal, not the process (unless the process is the goal)

**Bad:**
```
Help with code stuff
```

**Good:**
```
<objective>
Review the code changes for security vulnerabilities, specifically:
SQL injection, XSS, authentication issues, and sensitive data exposure.
Output findings with file:line references and severity ratings.
</objective>
```

## 2. Assume Intelligence

Skills are consumed by capable AI models. Don't:
- Over-explain obvious concepts
- Add excessive caveats
- Repeat the same instruction in multiple ways
- Include information the model already has

Do:
- Add domain-specific context the model might not have
- Clarify ambiguous terms in your domain
- Provide examples when the format is non-obvious

## 3. Progressive Disclosure

Load context progressively. Don't dump everything at once:

```
Level 1 (SKILL.md): Essential principles + routing         ~3k tokens
Level 2 (workflow): Specific steps for current task        ~2k tokens  
Level 3 (references): Deep knowledge when needed           ~3k tokens each
```

Users/agents load what they need, when they need it.

## 4. XML Structure for Clarity

XML tags create semantic clarity and improve model parsing:

```xml
<objective>What to accomplish</objective>
<process>How to do it</process>
<success_criteria>How to know it's done</success_criteria>
```

vs markdown headings which blend in with document structure.

## 5. Verification Built-In

Good skills include success criteria:
```xml
<success_criteria>
- [ ] All test files have been created
- [ ] Tests pass with `pytest -v`
- [ ] Coverage is above 80%
- [ ] No skipped tests without documented reason
</success_criteria>
```

This makes it clear when the task is actually complete.

## 6. Minimal Clarifying Questions

Ask clarifying questions only when:
- Multiple fundamentally different approaches exist
- User intent is genuinely ambiguous
- A wrong choice would require significant rework

Don't ask when:
- You can make a reasonable default choice
- The question is trivial
- You can do it both ways and show the difference
