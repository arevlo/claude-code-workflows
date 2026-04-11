---
description: Stop running swarm agents gracefully
allowed-tools: Bash,Read,Write,AskUserQuestion
---

Stop one or all running swarm agents.

## Usage

```
/stop [agent] [--all] [--force]
```

**Arguments:**
- `agent` - Stop specific agent
- `--all` - Stop all agents (default if no agent specified)
- `--force` - Force kill without graceful shutdown

## Steps:

1. **Check for active swarm:**
   - Read `.claude/swarm/manifest.json`
   - If no swarm active, inform user

2. **If specific agent:**

   **bash/zsh (macOS, Linux, Git Bash, WSL):**
   ```bash
   pid=$(cat .claude/swarm/pids/<agent>.pid)
   kill $pid
   rm .claude/swarm/pids/<agent>.pid
   ```

   **PowerShell (Windows):**
   ```powershell
   $pid = Get-Content .claude/swarm/pids/<agent>.pid
   Stop-Process -Id $pid -Force
   Remove-Item .claude/swarm/pids/<agent>.pid
   ```

3. **If `--all` or no args:**
   - Ask for confirmation
   - Stop all agents:

   **bash/zsh (macOS, Linux, Git Bash, WSL):**
   ```bash
   for pid_file in .claude/swarm/pids/*.pid; do
     pid=$(cat "$pid_file")
     kill $pid 2>/dev/null
     rm "$pid_file"
   done
   ```

   **PowerShell (Windows):**
   ```powershell
   Get-ChildItem .claude/swarm/pids/*.pid | ForEach-Object {
     $pid = Get-Content $_.FullName
     Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
     Remove-Item $_.FullName
   }
   ```

4. **Archive session:**
   - Move reports to `.claude/swarm/archive/<timestamp>/`
   - Keep last 5 sessions

5. **Clean up:**
   ```bash
   rm .claude/swarm/manifest.json
   rm .claude/swarm/started_at
   ```

6. **Final sync:**
   - Run `/sync` to consolidate any remaining findings
   - Output summary of session

## Output

```
STOPPING SWARM
═══════════════════════════════════════════════════

Stopping agents...
  [OK] reviewer (PID 12345) - stopped
  [OK] type-analyzer (PID 12346) - stopped
  [OK] silent-hunter (PID 12347) - stopped

SESSION SUMMARY
───────────────────────────────────────────────────
Duration: 1h 23m
Reports generated: 45
Issues found: 14 (2 critical, 4 high, 8 other)

Archives saved to: .claude/swarm/archive/2024-01-15-103000/

Final sync report: .claude/swarm/sync/final-1705312200.md
```

## Notes

- Always generates final sync before stopping
- Archives are kept for reference
- Use `/swarm` to start a new session
