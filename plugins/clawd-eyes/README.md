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

## Requirements

- clawd-eyes repo cloned locally
- Node.js installed
- Dependencies installed (`npm install` in both root and `web/` directories)

## Installation

1. Clone clawd-eyes: `git clone https://github.com/arevlo/clawd-eyes.git`
2. Install dependencies: `cd clawd-eyes && npm install && cd web && npm install`
3. Start with `/clawd-eyes:start`

## Workflow

1. Run `/clawd-eyes:start` to launch the servers
2. Run `/clawd-eyes:open` to open the web UI
3. Navigate to a URL in the browser window
4. Click elements in the web UI to inspect them
5. Add instructions and click "Send to clawd-eyes"
6. Run `/clawd-eyes:watch` to check for requests
7. Use `get_design_context` MCP tool to get full details with screenshot

## Architecture

- **Backend** (`npm start`): Launches browser via Playwright, captures screenshots and DOM
- **Web UI** (`web/`): React app for viewing page screenshots and selecting elements
- **MCP Server**: Exposes `get_design_context`, `clear_design_context`, `list_elements` tools

## Configuration

Browser settings can be customized in `src/browser.ts`:
- Browser type (Chromium/Firefox)
- Viewport size
- Device scale factor
- Extension loading (for Chromium)
