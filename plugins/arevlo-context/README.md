# Context Management

Slash commands for saving and loading Claude Code session context and plans to multiple destinations.

## Installation

```
/install arevlo-context@arevlo/claude-code-workflows
```

## What's Included

### Commands
- `/save-context` - Save current session to multiple destinations
- `/load-context` - Search and load prior context from multiple sources
- `/context-status` - Check current context state and recent saves
- `/plan` - Load, save, or browse Claude Code plans

## Storage Destinations

| Destination | Description |
|-------------|-------------|
| Local /tmp | Quick, ephemeral markdown files in `/tmp/claude-contexts/` |
| Swarm checkpoints | Auto checkpoints in `.claude/swarm/progress/` (load only) |
| Notion | Persistent storage in your Notion database |
| GitHub Issue | Create an issue in the current repo for tracking |
| Docs folder | Save to `./docs/context/` in your project |
| Claude Plans | Plans from `~/.claude/plans/` |

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

### Check Context Status
```
/context-status
```
- Shows recent saves in `/tmp/claude-contexts/`
- Shows swarm progress checkpoints
- Shows active `/auto` sessions
- Shows recent swarm reports

### Continue a Plan
```
/plan
```
- Shows recent plans from `~/.claude/plans/` with titles and summaries
- Select a plan to load and continue working on it

```
/plan latest
```
- Quickly loads the most recently modified plan

```
/plan save
```
- Saves current plan to chosen destination (local, Notion, GitHub)
- Use before running out of context to preserve your work

```
/plan search <query>
```
- Search plans across all sources by keyword

## Customization

Update the database name and data source ID in the command files to match your own Notion setup.
