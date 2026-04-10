---
description: Check and kill processes using specific ports
allowed-tools: Bash,AskUserQuestion
---

# Kill Port

Check which processes are using specific ports and optionally kill them.

## Instructions

1. Ask the user which port(s) they want to check (e.g., 3000, 8080, etc.)
2. For each port, run `lsof -i :<port>` to check what's using it
3. If nothing is using the port, inform the user
4. If something is using the port, show:
   - The process name (COMMAND)
   - The PID
   - The user running it
   - Full command details
5. Ask if they want to kill the process(es)
6. If yes, use `kill -9 <PID>` to terminate the process
7. Verify the process was killed by running `lsof -i :<port>` again

## Common Ports to Check
- 3000 (Next.js default)
- 4001 (Lighthouse)
- 8080 (Backend services)
- 5432 (PostgreSQL)
- 6379 (Redis)
- 9090 (Prometheus)

## Safety Notes
- Always show what will be killed before killing
- Warn if the process is owned by another user
- Use `kill -9` (SIGKILL) only after confirmation
- Suggest trying `kill <PID>` (SIGTERM) first for graceful shutdown if appropriate
