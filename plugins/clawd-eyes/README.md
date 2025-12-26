# clawd-eyes

Visual browser inspector with AI-powered element finding and Chrome DevTools integration.

## Commands

| Command | Description |
|---------|-------------|
| `/clawd-eyes:start` | Start backend + web UI (connects to existing browser) |
| `/clawd-eyes:stop` | Stop all clawd-eyes processes |
| `/clawd-eyes:status` | Check if services are running |
| `/clawd-eyes:open` | Open the web UI in default browser |
| `/clawd-eyes:watch` | Check for pending design requests |
| `/clawd-eyes:inspect-network` | Inspect network requests using Chrome DevTools |
| `/clawd-eyes:read-console` | Read browser console messages for debugging |

## Agents

clawd-eyes includes specialized AI agents for enhanced workflows:

### Element Finder Agent
**Name:** `element-finder`
**When to use:** Locate page elements by natural language description
**Example:** "Find the login button" or "Locate the main navigation menu"

The agent uses Claude Code's Chrome integration to find elements programmatically, returning selectors and coordinates that can be viewed in the clawd-eyes UI.

**Requirements:** `/chrome` must be enabled in Claude Code

### Design Orchestrator Agent
**Name:** `design-orchestrator`
**When to use:** Automatically process design requests end-to-end
**Workflow:**
1. Detects pending design requests from clawd-eyes
2. Fetches design context (screenshot, CSS, instruction)
3. Analyzes requested changes
4. Implements CSS/HTML modifications
5. Clears request when complete

**Usage:** The agent works proactively when design requests are detected, or can be invoked explicitly when working with clawd-eyes.

## Prerequisites

**A browser must be running with CDP (Chrome DevTools Protocol) enabled on port 9222.**

### Option 1: Playwright-based project
If you have a Playwright project that launches a browser, add this arg:
```typescript
args: ['--remote-debugging-port=9222']
```

### Option 2: Launch Chrome manually
```bash
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222
```

## Ports Used

| Port | Service |
|------|---------|
| 9222 | Browser CDP (user's browser) |
| 4000 | HTTP API |
| 4001 | WebSocket |
| 5173 | Web UI (Vite) |

## Requirements

- clawd-eyes repo cloned locally
- Node.js installed
- Dependencies installed (`npm install` in both root and `web/` directories)
- A browser running with `--remote-debugging-port=9222`

## Installation

1. Clone clawd-eyes: `git clone https://github.com/arevlo/clawd-eyes.git`
2. Install dependencies: `cd clawd-eyes && npm install && cd web && npm install`
3. Start a browser with CDP enabled (see Prerequisites above)
4. Start with `/clawd-eyes:start`

## Workflow

1. Start a browser with `--remote-debugging-port=9222`
2. Run `/clawd-eyes:start` to launch backend + web UI
3. Run `/clawd-eyes:open` to open the web UI
4. Navigate to pages in your browser
5. Click elements in the web UI to inspect them
6. Add instructions and click "Send to clawd-eyes"
7. Run `/clawd-eyes:watch` to check for requests
8. Use `get_design_context` MCP tool to get full details with screenshot

## Architecture

- **Backend** (`npm start`): Connects to existing browser via CDP, captures screenshots and DOM
- **Web UI** (`web/`): React app for viewing page screenshots and selecting elements
- **MCP Server**: Exposes `get_design_context`, `clear_design_context`, `list_elements` tools

## Chrome Integration

Some commands and agents require **Claude Code's Chrome integration** (`/chrome`):

- **Element Finder Agent** - Uses `mcp__claude-in-chrome__find` to locate elements
- **Network Inspector** - Uses `mcp__claude-in-chrome__read_network_requests`
- **Console Reader** - Uses `mcp__claude-in-chrome__read_console_messages`

**To enable Chrome integration:**
1. Run `/chrome` in Claude Code
2. Select "Enabled by default"
3. Or start with `claude --chrome`

**Benefits:**
- Programmatic element finding by description
- Network request debugging
- Console log monitoring
- Combines visual UI (clawd-eyes) with automation (Chrome integration)

## How It Works

1. Backend connects to browser via CDP (port 9222)
2. Captures screenshots and DOM when pages load
3. Sends data to web UI via WebSocket
4. Web UI displays screenshot with element overlays
5. User selects elements and sends design requests
6. MCP tools expose the data to Claude Code
7. AI agents automate workflows and debugging tasks
