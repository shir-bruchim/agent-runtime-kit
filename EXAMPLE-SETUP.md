# Example: Complete Setup for a Developer

This is a complete example showing how to set up the AI Config System for a typical developer workflow.

## Scenario

You're a full-stack developer who:
- Uses Claude for research and documentation
- Uses Cursor for coding
- Wants to streamline code reviews, testing, and documentation

## Step 1: Installation

```bash
# Clone the repo
git clone https://github.com/your-username/agent-runtime-kit.git

# Run auto-setup
cd agent-runtime-kit
./scripts/setup.sh

# Output: "Platform detected: claude" or "Platform detected: cursor"
```

## Step 2: Create Your First Universal Skill

```bash
# Create a code review skill that works on both platforms
nano skills/universal/code-review-basic.md
```

```markdown
# Basic Code Review

## Description
Quick code review checking for common issues

## Platform Compatibility
- ✅ Claude: Full analysis with web research
- ✅ Cursor: LSP-powered deep analysis
- ✅ Generic: Pattern-based review

## Trigger Conditions
- User uploads code files (.py, .js, .ts, .go)
- User requests code review
- Keywords: "review", "check my code"

## Instructions

### Universal Steps
1. Read the code
2. Check for:
   - Syntax errors
   - Code smells
   - Security issues
   - Performance problems
3. Generate findings report

### Claude-Specific
- Use web_search for best practices
- Create formatted DOCX report
- Include examples from online sources

### Cursor-Specific
- Use LSP for type checking
- Check against workspace conventions
- Provide inline code actions
- Suggest refactorings

## Examples

### Claude Example
Input: Python file uploaded
Output: Detailed DOCX report with:
- Executive summary
- Issue-by-issue breakdown
- Links to best practices
- Code examples

### Cursor Example
Input: TypeScript file saved
Output: Inline suggestions:
- ⚠️ Line 42: Unused variable
- 💡 Line 55: Can be simplified
- 🔒 Line 67: Security issue
