---
description: Resume from a prior checkpoint or auto phase export
allowed-tools: Bash,Read,Glob,AskUserQuestion
---

Load context from a prior session export to continue work.

## Usage

```
/resume                  # Interactive: choose from list
/resume --latest         # Load most recent export
/resume <filename>       # Load specific export
```

## Steps

### 1. Find Available Exports

List exports from multiple sources:

```bash
echo "=== Available Checkpoints ==="
echo ""
echo "Recent checkpoints:"
find .claude/swarm/exports -name "checkpoint-*.txt" -type f -mtime -30 2>/dev/null | sort -r | head -5

echo ""
echo "Auto mode phases:"
find .claude/swarm/exports -name "auto-phase*.txt" -type f -mtime -30 2>/dev/null | sort -r | head -5

echo ""
echo "Emergency/warning saves:"
find .claude/swarm/exports -name "warning-*.txt" -o -name "critical-*.txt" -o -name "emergency-*.txt" -type f -mtime -30 2>/dev/null | sort -r | head -5
```

### 2. If Interactive (no args)

Use AskUserQuestion to let user select:

```json
{
  "questions": [{
    "question": "Which checkpoint would you like to resume from?",
    "header": "Resume",
    "options": [
      {
        "label": "checkpoint-20250126-auth-research.txt",
        "description": "Manual checkpoint from 2 hours ago"
      },
      {
        "label": "auto-phase1-complete-20250126.txt",
        "description": "Auto mode Phase 1 from yesterday"
      },
      {
        "label": "warning-60pct-20250125.txt",
        "description": "Auto-save at 60% threshold from 2 days ago"
      }
    ],
    "multiSelect": false
  }]
}
```

### 3. If --latest flag

Load the most recent export by modification time:

```bash
LATEST=$(find .claude/swarm/exports -name "*.txt" -type f -mtime -30 2>/dev/null | sort -r | head -1)
```

### 4. Load Selected Export

Read the export file and extract key information:

- **Goal:** What was being worked on
- **Progress:** What was completed
- **Current state:** Where work left off
- **Next steps:** What should happen next
- **File references:** Which files were involved

**IMPORTANT:** Load the export content but DO NOT reproduce the entire conversation. Extract only the essential context.

### 5. Load Corresponding Summary (if exists)

Check for matching summary file:

```bash
# If loading checkpoint-20250126-auth-research.txt
# Look for: .claude/swarm/progress/summary-20250126-auth-research.md

# If loading auto-phase1-complete-20250126.txt
# Look for: .claude/swarm/progress/auto-phase1-20250126.md

# Extract timestamp from export filename and look for summary
TIMESTAMP=$(echo "$EXPORT_FILE" | grep -o '[0-9]\{8\}-[0-9]\{6\}')
SUMMARY=$(find .claude/swarm/progress -name "*${TIMESTAMP}*.md" 2>/dev/null | head -1)
```

If summary exists, load it as the **primary working memory**.

### 6. Present Resume Summary

```
┌─────────────────────────────────────────────────────────┐
│  RESUMING FROM CHECKPOINT                               │
│                                                         │
│  Source: checkpoint-20250126-auth-research.txt          │
│  Created: 2025-01-26 14:30                              │
│                                                         │
│  Goal: Implement authentication system                  │
│                                                         │
│  Completed:                                             │
│  - [✓] Phase 1: Research (OAuth patterns identified)    │
│  - [✓] Dependencies analyzed (passport.js suitable)     │
│  - [✓] File structure reviewed                          │
│                                                         │
│  Resuming at: Ready to create implementation plan       │
│                                                         │
│  Working memory loaded from:                            │
│  .claude/swarm/progress/summary-20250126.md             │
│                                                         │
│  Full export available for reference at:                │
│  .claude/swarm/exports/checkpoint-20250126.txt          │
│                                                         │
│  Ready to continue. What would you like to do next?     │
└─────────────────────────────────────────────────────────┘
```

### 7. Working Memory Strategy

**Hybrid approach:**

- **Primary:** Load summary (compacted, memory-efficient)
- **Secondary:** Full export available for reference
- **On-demand:** Read from export if specific details needed

This keeps context low while preserving full access.

## Notes

- Prioritize loading summaries over full exports (memory efficient)
- Full exports available for detail lookup
- Can resume from any checkpoint or auto phase
- Checkpoints older than 30 days auto-archived
- If no summary exists, extract key context from export (but don't load entire conversation)
