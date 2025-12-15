# clawd-eyes

Slash commands for managing clawd-eyes visual browser inspector.

## Commands

| Command | Description |
|---------|-------------|
| `/clawd-eyes:start` | Start clawd-eyes (clears ports, starts servers) |
| `/clawd-eyes:stop` | Stop all clawd-eyes processes |
| `/clawd-eyes:status` | Check if clawd-eyes is running |
| `/clawd-eyes:watch` | Watch for design requests (background) |

## Ports Used

- 4000 - HTTP API
- 4001 - WebSocket
- 3000 - Web UI (Vite)
- 9222 - Chrome DevTools Protocol

## Requirements

- clawd-eyes repo cloned to `~/Desktop/personal-repos/clawd-eyes`
- Node.js installed
