# Claude Code Workflows

A curated collection of Claude Code plugins with slash commands for design-to-code workflows, context management, and development best practices.

## Installation

```bash
# Add the marketplace
/plugin marketplace add arevlo/claude-code-workflows

# Install individual plugins
/plugin install figma-make-toolkit@claude-code-workflows
/plugin install notion-context-management@claude-code-workflows
/plugin install dev-workflows@claude-code-workflows
```

## Plugins

### figma-make-toolkit

Slash commands for Figma Make design-to-code workflows.

- `/make` - Create or update prompts/changelogs in Notion for Figma Make

### notion-context-management

Slash commands for saving/loading Claude Code session context to Notion.

- `/save-context` - Save session to Notion
- `/load-context` - Load prior context
- `/context-reminder` - Reminder to save before ending

**Customizable** - Update database names to match your setup

### dev-workflows

Git commit workflows and development best practices.

- `/commit` - Full commit workflow with branch management
- `/pr-describe` - Generate/update PR descriptions
- `/pr-review` - Request AI code review

## Workflow Overview

```
+-------------------------------------------------------------+
|                     DESIGN WORKFLOW                          |
+-------------------------------------------------------------+
|                                                              |
|  1. Create Spec     ->  Notion database                     |
|                                                              |
|  2. Create Prompt   ->  /make                               |
|                                                              |
|  3. Implement       ->  Figma Make                          |
|                                                              |
|  4. Iterate         ->  Follow-up prompts                   |
|                                                              |
|  5. Commit          ->  /commit                             |
|                                                              |
|  6. Save Context    ->  /save-context                       |
|                                                              |
+-------------------------------------------------------------+
```

## Requirements

- **Claude Code** with plugin support
- **Notion MCP server** (for Notion-related plugins)
- **GitHub CLI** (`gh`) (for dev-workflows)

## Customization

Most plugins reference specific Notion database names and data source IDs. Update these in the command files to match your own setup:

1. Database names (default: `_make`, `_clawd`)
2. Data source IDs
3. Project name mappings

## Contributing

See [docs/ADDING_PLUGINS.md](docs/ADDING_PLUGINS.md) for how to add new plugins.

## License

MIT
