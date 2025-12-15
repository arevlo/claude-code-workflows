# clawd-eyes

Slash commands for managing clawd-eyes visual browser inspector.

## Commands

| Command | Description |
|---------|-------------|
| `/clawd-eyes:start` | Start backend + web UI (clears ports first) |
| `/clawd-eyes:stop` | Stop all clawd-eyes processes |
| `/clawd-eyes:status` | Check if services are running |
| `/clawd-eyes:open` | Open the web UI in default browser |
| `/clawd-eyes:watch` | Check for pending design requests |

## Ports Used

| Port | Service |
|------|---------|
| 4000 | HTTP API |
| 4001 | WebSocket |
| 5173 | Web UI (Vite) |
| 9222 | Chrome DevTools Protocol |

## Requirements

- clawd-eyes repo cloned to `~/Desktop/personal-repos/clawd-eyes`
- Node.js installed
- Dependencies installed (`npm install` in both root and `web/` directories)

## Workflow

1. Run `/clawd-eyes:start` to launch the servers
2. Run `/clawd-eyes:open` to open the web UI
3. Navigate to a URL in the Chromium browser
4. Click elements to inspect them
5. Add instructions and click "Send to clawd-eyes"
6. Run `/clawd-eyes:watch` to check for requests
7. Use `get_design_context` MCP tool to get full details
