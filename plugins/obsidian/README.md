# Obsidian Plugin

Capture screenshots and context to your Obsidian Zettelkasten vault as fragment notes. Save external links to note tables. Interactively study complex documents with Q&A. Add Confluence document summaries to project files.

## Commands

### `/arevlo:obsidian:capture`

Capture a screenshot with context and create a fragment note in your Obsidian vault.

**Usage:**
```
/arevlo:obsidian:capture [category]

# Example:
/arevlo:obsidian:capture ai
```

**What it does:**
1. Analyzes any screenshot you've shared in the conversation
2. Prompts for category if not provided
3. Asks for a topic-based title
4. Creates a `{category}/fragments/` subfolder if it doesn't exist
5. Copies the screenshot to `{category}/fragments/_attachments/{topic}.png`
6. Creates a fragment note with the screenshot embedded, your analysis, and any external links
7. Returns the path to the created note

### `/arevlo:obsidian:save-link`

Save external links to an Obsidian note's external links table. Creates the note if it doesn't exist.

**Usage:**
```
/arevlo:obsidian:save-link <url> [note-path]

# Examples:
/arevlo:obsidian:save-link https://anthropic.com
/arevlo:obsidian:save-link https://example.com/article ai/outlinks
```

**What it does:**
1. Accepts a URL and optional note path as arguments
2. Prompts for a descriptive title for the link
3. Prompts for the note path if not provided (e.g., "ai/outlinks", "resources")
4. Optionally asks for tags and notes/context
5. Saves the link to the note's external links table
6. Creates the note if it doesn't exist
7. Auto-generates a source tag from the URL domain (e.g., "source/anthropic")

### `/arevlo:obsidian:study`

Interactively break down and study complex documents (TDDs, specs, architecture docs) with Q&A, saving session notes to your Obsidian vault.

**Usage:**
```
/arevlo:obsidian:study [confluence-url or file-path]
```

**What it does:**
1. Fetches the document content (Confluence or local file)
2. Parses it into logical sections and presents an outline
3. Walks through each section interactively with summaries and Q&A
4. Tracks all questions and answers from the session
5. Generates a study session note with summaries, key points, Q&A, and takeaways
6. Saves the note to your Obsidian vault

### `/arevlo:obsidian:project-doc`

Add a Confluence document summary (TDD, PRD, Design Doc, RFC, Spec) to a project file.

**Usage:**
```
/arevlo:obsidian:project-doc [confluence-url] [optional:project-name]
```

**What it does:**
1. Fetches the Confluence page content and metadata
2. Auto-detects the document type (TDD, PRD, Design, RFC, Spec) from the title
3. Asks which platform section (Web/Mobile) and document status
4. Generates a one-line description, author attribution, and dense 3-6 sentence summary
5. Creates a new project file with the full template, or appends the section to an existing one

## Configuration

Configuration is stored in `~/.claude/obsidian-plugin.json`. On first use, any command will prompt you to set up your vault path.

| Field | Used By | Description |
|-------|---------|-------------|
| `vault_path` | All commands | Absolute path to your Obsidian vault |

To reconfigure, edit `~/.claude/obsidian-plugin.json` directly.

## Installation

This plugin is part of the `claude-code-workflows` marketplace.

1. Add the marketplace to `~/.claude.json`:
```json
{
  "extraKnownMarketplaces": {
    "claude-code-workflows": {
      "source": {
        "source": "github",
        "owner": "arevlo",
        "repo": "claude-code-workflows"
      }
    }
  }
}
```

2. Enable the plugin in `~/.claude/settings.json`:
```json
{
  "enabledPlugins": {
    "arevlo:obsidian@claude-code-workflows": true
  }
}
```

3. Restart Claude Code or run `/plugins refresh`

## Requirements

- Screenshots must be pasted into Claude Code (they're auto-cached in `~/.claude/image-cache/`)
- Your Obsidian vault must be accessible at the configured path
- For `/study` and `/project-doc`: Atlassian MCP server for Confluence access

## Fragment Workflow

Fragments are temporary captures in the Zettelkasten method:
1. **Capture** - Quickly save ideas/screenshots (this plugin)
2. **Process** - Review and convert to atomic primitives
3. **Connect** - Link primitives to build knowledge graph

## Version History

- **1.6.0** - Added `/arevlo:obsidian:study` and `/arevlo:obsidian:project-doc` commands
- **1.2.0** - Added `/arevlo:obsidian:save-link` command for saving external links to notes
- **1.0.0** - Initial release with screenshot capture to fragment notes
