# Obsidian Plugin

Capture screenshots, manage notes, run digests, and maintain your Obsidian Zettelkasten vault from Claude Code.

## Commands

### `/obsidian:capture`

Capture a screenshot with context and create a fragment note in your Obsidian vault.

**Usage:**
```
/obsidian:capture [category]

# Example:
/obsidian:capture flow
```

**What it does:**
1. Analyzes any screenshot you've shared in the conversation
2. Prompts for category (flow, ai, personal, etc.) if not provided
3. Asks for a topic-based title
4. Creates a `{category}/fragments/` subfolder if it doesn't exist
5. Copies the screenshot to `{category}/fragments/_attachments/{topic}.png`
6. Creates a fragment note with the screenshot embedded, your analysis, and any external links
7. Returns the path to the created note

**Example workflow:**
```
User: [Pastes screenshot from Slack]
      https://your-workspace.slack.com/archives/C123/p456

/obsidian:capture flow

Claude: What topic should I use for the filename?
User: property-filters-discussion

Claude: ✓ Fragment note created: flow/fragments/property-filters-discussion.md
        ✓ Screenshot saved: flow/fragments/_attachments/property-filters-discussion.png
```

### `/obsidian:save-link`

Save external links to an Obsidian note's external links table. Creates the note if it doesn't exist.

**Usage:**
```
/obsidian:save-link <url> [note-path]

# Examples:
/obsidian:save-link https://anthropic.com
/obsidian:save-link https://example.com/article ai/outlinks
```

**What it does:**
1. Accepts a URL and optional note path as arguments
2. Prompts for a descriptive title for the link
3. Prompts for the note path if not provided (e.g., "ai/outlinks", "resources")
4. Optionally asks for tags and notes/context
5. Saves the link to the note's external links table
6. Creates the note if it doesn't exist
7. Auto-generates a source tag from the URL domain (e.g., "source/anthropic")

**Example workflow:**
```
User: /obsidian:save-link https://anthropic.com/research/constitutional-ai

Claude: What title/description should I use for this link?
User: Constitutional AI Research Paper

Claude: Where should I save this link?
User: ai/outlinks

Claude: Any tags to add? (optional)
User: research, alignment

Claude: Any notes or context? (optional)
User: Foundational paper on RLHF with AI feedback

Claude: ✓ Link saved to ai/outlinks
        Title: Constitutional AI Research Paper
        Tags: research, alignment, source/anthropic
```

**External Links Table Format:**
The command creates/updates a table in your note with this structure:
```markdown
## External Links

| Title | Tags | Link | Notes |
|-------|------|------|-------|
| Constitutional AI Research Paper | #research #alignment #source/anthropic | [Constitutional AI Research Paper](https://anthropic.com/research/constitutional-ai) | Foundational paper on RLHF with AI feedback |
```

### `/obsidian:configure`

Set up or update the Obsidian plugin configuration (`~/.claude/obsidian-plugin.json`), including vault path and digest output directory. Auto-detects the vault path when possible.

### `/obsidian:gmail:digest`

Fetch all unread Gmail emails via the Gmail MCP, categorize them into bucketed summaries (Action Required, Calendar, Conversations, FYI, Automated, Figma Comments), and save a dated digest markdown file to your Obsidian vault.

### `/obsidian:graph:sync`

Scan all vault `.md` files for keyword matches and insert `[[wiki-links]]` inline. Runs a semantic pass on unlinked files to append `## Related` sections. Increases Obsidian graph density.

### `/obsidian:health`

Display a health dashboard for your vault: orphan count, dead ends, broken links, open tasks, tag totals, and a computed health score (0-100). Offers drill-down into each metric.

### `/obsidian:note:create`

Create a new note in any registered Obsidian vault. Detects all vaults on the current machine, lets you choose vault and subfolder, and writes a properly formatted markdown note with frontmatter.

### `/obsidian:search`

Search the vault for notes matching a query using the Obsidian CLI. Supports folder filtering, case-sensitive search, and result limits. Displays results with surrounding context.

### `/obsidian:slack:digest`

Read Slack mentions, DMs, and key channels via the Slack MCP, categorize messages (Action Required, Mentions, DMs, Active Threads, Channel Highlights, Bot/Automated), and save a dated digest to the vault.

### `/obsidian:task:create`

Create a task markdown file with TaskBase-compatible frontmatter. Supports screenshot analysis for auto-filling task details, link enrichment (GitHub comments, Slack threads), and structured prompts for project, priority, status, and due date.

### `/obsidian:weekly`

Generate a weekly review from daily notes, tasks, and tags. Synthesizes accomplishments, in-progress work, blockers, and next-week priorities into a structured review document saved to `reviews/weekly/`.

## Configuration

The plugin expects your Obsidian vault at:
```
~/Library/Mobile Documents/com~apple~CloudDocs/zk
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
        "path": "/path/to/claude-code-workflows"
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

- **1.3.0** - Added 9 commands: configure, gmail-digest, graph-sync, health, note-create, search, slack-digest, task-create, weekly
- **1.2.0** - Added `/obsidian:save-link` command for saving external links to notes
- **1.0.0** - Initial release with screenshot capture to fragment notes
