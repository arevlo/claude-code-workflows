---
description: Stop all clawd-eyes servers by killing processes on their ports
allowed-tools: Bash
---

# Stop Clawd-Eyes

Stop all clawd-eyes processes and free up the ports.

## Instructions

1. **Kill processes on all clawd-eyes ports**
   ```bash
   lsof -ti :4000 :4001 :5173 :9222 | xargs kill -9 2>/dev/null
   ```

2. **Verify ports are free**
   ```bash
   lsof -i :4000 -i :4001 -i :5173 -i :9222 2>/dev/null | grep LISTEN || echo "All ports free"
   ```

3. **Report to user**
   - Confirm processes were stopped
   - Confirm all ports are now free

## Ports Killed

| Port | Service |
|------|---------|
| 4000 | HTTP API |
| 4001 | WebSocket |
| 5173 | Web UI (Vite) |
| 9222 | Chrome DevTools Protocol |

## Notes

- Some ports may already be free - that's fine
- Port 9222 is Chrome's CDP port - killing it closes the browser
- After stopping, restart with `/clawd-eyes:start`
