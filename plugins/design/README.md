# Design Toolkit

Slash commands for Figma workflows - Make prompts, FigJam diagrams, and MCP setup.

## Installation

```
/plugin marketplace add arevlo/claude-code-workflows
/plugin install design@claude-code-workflows
```

## What's Included

### Commands
- `/make` - Create or update prompts/changelogs in Notion for Figma Make
- `/figjam-presentation` - Create a FigJam flowchart for a presentation outline or slide map
- `/figma-console-setup` - Set up the Figma Console MCP server (token, config, Desktop Bridge plugin)

## Requirements

| Command | Requirements |
|---------|-------------|
| `/make` | Notion MCP server, Notion database for prompts/changelogs |
| `/figjam-presentation` | Figma MCP server (`claude_ai_Figma`) |
| `/figma-console-setup` | Node.js 18+, Figma Desktop |

## /make Workflow

1. Create detailed spec in Notion
2. Run `/make` to create a prompt referencing the spec
3. Use the prompt in Figma Make
4. Run `/make` again for follow-up iterations
5. Update changelog with `/make` (select Changelog type)

### Prompt Guidelines

When creating prompts for Figma Make:
- Specify **full file paths** (e.g., `src/components/` not `components/`)
- Note file sizes if large (>30KB)
- List ALL files that need modification together
- Provide exact code snippets to insert
- Include verification steps
- Link to related context/specs in Notion

## /figjam-presentation Workflow

1. Describe your presentation outline or slide structure
2. The command generates a Mermaid flowchart with slide nodes and speaker notes
3. Click the returned URL to claim the new FigJam file
4. Rearrange nodes in FigJam for final layout

## /figma-console-setup Workflow

1. Run `/figma-console-setup` to start the guided setup
2. The command scans your environment (platform, shell, Node.js, Figma Desktop, token)
3. Walks through token creation, MCP registration, and Desktop Bridge plugin import
4. Verifies the connection end-to-end
