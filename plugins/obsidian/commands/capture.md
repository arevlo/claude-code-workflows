---
description: Capture screenshots with context and create fragment notes in Obsidian vault
argument-hint: [optional: folder name]
allowed-tools: mcp__obsidian-zettelkasten__create_fragment_note,Bash,AskUserQuestion,Read
---

Capture a screenshot with context and create a fragment note in your Obsidian Zettelkasten vault.

## What this does

When you share a screenshot (from Slack, Figma, browser, etc.) along with optional links or context:
1. Analyzes the screenshot to understand the content
2. Prompts you for which folder to save in (flow, ai, personal, etc.)
3. Prompts you for a topic-based title
4. Creates a fragment note with:
   - The screenshot embedded (saved to `_attachments/`)
   - Your analysis/description of the content
   - External reference links (Slack, Figma, etc.)
   - Relevant tags
5. Returns the path to the created note

## Configuration

**Obsidian vault path:** `/Users/arevlo/Library/Mobile Documents/com~apple~CloudDocs/zk`

## Steps

### 1. Analyze the Screenshot

If there's an image in the conversation:
- Analyze what it shows (UI mockup, conversation, diagram, etc.)
- Identify key discussion points or decisions
- Note any important context visible in the screenshot

### 2. Gather Information

**Folder selection:**
- Check if user provided folder in $ARGUMENTS
- If not, ask: "Which folder should I save this to?"
- Common options: `flow`, `ai`, `personal`, `work`
- Default to `flow` if user doesn't specify

**Topic/Title:**
- Ask: "What topic should I use for the filename?"
- Example: `create-charge-ui-design` or `property-filters-discussion`
- This will be used for both image and note filenames

**External link** (if not already provided):
- Ask if there's a related link (Slack thread, Figma file, GitHub issue, etc.)

**Additional context** (optional):
- Any extra notes or context not visible in the screenshot
- Follow-up actions needed
- Related work or decisions

### 3. Find and Copy the Screenshot

The screenshot is cached by Claude Code in `~/.claude/image-cache/`:

```bash
# Find the most recent image
LATEST_IMAGE=$(ls -t ~/.claude/image-cache/*/[0-9]*.png 2>/dev/null | head -1)

# Set vault path
VAULT_PATH="/Users/arevlo/Library/Mobile Documents/com~apple~CloudDocs/zk"

# Create _attachments folder if needed
mkdir -p "$VAULT_PATH/{folder}/_attachments"

# Copy the image with the topic name
cp "$LATEST_IMAGE" "$VAULT_PATH/{folder}/_attachments/{topic}.png"

# Verify the copy
ls -lh "$VAULT_PATH/{folder}/_attachments/{topic}.png"
```

### 4. Create the Fragment Note

Use the `mcp__obsidian-zettelkasten__create_fragment_note` tool:

```typescript
{
  title: "User's provided title",
  content: `
# Screenshot

![[{topic}.png]]

## Context

{Your analysis of the screenshot}

**Key points:**
- {Point 1 from screenshot}
- {Point 2 from screenshot}
- {Point 3 from screenshot}

{Any additional context provided by user}

## Follow-up

{Any action items or decisions needed}
`,
  folder: "{folder}",
  externalRefs: [
    {
      title: "Slack Thread - {Topic}",
      url: "{slack-url}"
    }
  ],
  isLlmGenerated: true
}
```

### 5. Provide Summary

Show the user:
- Path to the created fragment note
- Image filename and location
- Reminder that fragments should be processed into primitives later

Example output:
```
✓ Fragment note created: flow/{topic}.md
✓ Screenshot saved: flow/_attachments/{topic}.png

The fragment note is ready in your Obsidian vault. Remember to process it into primitives later!
```

## Notes

- **Fragment lifecycle:** Fragments are temporary captures meant to be processed later into primitives (atomic knowledge) or discarded
- **Screenshot storage:** Images are stored in `_attachments/` subfolder alongside the note
- **Tags:** The tool will auto-generate relevant tags based on content
- **Follow-up:** Always note if there are action items or decisions to be made

## Related Tools

- `mcp__obsidian-zettelkasten__process_fragment` - Process fragments into primitives
- `mcp__obsidian-zettelkasten__list_notes` - List all notes in vault
- `mcp__obsidian-zettelkasten__search_vault` - Search vault content
