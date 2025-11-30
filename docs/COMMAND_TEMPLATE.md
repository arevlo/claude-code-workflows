# Command Template

Use this template when creating new slash commands.

## Template

```markdown
---
description: Brief description of what this command does
argument-hint: <optional arguments>
allowed-tools: Tool1,Tool2,AskUserQuestion
---

# Command Title

[What this command does - one sentence]

## Configuration

**Setting name:** Default value (customize to match your setup)

## Steps:

1. [Step 1]
2. [Step 2]
3. [Step 3]

## Examples

[Provide examples if helpful]

## Notes

[Any additional notes or requirements]
```

## Guidelines

### Description
- Keep it under 80 characters
- Start with a verb (e.g., "Create", "Generate", "Search")
- Be specific about what it does

### Steps
- Number all steps
- Use code blocks for commands
- Include decision points (if/else)
- Always wait for user confirmation before destructive actions

### Allowed Tools
- Only include tools the command actually needs
- Always include `AskUserQuestion` if command needs user input
- Be specific about Notion tools (e.g., `mcp__notion__notion-search`)

### Configuration
- Document any values users need to customize
- Provide sensible defaults
- Explain what each setting does
