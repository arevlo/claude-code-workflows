---
description: Check current context health metrics and alerts
allowed-tools: Bash,Read,Glob
---

Display current context health based on proxy signal tracking.

## Usage

```
/health           # Show current metrics and any alerts
/health --reset   # Reset metrics (start fresh tracking)
```

## Steps

### 1. Check if guardian directory exists

**bash/zsh:**
```bash
if [ ! -d ".claude/swarm/guardian" ]; then
  echo "Health tracking not initialized. Run any command to start tracking."
  exit 0
fi
```

### 2. Read current metrics

**bash/zsh:**
```bash
cat .claude/swarm/guardian/metrics.json 2>/dev/null || echo "{}"
```

Parse the JSON to extract:
- `alert_level`: Current level (good/watch/warning/critical)
- `tool_invocations`: Total tool calls
- `message_count`: Estimated message weight
- `file_reads`: Number of Read/Glob/Grep calls
- `code_edits`: Number of Edit/Write calls
- `session_start`: When tracking started
- `last_checkpoint`: Last checkpoint timestamp (if any)

### 3. Display formatted status

Output in this format:

```
Context Health Status
══════════════════════════════════════════════════════════════

Status: [GOOD|WATCH|WARNING|CRITICAL]

Session Metrics:
  Tool invocations:  {count}
  File reads:        {count} / 50 threshold
  Code edits:        {count} / 30 threshold
  Message weight:    {count} / 30 threshold

Progress bars (visual):
  Reads:  [████████░░░░░░░░░░░░] 40%
  Edits:  [██████░░░░░░░░░░░░░░] 30%
  Weight: [████░░░░░░░░░░░░░░░░] 20%

Last checkpoint: {timestamp or "None"}
Session started: {timestamp}

══════════════════════════════════════════════════════════════
```

Use visual indicators:
- GOOD: Continue normally
- WATCH: Consider checkpointing soon
- WARNING: Checkpoint now, consider /compact
- CRITICAL: Save immediately, wrap up work

### 4. Show recent alerts (if any)

Check for alerts file:

**bash/zsh:**
```bash
if [ -f ".claude/swarm/guardian/alerts.md" ]; then
  # Show last 20 lines of alerts
  tail -20 .claude/swarm/guardian/alerts.md
fi
```

### 5. Show recommendations based on level

**If GOOD:**
```
Recommendations:
  - Continue working normally
  - Health tracking is active
```

**If WATCH:**
```
Recommendations:
  - Save a checkpoint soon: /checkpoint
  - Monitor progress with /health
```

**If WARNING:**
```
Recommendations:
  - Save checkpoint NOW: /checkpoint
  - Consider compacting context: /compact
  - Wrap up current task before starting new work
```

**If CRITICAL:**
```
Recommendations:
  - IMMEDIATELY save: /checkpoint "emergency"
  - Run /compact to reduce context
  - Complete current work gracefully
  - Avoid starting new complex operations
```

### 6. Handle --reset flag

If `--reset` is provided:

**bash/zsh:**
```bash
rm -f .claude/swarm/guardian/metrics.json
rm -f .claude/swarm/guardian/alerts.md
echo "Health metrics reset. Tracking will restart on next tool use."
```

## Thresholds Reference

| Signal | Threshold | Meaning |
|--------|-----------|---------|
| File reads | > 50 | Heavy file exploration |
| Code edits | > 30 | Significant modifications |
| Message weight | > 30 | Many tool calls / tasks |
| Tool invocations | > 100 | Very active session |

| Warning Signals | Level |
|-----------------|-------|
| 0-1 | GOOD |
| 2 | WATCH |
| 3 | WARNING |
| 4+ | CRITICAL |

## Notes

- Health tracking uses proxy signals, not actual context measurement
- Metrics are estimates - actual context usage may vary
- Tracking resets at session start (via SessionStart hook)
- Use `/checkpoint` to save state, `/compact` to reduce context
