---
description: Read browser console messages (errors, warnings, logs) from current page
allowed-tools: Bash
---

# Read Console Messages

Capture and analyze JavaScript console output from the current web page for debugging.

## Instructions

### 1. Check Chrome Integration

Verify Chrome integration is available:

```bash
echo "Checking Chrome integration for console access..."
```

**If Chrome integration is not enabled:**

Tell the user:
```
Chrome integration required to read console messages.

To enable:
1. Run: /chrome
2. Select "Enabled by default"

Or start Claude Code with: claude --chrome
```

Exit gracefully if Chrome is not available.

### 2. Get Tab Context

Use the `mcp__claude-in-chrome__tabs_context_mcp` tool to get the current tab ID.

**If no tabs available:**
- Inform user: "No Chrome tabs available. Please navigate to a page first."
- Exit

### 3. Parse Arguments (Optional Filter)

Accept optional pattern argument for filtering console messages:

**Default pattern:** `"error|warning"` (show errors and warnings)

**User-provided patterns:**
- `"error"` - Only errors
- `".*"` - All messages
- `"MyApp"` - App-specific logs
- `"API|fetch"` - API-related logs

### 4. Read Console Messages

Use the `mcp__claude-in-chrome__read_console_messages` tool:

Parameters:
- `tabId`: From step 2
- `pattern`: Filter pattern (regex)
- `onlyErrors`: false (use pattern instead)
- `limit`: Default 100
- `clear`: false (keep messages for future reads)

### 5. Parse and Display Results

Format console messages into readable output:

```markdown
## Console Messages for [URL]

### Errors (2)
❌ **TypeError: Cannot read property 'map' of undefined**
   File: app.js:145
   Timestamp: 12:34:56.789

❌ **Failed to load resource: net::ERR_CONNECTION_REFUSED**
   URL: https://api.example.com/data
   Timestamp: 12:35:02.123

### Warnings (1)
⚠️  **Deprecated API: document.write() is deprecated**
   File: legacy.js:89
   Timestamp: 12:34:50.456

### Info/Logs (0)
(No info messages matching filter)

---
**Total messages:** 3
**Pattern:** error|warning
**Tip:** Use /clawd-eyes:read-console [pattern] to filter messages
```

### 6. Message Categorization

Group messages by type:
- **Errors** (console.error, exceptions): ❌ prefix
- **Warnings** (console.warn): ⚠️ prefix
- **Info** (console.info, console.log): ℹ️ prefix
- **Debug** (console.debug): 🔍 prefix

Sort by timestamp (most recent first) within each category.

## Output Format

### Per-Message Details
- **Icon and message text** (first 100 chars if long)
- **Source file and line** (if available)
- **Timestamp** (formatted for readability)
- **Stack trace** (for errors, if available - show first 3 lines)

### Summary Statistics
- Total messages by type
- Active filter pattern
- Clear command to read all messages
- Tip for pattern usage

### Helpful Context
For errors:
- Extract error type (TypeError, ReferenceError, etc.)
- Show affected line of code if available
- Suggest potential fixes if pattern is obvious

## Error Handling

**Chrome not enabled:**
```
❌ Chrome integration not available.

Enable with: /chrome

This command requires Claude Code's Chrome integration to read console messages.
```

**No tab context:**
```
❌ No active Chrome tab found.

Please:
1. Open Chrome
2. Navigate to a web page
3. Run this command again
```

**No messages found:**
```
✓ Console monitoring active

No messages match pattern: [pattern]

Possible reasons:
- No console output yet
- Pattern too restrictive
- Page hasn't triggered any logs

Try:
- /clawd-eyes:read-console .* (show all)
- Interact with the page to trigger logs
- Refresh the page
```

**Invalid pattern:**
```
❌ Invalid regex pattern: [pattern]

Error: [regex error message]

Examples of valid patterns:
- "error" (exact match)
- "error|warning" (either)
- ".*" (all messages)
- "[A-Z]+" (uppercase words)
```

## Filter Pattern Examples

| Pattern | Matches |
|---------|---------|
| `error` | Messages containing "error" |
| `error\|warning` | Errors or warnings |
| `.*` | All messages |
| `^ERROR:` | Lines starting with "ERROR:" |
| `MyApp` | App-specific logs |
| `API\|fetch\|xhr` | Network-related logs |
| `\d{3}` | Messages with 3-digit numbers |

## Integration with clawd-eyes

**Workflow:**
1. User selects interactive element (button, form, etc.)
2. Element has JavaScript behavior
3. Run `/clawd-eyes:read-console` to see errors/logs
4. Debug JavaScript issues affecting the element
5. Combine with `/clawd-eyes:inspect-network` for full picture

**Common Use Cases:**
- Debug click handlers that fail silently
- Find validation errors in forms
- Investigate API call failures
- Check for deprecated API warnings
- Monitor real-time logging during interactions

## Advanced Options

### Clear After Reading
To prevent duplicate messages on subsequent reads:

```bash
# Read and clear (not implemented in base command, but possible)
# Use clear: true parameter if needed
```

### Continuous Monitoring
For watching console in real-time:

```bash
# Read periodically
/clawd-eyes:read-console
# Interact with page
/clawd-eyes:read-console
# See new messages since last read
```

### Error-Only Mode
```bash
/clawd-eyes:read-console error
```

### Verbose Mode (All Messages)
```bash
/clawd-eyes:read-console .*
```

## Notes

- Console messages are captured **from current domain only**
- Messages accumulate until page navigation or reload
- Cross-origin iframe console messages may not be visible
- Some browser extensions inject console logs (may see noise)
- **Pattern matching is case-sensitive** by default
- Use `(?i)` prefix for case-insensitive: `(?i)error`

## Example Usage

**User:** "Why is this button click not working?"

**Command:** `/clawd-eyes:read-console`

**Output:**
```markdown
## Console Messages for https://example.com

### Errors (1)
❌ **Uncaught TypeError: Cannot read properties of null (reading 'addEventListener')**
   File: main.js:234
   Timestamp: 14:23:45.678

   Stack trace:
     at setupButton (main.js:234:15)
     at init (main.js:189:5)
     at DOMContentLoaded (main.js:301:3)

### Warnings (0)
(No warnings)

---
**Total messages:** 1
**Pattern:** error|warning

💡 **Diagnostic:** The button element wasn't found in the DOM when trying to add the click handler. The selector might be wrong, or the script is running before the button is rendered.

**Suggested fix:** Ensure button exists before calling addEventListener, or move script to run after DOM is ready.
```
