# Context Management

Slash commands for saving and loading Claude Code session context to multiple destinations.

## Installation

```
/install arevlo-context@arevlo/claude-code-workflows
```

## What's Included

### Commands
- `/save-context` - Save current session to multiple destinations
- `/load-context` - Search and load prior context from multiple sources
- `/context-reminder` - Reminder to save before ending session

## Storage Destinations

| Destination | Description |
|-------------|-------------|
| Local /tmp | Quick, ephemeral markdown files in `/tmp/claude-contexts/` |
| Notion | Persistent storage in your Notion database |
| GitHub Issue | Create an issue in the current repo for tracking |
| Docs folder | Save to `./docs/context/` in your project |

## Requirements

### Notion (optional)
- **Notion MCP server** configured in Claude Code
- **Notion database** for storing contexts (default name: `_clawd`)

Your Notion database should have these properties:
- **Name** (title) - Session/context title
- **Project** (select) - Project name
- **Tags** (multi-select) - Context, Summary, Spec, Reference

### GitHub CLI (optional)

If you want to save context to GitHub Issues, install the GitHub CLI:

**macOS:**
```bash
brew install gh
```

**Ubuntu/Debian:**
```bash
sudo apt install gh
```

**Windows:**
```bash
winget install GitHub.cli
```

After installing, authenticate:
```bash
gh auth login
```

## Usage

### End of Session
```
/save-context
```
- Detects project from working directory
- Asks where to save (local, Notion, GitHub, docs)
- Asks for tag type and title
- Generates comprehensive session summary
- Saves to selected destination

### Start of Session
```
/load-context [search query]
```
- Asks which source to search
- Searches your selected source
- Shows matching results
- Lets you select and view full content

### Before Ending
```
/context-reminder
```
- Quick reminder to save your work
- Prompts to run /save-context

## Customization

Update the database name and data source ID in the command files to match your own Notion setup.
