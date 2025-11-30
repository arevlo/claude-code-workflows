# Notion Context Management

Slash commands for saving and loading Claude Code session context to Notion.

## Installation

```
/plugin marketplace add arevlo/claude-code-workflows
/plugin install notion-context-management@claude-code-workflows
```

## What's Included

### Commands
- `/save-context` - Save current session to Notion
- `/load-context` - Search and load prior context
- `/context-reminder` - Reminder to save before ending session

## Configuration Required

This plugin requires:
1. **Notion MCP server** configured in Claude Code
2. **Notion database** for storing contexts (default name: `_clawd`)
3. Update the data source ID in the commands to match your database

### Database Schema

Your Notion database should have these properties:
- **Name** (title) - Session/context title
- **Project** (select) - Project name
- **Tags** (multi-select) - Context, Summary, Spec, Reference

## Usage

### End of Session
```
/save-context
```
- Detects project from working directory
- Asks for tag type and title
- Generates comprehensive session summary
- Creates page in Notion

### Start of Session
```
/load-context [project or topic]
```
- Searches your context database
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
