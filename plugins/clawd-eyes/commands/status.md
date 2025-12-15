---
description: Check clawd-eyes status
allowed-tools: Bash
---

# Check clawd-eyes Status

Check if clawd-eyes services are running.

## Instructions

1. **Check each port**

   ```bash
   echo "=== clawd-eyes Status ===" && \
   echo "" && \
   echo "HTTP API (4000):" && \
   lsof -i :4000 2>/dev/null || echo "  Not running" && \
   echo "" && \
   echo "WebSocket (4001):" && \
   lsof -i :4001 2>/dev/null || echo "  Not running" && \
   echo "" && \
   echo "Web UI (3000):" && \
   lsof -i :3000 2>/dev/null || echo "  Not running" && \
   echo "" && \
   echo "Chrome CDP (9222):" && \
   lsof -i :9222 2>/dev/null || echo "  Not running"
   ```

2. **Report to user**
   - List which services are running
   - If all are running: "clawd-eyes is fully running"
   - If partially running: "clawd-eyes is partially running (missing: X)"
   - If none running: "clawd-eyes is not running - use /clawd-eyes:start"

## URLs (when running)

- Web UI: http://localhost:3000
- API: http://localhost:4000
- WebSocket: ws://localhost:4001
- CDP: ws://localhost:9222
