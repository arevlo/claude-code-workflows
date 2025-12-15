---
description: Watch for design requests from clawd-eyes web UI
allowed-tools: Bash,Read
---

# Watch for Design Requests

Monitor for incoming design requests from the clawd-eyes web UI.

## Instructions

1. **Check if clawd-eyes is running first**
   ```bash
   lsof -i :4000 2>/dev/null | grep LISTEN
   ```
   If not running, tell user to run `/clawd-eyes:start` first.

2. **Find the clawd-eyes data directory**
   - Look for `~/Desktop/personal-repos/clawd-eyes/data/pending-request.json`
   - Or search for the clawd-eyes project directory

3. **Check for pending request**
   ```bash
   cat ~/Desktop/personal-repos/clawd-eyes/data/pending-request.json 2>/dev/null
   ```

4. **If request exists:**
   - Read the file contents
   - Display a summary: selector, instruction (first 100 chars)
   - Tell user: "Design request found! I can now help you implement this."
   - Offer to call the `get_design_context` MCP tool to get full details with screenshot

5. **If no request:**
   - Tell user: "No pending request. Select an element in the clawd-eyes web UI and click 'Send to clawd-eyes'."
   - Optionally poll again in a few seconds (ask user if they want to wait)

## File Location

The pending request is stored at:
```
<clawd-eyes-path>/data/pending-request.json
```

## Request Format

```json
{
  "selector": "div.example",
  "instruction": "User's design instruction",
  "css": { "width": "100px", ... },
  "boundingBox": { "x": 0, "y": 0, "width": 100, "height": 50 },
  "timestamp": 1234567890
}
```
