---
description: Check status of clawd-eyes servers
allowed-tools: Bash
---

# Check Clawd-Eyes Status

Check if clawd-eyes services are running.

## Instructions

1. **Check each port for running services**
   ```bash
   echo "=== clawd-eyes Status ===" && \
   echo "Backend API (4000): $(lsof -i :4000 2>/dev/null | grep LISTEN > /dev/null && echo 'Running' || echo 'Not running')" && \
   echo "WebSocket (4001): $(lsof -i :4001 2>/dev/null | grep LISTEN > /dev/null && echo 'Running' || echo 'Not running')" && \
   echo "Web UI (5173): $(lsof -i :5173 2>/dev/null | grep LISTEN > /dev/null && echo 'Running' || echo 'Not running')"
   ```

2. **Report to user**
   - If all are running: "clawd-eyes is fully running"
   - If partially running: "clawd-eyes is partially running (missing: X)"
   - If none running: "clawd-eyes is not running - use /clawd-eyes:start"

## URLs (when running)

| Service | URL |
|---------|-----|
| Web UI | http://localhost:5173 |
| API | http://localhost:4000 |
| WebSocket | ws://localhost:4001 |
