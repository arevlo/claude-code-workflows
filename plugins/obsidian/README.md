# Obsidian Capture Plugin

Capture screenshots and context directly to your Obsidian Zettelkasten vault as fragment notes. Save external links to note tables. Generate Gmail digest summaries.

## Commands

### `/arevlo:obsidian:capture`

Capture a screenshot with context and create a fragment note in your Obsidian vault.

**Usage:**
```
/arevlo:obsidian:capture [category]

# Example:
/arevlo:obsidian:capture flow
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
      https://life-in-flow.slack.com/archives/C123/p456

/arevlo:obsidian:capture flow

Claude: What topic should I use for the filename?
User: property-filters-discussion

Claude: ✓ Fragment note created: flow/fragments/property-filters-discussion.md
        ✓ Screenshot saved: flow/fragments/_attachments/property-filters-discussion.png
```

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

**Example workflow:**
```
User: /arevlo:obsidian:save-link https://anthropic.com/research/constitutional-ai

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

### `/arevlo:obsidian:gmail-digest`

Open Gmail in Chrome, read all unread emails, categorize them, and save a bucketed digest to your Obsidian vault.

**Usage:**
```
/arevlo:obsidian:gmail-digest
```

**What it does:**
1. Opens Gmail in Chrome filtered to unread emails
2. Reads each unread email (opening them marks as read)
3. Categorizes emails into buckets:
   - **Action Required** — needs a response or task
   - **Calendar & Scheduling** — meeting invites, schedule changes
   - **Conversations** — ongoing threads/replies
   - **FYI / Informational** — newsletters, notifications, updates
   - **Automated / System** — receipts, alerts, service notifications
4. Generates a structured markdown digest
5. Saves to `{digest_output_path}/gmail-digest-YYYY-MM-DD.md`
6. Shows summary of processed emails and categories

**Example output file:** `gmail-digest-2026-02-07.md` (saved to your configured `digest_output_path`)

**Notes:**
- Running multiple times per day appends a counter (e.g., `gmail-digest-2026-02-07-2.md`)
- Requires Chrome with the Claude in Chrome extension
- Emails are marked as read by being opened during processing

### `/arevlo:obsidian:configure`

Set up or update the Obsidian plugin configuration (vault path, digest output path).

**Usage:**
```
/arevlo:obsidian:configure
```

## Configuration

On first use, any command will prompt you to configure your paths. Configuration is stored in `~/.claude/obsidian-plugin.json`:

| Field | Used By | Description |
|-------|---------|-------------|
| `vault_path` | `/capture`, `/save-link` | Absolute path to your Obsidian vault |
| `digest_output_path` | `/gmail-digest` | Absolute path for Gmail digest files |

To reconfigure, run `/arevlo:obsidian:configure` or edit `~/.claude/obsidian-plugin.json` directly.

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
    "arevlo:obsidian@claude-code-workflows": true
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

- **1.4.0** - Made paths configurable via `~/.claude/obsidian-plugin.json`; added `/arevlo:obsidian:configure` command
- **1.3.0** - Added `/arevlo:obsidian:gmail-digest` command for Gmail digest summaries
- **1.2.0** - Added `/arevlo:obsidian:save-link` command for saving external links to notes
- **1.0.0** - Initial release with screenshot capture to fragment notes
