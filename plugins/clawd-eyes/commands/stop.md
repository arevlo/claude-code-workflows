---
description: Stop clawd-eyes processes and free ports
allowed-tools: Bash
---

# Stop clawd-eyes

Stop all clawd-eyes processes and free up the ports.

## Instructions

1. **Find and kill processes on each port**

   For each port (4000, 4001, 3000, 9222):
   ```bash
   lsof -ti :<port> | xargs kill -9 2>/dev/null
   ```

2. **Verify ports are free**
   ```bash
   lsof -i :4000,:4001,:3000,:9222
   ```
   Should return empty if all processes stopped.

3. **Report to user**
   - Confirm which processes were stopped
   - Confirm all ports are now free

## Quick One-Liner

```bash
lsof -ti :4000,:4001,:3000,:9222 | xargs kill -9 2>/dev/null; echo "clawd-eyes stopped"
```

## Notes

- Some ports may already be free - that's fine
- The 9222 port is Chrome's CDP port, killing it closes the browser
- After stopping, you can restart with `/clawd-eyes:start`
