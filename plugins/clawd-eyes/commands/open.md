---
description: Open the clawd-eyes web UI in the default browser
allowed-tools: Bash
---

# Open Clawd-Eyes

Open the clawd-eyes web UI in your default browser.

## Instructions

1. **Check if web UI is running**
   ```bash
   lsof -i :5173 2>/dev/null | grep LISTEN
   ```

2. **If running, open in browser**
   ```bash
   open http://localhost:5173
   ```

3. **If not running, inform user**
   - Tell user: "Web UI is not running. Use /clawd-eyes:start first."

## URL

http://localhost:5173
