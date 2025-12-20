---
description: Start clawd-eyes backend server and web UI
allowed-tools: Bash,Read
---

# Start Clawd-Eyes

Start the clawd-eyes visual browser inspector servers.

## Instructions

1. **Find the clawd-eyes project directory:**
   - Check if current directory is clawd-eyes: `cat package.json 2>/dev/null | grep '"name": "clawd-eyes"'`
   - Check common locations: `~/clawd-eyes`, `~/projects/clawd-eyes`, `~/Desktop/clawd-eyes`
   - Search for it: `find ~ -maxdepth 4 -name "clawd-eyes" -type d 2>/dev/null | head -5`
   - If not found, ask the user for the path

2. **Kill any existing processes on clawd-eyes ports:**
   ```bash
   lsof -ti :4000 :4001 :5173 2>/dev/null | xargs kill -9 2>/dev/null; echo "Ports cleared"
   ```

3. **Start the backend server** (runs in background, launches Chromium):
   ```bash
   cd <clawd-eyes-path> && npm start
   ```
   Run this in background mode using the Bash tool's `run_in_background` parameter.

4. **Wait for backend to initialize** (2-3 seconds for browser to launch)

5. **Start the web UI** (runs in background):
   ```bash
   cd <clawd-eyes-path>/web && npm run dev
   ```
   Run this in background mode using the Bash tool's `run_in_background` parameter.

6. **Wait for Vite to start** (1-2 seconds)

7. **Verify services are running:**
   ```bash
   echo "=== clawd-eyes Status ===" && \
   echo "Backend API (4000): $(lsof -i :4000 2>/dev/null | grep LISTEN > /dev/null && echo 'Running' || echo 'Not running')" && \
   echo "WebSocket (4001): $(lsof -i :4001 2>/dev/null | grep LISTEN > /dev/null && echo 'Running' || echo 'Not running')" && \
   echo "Web UI (5173): $(lsof -i :5173 2>/dev/null | grep LISTEN > /dev/null && echo 'Running' || echo 'Not running')"
   ```

8. **Report to user:**
   - Web UI: http://localhost:5173
   - A browser window should have opened
   - They can navigate to any URL in the browser, then use the web UI to inspect elements

## Ports Used

| Port | Service |
|------|---------|
| 4000 | HTTP API |
| 4001 | WebSocket (live updates) |
| 5173 | Web UI (Vite dev server) |

## Notes

- Backend launches a browser via Playwright for page capture
- If extension support is configured in browser.ts, it will load the extension
- User can configure viewport size and scale factor in browser.ts
