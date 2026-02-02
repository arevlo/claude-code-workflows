# Obsidian Capture Plugin

Capture screenshots and context directly to your Obsidian Zettelkasten vault as fragment notes.

## Commands

### `/obsidian:capture` (or `/obs-capture`)

Capture a screenshot with context and create a fragment note in your Obsidian vault.

**Usage:**
```
/obsidian:capture [folder]

# Or with shorthand:
/obs-capture flow
```

**What it does:**
1. Analyzes any screenshot you've shared in the conversation
2. Prompts for folder (flow, ai, personal, etc.) if not provided
3. Asks for a topic-based title
4. Copies the screenshot to `{vault}/{folder}/_attachments/{topic}.png`
5. Creates a fragment note with the screenshot embedded, your analysis, and any external links
6. Returns the path to the created note

**Example workflow:**
```
User: [Pastes screenshot from Slack]
      https://life-in-flow.slack.com/archives/C123/p456

/obs-capture flow

Claude: What topic should I use for the filename?
User: property-filters-discussion

Claude: ✓ Fragment note created: flow/property-filters-discussion.md
        ✓ Screenshot saved: flow/_attachments/property-filters-discussion.png
```

## Configuration

The plugin expects your Obsidian vault at:
```
/Users/arevlo/Library/Mobile Documents/com~apple~CloudDocs/zk
```

To change this, edit the `VAULT_PATH` in `commands/capture.md`.

## Installation

This plugin is part of the `claude-code-workflows` marketplace.

1. Make sure your `~/.claude.json` includes this marketplace:
```json
{
  "extraKnownMarketplaces": {
    "claude-code-workflows": {
      "source": {
        "source": "directory",
        "path": "/Users/arevlo/Desktop/personal-repos/claude-code-workflows"
      }
    }
  }
}
```

2. Enable the plugin in `~/.claude/settings.json`:
```json
{
  "enabledPlugins": {
    "obsidian@claude-code-workflows": true
  }
}
```

3. Restart Claude Code or run `/plugins refresh`

## Requirements

- **Obsidian MCP server** must be configured and running
- Screenshots must be pasted into Claude Code (they're auto-cached in `~/.claude/image-cache/`)
- Your Obsidian vault must be accessible at the configured path

## Fragment Workflow

Fragments are temporary captures in the Zettelkasten method:
1. **Capture** - Quickly save ideas/screenshots (this plugin)
2. **Process** - Review and convert to atomic primitives
3. **Connect** - Link primitives to build knowledge graph

Use `mcp__obsidian-zettelkasten__process_fragment` to convert fragments to primitives later.

## Version History

- **1.0.0** - Initial release with screenshot capture to fragment notes
