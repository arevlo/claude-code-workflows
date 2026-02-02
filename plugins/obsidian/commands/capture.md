---
description: Capture screenshots with context and create fragment notes in Obsidian vault
allowed-tools: mcp__obsidian-zettelkasten__create_fragment_note,Bash,AskUserQuestion,Read
---

Capture a screenshot with context and create a fragment note in your Obsidian Zettelkasten vault.

## What this does

When you share a screenshot (from Slack, Figma, browser, etc.) along with optional links or context:
1. Analyzes the screenshot to understand the content
2. Prompts you for which category folder (flow, ai, personal, etc.)
3. Creates fragment in `{category}/fragments/` subfolder (creates if doesn't exist)
4. Prompts you for a topic-based title
5. Creates a fragment note with:
   - The screenshot embedded (saved to `{category}/fragments/_attachments/`)
   - Your analysis/description of the content
   - External reference links (Slack, Figma, etc.)
   - Relevant tags
6. Returns the path to the created note

## Configuration

**Obsidian vault path:** `/Users/arevlo/Library/Mobile Documents/com~apple~CloudDocs/zk`

## Steps

### 1. Gather Information First

**Before doing any file operations**, collect all the information needed:

**Category selection:**
- Ask: "Which category should I save this to?"
- Common options: `flow`, `ai`, `personal`, `work`
- Default to `flow` if user doesn't specify
- Fragment will be saved in `{category}/fragments/` subfolder

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

### 2. Find and Verify the Screenshot

**Only after gathering all information above**, find the screenshot in the cache:

The screenshot is cached by Claude Code in `~/.claude/image-cache/`:

```bash
# Find the most recent image
LATEST_IMAGE=$(ls -t ~/.claude/image-cache/*/[0-9]*.png 2>/dev/null | head -1)

# Validate image exists
if [ -z "$LATEST_IMAGE" ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  No Screenshot Detected"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "To use /arevlo:obsidian:capture, you need to:"
  echo ""
  echo "  1. Paste or attach a screenshot in the chat"
  echo "  2. Then run /arevlo:obsidian:capture again"
  echo ""
  echo "The screenshot will be automatically cached and"
  echo "ready for capture when you re-run the command."
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 1
fi

# Show which image was found
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Screenshot Found in Cache"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Most recent image: $(basename "$LATEST_IMAGE")"
ls -lh "$LATEST_IMAGE"
echo ""
echo "I'll show you this image for confirmation..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

**After running the bash block above:**

1. Use the `Read` tool to display the image to the user:
   - Read the file at the path stored in `$LATEST_IMAGE`
   - This will show the screenshot visually in the conversation

2. Use `AskUserQuestion` to confirm:
   - Question: "Is this the correct screenshot you want to capture?"
   - Options:
     - "Yes, use this screenshot"
     - "No, wrong screenshot"
   - If "No": Exit with message instructing user to paste the correct screenshot

3. Only proceed with copy if user confirms "Yes"

Then continue with the copy operation:

```bash
# Set vault path and fragment folder
VAULT_PATH="/Users/arevlo/Library/Mobile Documents/com~apple~CloudDocs/zk"
FRAGMENT_FOLDER="{category}/fragments"

# Create _attachments folder if needed
mkdir -p "$VAULT_PATH/$FRAGMENT_FOLDER/_attachments"

# Copy the image with the topic name
cp "$LATEST_IMAGE" "$VAULT_PATH/$FRAGMENT_FOLDER/_attachments/{topic}.png"

# Verify the copy succeeded
if [ ! -f "$VAULT_PATH/$FRAGMENT_FOLDER/_attachments/{topic}.png" ]; then
  echo "Error: Failed to copy screenshot to Obsidian vault."
  echo "Source: $LATEST_IMAGE"
  echo "Destination: $VAULT_PATH/$FRAGMENT_FOLDER/_attachments/{topic}.png"
  exit 1
fi

# Show confirmation
ls -lh "$VAULT_PATH/$FRAGMENT_FOLDER/_attachments/{topic}.png"
echo "✓ Screenshot copied successfully"
```

### 3. Analyze and Create the Fragment Note

**After confirming the screenshot**, analyze what it shows:
- Identify what the screenshot contains (UI mockup, conversation, diagram, etc.)
- Note key discussion points or decisions visible
- Extract important context from the image

Then use the `mcp__obsidian-zettelkasten__create_fragment_note` tool:

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
  folder: "{category}/fragments",  // Will be created if doesn't exist
  externalRefs: [
    {
      title: "Slack Thread - {Topic}",
      url: "{slack-url}"
    }
  ],
  isLlmGenerated: true
}
```

### 4. Provide Summary

Show the user:
- Path to the created fragment note
- Image filename and location
- Reminder that fragments should be processed into primitives later

Example output:
```
✓ Fragment note created: flow/fragments/{topic}.md
✓ Screenshot saved: flow/fragments/_attachments/{topic}.png

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
