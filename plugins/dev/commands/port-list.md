---
description: Use when the user wants to see all listening ports and what processes are using them
allowed-tools: Bash
---

# Port List

Show all listening TCP ports with their app names and PIDs.

## Instructions

1. Run `sudo lsof -iTCP -sTCP:LISTEN -n -P` to list all listening ports
2. Format output as a table: PORT, APP NAME, PID
3. Sort by port number
