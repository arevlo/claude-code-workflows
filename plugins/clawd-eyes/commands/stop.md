---
description: Stop all clawd-eyes servers by killing processes on their ports
allowed-tools: Bash
---

# Stop Clawd-Eyes

Stop all clawd-eyes processes and free up the ports.

## Instructions

1. **Kill processes on all clawd-eyes ports**
   ```bash
   lsof -ti :4000 :4001 :5173 2>/dev/null | xargs kill -9 2>/dev/null; echo "Processes killed"
   ```

2. **Verify ports are free**
   ```bash
   lsof -i :4000,:4001,:5173 2>/dev/null | grep LISTEN || echo "All ports free"
   ```

3. **Report to user**
   - Confirm processes were stopped
   - Confirm all ports are now free
   - The browser window will close automatically

## Ports Killed

| Port | Service |
|------|---------|
| 4000 | HTTP API |
| 4001 | WebSocket |
| 5173 | Web UI (Vite) |

## Notes

- Some ports may already be free - that's fine
- Killing the backend also closes the browser (managed by Playwright)
- After stopping, restart with `/clawd-eyes:start`
