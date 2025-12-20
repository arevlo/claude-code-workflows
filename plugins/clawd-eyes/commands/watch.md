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

2. **Find the clawd-eyes data directory:**
   - Check common locations for `data/pending-request.json`:
     - Current directory: `./data/pending-request.json`
     - Home: `~/clawd-eyes/data/pending-request.json`
     - Projects: `~/projects/clawd-eyes/data/pending-request.json`
   - Or search: `find ~ -maxdepth 5 -path "*/clawd-eyes/data/pending-request.json" 2>/dev/null | head -1`
   - If not found, ask the user for the clawd-eyes path

3. **Check for pending request**
   ```bash
   cat <clawd-eyes-path>/data/pending-request.json 2>/dev/null || echo "No pending request"
   ```

4. **If request exists:**
   - Read the file contents
   - Display a summary: selector, instruction (first 100 chars)
   - Tell user: "Design request found! I can now help you implement this."
   - Offer to call the `get_design_context` MCP tool to get full details with screenshot

5. **If no request:**
   - Tell user: "No pending request. Select an element in the clawd-eyes web UI and click 'Send to clawd-eyes'."

## Request Format

```json
{
  "selector": "div.example",
  "instruction": "User's design instruction",
  "css": { "width": "100px", ... },
  "boundingBox": { "x": 0, "y": 0, "width": 100, "height": 50 },
  "url": "https://example.com",
  "timestamp": 1234567890
}
```
