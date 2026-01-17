---
description: Start clawd-eyes backend server and web UI
allowed-tools: Bash,Read
---

# Start Clawd-Eyes

Start the clawd-eyes visual browser inspector (backend + web UI) as background services.

## Instructions

1. **Find the clawd-eyes project directory:**
   - Check common locations: `~/clawd-eyes`, `~/Desktop/personal-repos/clawd-eyes`
   - Search for it: `find ~ -maxdepth 5 -name "clawd-eyes" -type d 2>/dev/null | grep -v node_modules | head -3`
   - If not found, ask the user for the path

2. **Kill any existing processes on clawd-eyes ports:**
   ```bash
   lsof -ti :4000 :4001 :5173 2>/dev/null | xargs kill -9 2>/dev/null; echo "Ports cleared"
   ```

3. **Start the backend server** (launches Chromium automatically):
   ```bash
   cd <clawd-eyes-path> && npm start
   ```
   Run this in background mode using the Bash tool's `run_in_background` parameter.

4. **Wait for backend to start** (2-3 seconds)

5. **Start the web UI**:
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
   - A Chromium browser window should have opened
   - Navigate in the browser, select elements in the web UI, send to Claude Code

## Ports Used

| Port | Service |
|------|---------|
| 4000 | HTTP API |
| 4001 | WebSocket (live updates) |
| 5173 | Web UI (Vite dev server) |
| 9222 | Browser CDP (auto-launched) |

## Notes

- Backend automatically launches a Chromium browser via Playwright
- Both servers run in background - no manual terminals needed
- Use `/clawd-eyes:stop` to stop all services
- Use `/clawd-eyes:status` to check if services are running
