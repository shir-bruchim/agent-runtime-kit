# Universal Skill Template

## Description
[Brief 1-2 sentence description of what this skill does]

## Platform Compatibility
- ✅ Claude: Full support
- ✅ Cursor: Full support  
- ✅ Generic: Basic support

## Trigger Conditions
This skill should be used when:
- [Condition 1: e.g., "User uploads a specific file type"]
- [Condition 2: e.g., "User asks for specific analysis"]
- [Condition 3: e.g., "Keywords detected"]

## Platform-Specific Adaptations

### Claude
- Can use: `web_search`, `create_file`, `view`, `bash_tool`
- Can create: Documents (DOCX, PDF, PPTX)
- Can access: Uploaded files in `/mnt/user-data/uploads`

### Cursor
- Can use: Workspace API, LSP, File system
- Can create: Code files, configurations
- Can access: Project files, Git history

### Generic
- Can use: Basic text processing
- Can create: Simple files
- Can access: Provided inputs only

## Instructions

### Universal Steps (All Platforms)
1. **Initial Assessment**
   - Understand the request
   - Identify input type
   - Determine expected output

2. **Core Processing**
   - [Step 1: What to do]
   - [Step 2: What to do]
   - [Step 3: What to do]

3. **Output Generation**
   - Format results appropriately
   - Adapt to platform capabilities

4. **Validation**
   - Verify output quality
   - Check completeness

### Platform-Specific Steps

#### For Claude:
```markdown
1. Use `view` tool to read uploaded files
2. Use `web_search` if external information needed
3. Use `create_file` to generate outputs
4. Save to `/mnt/user-data/outputs/`
```

#### For Cursor:
```markdown
1. Use workspace API to read project files
2. Use LSP for code intelligence
3. Create files in project structure
4. Integrate with Git if needed
```

#### For Generic:
```markdown
1. Process provided text/data
2. Generate output in requested format
3. Return results in standard format
```

## Tools & Requirements

### Universal Requirements
- Text processing capabilities
- Basic file operations (read/write)

### Claude-Specific Tools
```bash
# Tools available
- view: Read files
- create_file: Create new files
- str_replace: Edit existing files
- bash_tool: Run commands
- web_search: Search the web
```

### Cursor-Specific Tools
```javascript
// APIs available
- workspace.fs: File system operations
- languages: LSP integration
- terminal: Terminal access
- git: Git operations
```

## Examples

### Example 1: Universal Use Case

**User Request (Any Platform):**
```
[Example user message]
```

**Claude Approach:**
```
1. Use view to read file
2. Process content
3. Create output file
4. Return link to user
```

**Cursor Approach:**
```
1. Read from workspace
2. Process content
3. Create file in project
4. Show in editor
```

**Generic Approach:**
```
1. Process input text
2. Format output
3. Return as text
```

### Example 2: Platform-Specific Optimization

**For Claude:**
```
If research needed:
  - Use web_search
  - Gather comprehensive information
  - Create detailed document
```

**For Cursor:**
```
If code context needed:
  - Use LSP to understand codebase
  - Analyze related files
  - Generate contextual suggestions
```

## Output Formats

### Claude
- DOCX files
- PDF files
- Markdown files
- PPTX presentations

### Cursor
- Code files (.js, .py, .ts, etc.)
- Configuration files
- Markdown documentation
- Test files

### Generic
- Plain text
- Markdown
- JSON
- CSV

## Best Practices

### Universal Best Practices
- ✅ Clear, step-by-step instructions
- ✅ Validate inputs before processing
- ✅ Provide clear error messages
- ✅ Document assumptions

### Platform-Specific Tips

**Claude:**
- 💡 Use skills from `/mnt/skills/public/` when applicable
- 💡 Check for existing uploads before asking
- 💡 Create files in outputs directory

**Cursor:**
- 💡 Respect workspace structure
- 💡 Follow project conventions
- 💡 Use existing configurations

**Generic:**
- 💡 Minimize external dependencies
- 💡 Provide detailed instructions
- 💡 Handle edge cases gracefully

## Error Handling

### Universal Errors
**Error:** [Common error]
**Solution:** [How to handle across platforms]

### Platform-Specific Errors

**Claude:**
- Error: File not found
- Solution: Check `/mnt/user-data/uploads/`

**Cursor:**
- Error: Workspace not initialized
- Solution: Check project root

**Generic:**
- Error: Insufficient input
- Solution: Request more information

## Testing Checklist

- [ ] Works on Claude (test with uploaded file)
- [ ] Works on Cursor (test in workspace)
- [ ] Works generically (test with text input)
- [ ] Handles errors gracefully
- [ ] Output is appropriate for each platform
- [ ] Documentation is clear

## Related Skills
- `[related-skill-1]` - [When to use]
- `[related-skill-2]` - [When to use]

## Maintenance
- **Version:** 1.0
- **Last Updated:** YYYY-MM-DD
- **Compatible With:** Claude 4.5+, Cursor 0.40+, Generic AI
- **Changelog:**
  - v1.0: Initial universal version

---

## Notes for AI Assistants

When using this skill:

1. **Detect your platform first** (read AI-DETECTION.md)
2. **Load platform-specific instructions** (see above)
3. **Use available tools only** (check capabilities)
4. **Adapt output format** (match platform)
5. **Follow best practices** (platform-specific)

**Remember:** This skill should work everywhere, but optimize for your specific platform!
