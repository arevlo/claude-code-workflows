---
description: Check current context state and recent saves
allowed-tools: Bash,Glob,Read
---

Show current context usage status and recent saves/checkpoints.

## Usage

```
/context-status
```

## Steps:

### 1. Check recent saves in /tmp

List recent context saves:

**bash/zsh:**
```bash
echo "=== Recent /tmp saves ==="
ls -lt /tmp/claude-contexts/*.md 2>/dev/null | head -5 || echo "  (none found)"
```

**PowerShell:**
```powershell
Write-Host "=== Recent /tmp saves ==="
Get-ChildItem /tmp/claude-contexts/*.md -ErrorAction SilentlyContinue |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 5 |
  ForEach-Object { $_.Name }
if (-not $?) { Write-Host "  (none found)" }
```

### 2. Check swarm progress files

List checkpoint files:

**bash/zsh:**
```bash
echo "=== Swarm progress checkpoints ==="
ls -lt .claude/swarm/progress/*.md 2>/dev/null | head -5 || echo "  (none found)"
```

**PowerShell:**
```powershell
Write-Host "=== Swarm progress checkpoints ==="
Get-ChildItem .claude/swarm/progress/*.md -ErrorAction SilentlyContinue |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 5 |
  ForEach-Object { $_.Name }
if (-not $?) { Write-Host "  (none found)" }
```

### 3. Check active auto progress

Look for recent auto-mode checkpoints:

**bash/zsh:**
```bash
echo "=== Active /auto progress ==="
ls -lt .claude/swarm/progress/auto-*.md 2>/dev/null | head -3 || echo "  (no active /auto session)"
```

### 4. Check swarm reports

List recent agent findings:

**bash/zsh:**
```bash
echo "=== Recent swarm reports ==="
ls -lt .claude/swarm/reports/*.md 2>/dev/null | head -5 || echo "  (none found)"
```

### 5. Display formatted status

Output in this format:

```
Context Status
══════════════════════════════════════════════════════════

Recent Saves (/tmp/claude-contexts/):
  • 2024-12-19-1430-project.md (2h ago)
  • 2024-12-19-1200-project-emergency.md (4h ago)
  (or "No recent saves")

Swarm Progress (.claude/swarm/progress/):
  • auto-2024-12-19-phase2.md (1h ago)
  • reviewer-checkpoint.md (3h ago)
  (or "No checkpoints")

Active /auto Session:
  • Goal: <extracted from checkpoint>
  • Phase: Plan Approved
  • Resume with: /auto --resume
  (or "No active session")

Recent Swarm Reports (.claude/swarm/reports/):
  • reviewer-1734567890.md (30m ago)
  • type-analyzer-1734567800.md (45m ago)
  (or "No reports")

══════════════════════════════════════════════════════════

💡 Tips:
  • Save context now: /save-context
  • Load prior context: /load-context
  • Resume auto mode: /auto --resume
```

### 6. Extract active auto session info (if exists)

If an auto checkpoint exists, read the most recent one and extract:
- Goal (from `# Auto Checkpoint: <goal>` line)
- Phase (from `Phase:` line)
- Next steps summary

## Notes

- This command is read-only and does not modify any files
- Use `/save-context` to create a new save
- Use `/load-context` to load prior context
- Use `/auto --resume` to continue an interrupted auto session
