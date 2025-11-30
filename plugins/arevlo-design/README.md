# Figma Make Toolkit

Slash commands for Figma Make design-to-code workflows.

## Installation

```
/plugin marketplace add arevlo/claude-code-workflows
/plugin install figma-make-toolkit@claude-code-workflows
```

## What's Included

### Commands
- `/make` - Create or update prompts/changelogs in Notion for Figma Make

## Configuration Required

This plugin requires:
1. **Notion MCP server** configured in Claude Code
2. **Notion database** for storing prompts and changelogs
3. Update the data source ID in the command to match your database

## Workflow

1. Create detailed spec in Notion
2. Run `/make` to create a prompt referencing the spec
3. Use the prompt in Figma Make
4. Run `/make` again for follow-up iterations
5. Update changelog with `/make` (select Changelog type)

## Prompt Guidelines

When creating prompts for Figma Make:
- Specify **full file paths** (e.g., `src/components/` not `components/`)
- Note file sizes if large (>30KB)
- List ALL files that need modification together
- Provide exact code snippets to insert
- Include verification steps
- Link to related context/specs in Notion
