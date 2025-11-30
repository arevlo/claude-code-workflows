# Claude Code Workflows

A curated collection of Claude Code plugins with slash commands for design-to-code workflows, context management, and development best practices.

## Installation

### Add Marketplace

1. Run `/plugin` and select **Add Marketplace**
2. Enter marketplace source: `arevlo/claude-code-workflows`

Or use the command directly:
```bash
/plugin marketplace add arevlo/claude-code-workflows
```

### Install Plugins

```bash
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

## Workflows

### Design Workflow (Figma Make)

```
Claude Code               Notion                  Figma Make
    |                       |                         |
    |-- Create spec ------->|                         |
    |                       |                         |
    |-- /save-context ----->| (save as Spec)          |
    |                       |                         |
    |-- /make ------------->| (reference spec) ------>|
    |                       |                         |
    |                       |<-- iterate -------------|
    |                       |                         |
    |                       |<-- push to GitHub ------|
```

1. **Create Spec** - Give Claude Code instructions for the feature/design
2. **Save as Spec** - `/save-context` with "Spec" tag type
3. **Create Prompt** - `/make` references the saved spec
4. **Iterate** - Use Figma Make to implement and refine

> **Note:** Figma Make pushes directly to GitHub. Committing happens separately in Claude Code.

### Commit Workflow

```
/commit
```

Run after Figma Make pushes changes (or any code changes):
- Stage and commit changes
- Update PR description if PR exists
- Push with confirmation

### Context Management

| Command | Purpose |
|---------|---------|
| `/save-context` | Save session context to Notion |
| `/load-context <query>` | Search and load prior contexts |
| `/context-reminder` | Reminder to save before ending |

### PR Workflows

| Command | Purpose |
|---------|---------|
| `/pr-describe` | Generate/update PR description |
| `/pr-review` | Request @claude or @codex review |

## Requirements

- **Claude Code** with plugin support
- **[Notion MCP server](https://www.notion.com/help/notion-mcp)** (for Notion-related plugins)
- **[GitHub CLI](https://cli.github.com/)** (`gh`) (for dev-workflows)

### Notion MCP Setup

Add to your `~/.claude/.claude.json` under `mcpServers`:

```json
"notion": {
  "type": "http",
  "url": "https://mcp.notion.com/mcp"
}
```

Then authenticate via Notion when prompted.

### GitHub CLI Setup

```bash
# Install
brew install gh

# Authenticate
gh auth login
```

## Customization

Most plugins reference specific Notion database names and data source IDs. Update these in the command files to match your own setup:

1. Database names (default: `_make`, `_clawd`)
2. Data source IDs
3. Project name mappings

## Contributing

See [docs/ADDING_PLUGINS.md](docs/ADDING_PLUGINS.md) for how to add new plugins.

## License

MIT
