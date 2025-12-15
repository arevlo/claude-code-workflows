---
description: Start clawd-eyes backend server and web UI
allowed-tools: Bash,Read
---

# Start Clawd-Eyes

Start the clawd-eyes visual browser inspector servers.

## Instructions

1. **Find the clawd-eyes project:**
   - Search for a directory containing `clawd-eyes` with a `package.json` that has `"name": "clawd-eyes"`
   - Check common locations: current directory, parent directories, or ask the user
   - If not found, ask the user for the path to their clawd-eyes installation

2. **Check if servers are already running** on the ports:
   - Port 4000 (HTTP API)
   - Port 4001 (WebSocket)
   - Port 5173 (Web UI)
   - Port 9222 (Chrome DevTools)

3. If any ports are in use, inform the user and suggest running `/clawd-eyes:stop` first

4. If ports are free, start the servers from the clawd-eyes directory:

   **Start backend** (in background):
   ```bash
   cd <clawd-eyes-path> && npm start &
   ```

   **Start web UI** (in background):
   ```bash
   cd <clawd-eyes-path>/web && npm run dev &
   ```

5. Wait a few seconds for servers to start

6. Report the status:
   - Backend API: http://localhost:4000
   - WebSocket: ws://localhost:4001
   - Web UI: http://localhost:5173
   - CDP: ws://localhost:9222

7. Inform the user they can open http://localhost:5173 in their browser

## Ports Used

| Port | Service |
|------|---------|
| 4000 | HTTP API |
| 4001 | WebSocket (live updates) |
| 5173 | Web UI (Vite dev server) |
| 9222 | Chrome DevTools Protocol |
