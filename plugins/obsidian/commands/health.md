---
skill: obsidian:health
type: local
title: Vault Health Dashboard
description: Display a health dashboard for the Obsidian vault showing orphans, dead ends, broken links, open tasks, and a health score.
allowed-tools: Bash
---

# Vault Health Dashboard

Run multiple CLI diagnostic commands and present a unified health report.

## Steps

### 1. Gather Metrics

Run these commands in parallel:

```bash
obsidian vault
obsidian orphans total
obsidian deadends total
obsidian unresolved total
obsidian tasks todo total
obsidian tags total
```

Extract from `obsidian vault`:
- `files` -- total file count
- `folders` -- total folder count
- `size` -- vault size in bytes

### 2. Compute Health Score

Calculate a score from 0-100:

```
orphan_ratio  = orphans / files
deadend_ratio = deadends / files
unresolved_penalty = min(unresolved * 2, 30)

score = 100 - (orphan_ratio * 40) - (deadend_ratio * 30) - unresolved_penalty
score = max(0, min(100, score))
```

Rating:
- 90-100: Excellent
- 70-89: Good
- 50-69: Needs attention
- 0-49: Poor

### 3. Display Dashboard

```
Vault Health -- {vault name}
=======================================

Score: {score}/100 ({rating})

  Files:      {files}
  Folders:    {folders}
  Size:       {size human-readable}

  Orphans:    {orphans}  ({orphan_ratio}% of files)
  Dead ends:  {deadends} ({deadend_ratio}% of files)
  Unresolved: {unresolved} broken links
  Open tasks: {tasks}
  Tags:       {tags}

=======================================
```

### 4. Recommendations

Based on the metrics, suggest actions:

- **Orphans > 10%:** "Run `/obsidian:graph:sync` to connect orphaned notes"
- **Dead ends > 15%:** "Consider adding outgoing links to dead-end notes"
- **Unresolved > 0:** "Run `obsidian unresolved verbose` to see broken links"
- **Open tasks > 50:** "Run `/obsidian:tasks` to review and triage"

### 5. Offer Drill-downs

Offer to show details:
- "List orphan files?"
- "Show broken links?"
- "Show tag distribution?"

Execute the verbose variant of the relevant command if the user requests it:
```bash
obsidian orphans verbose
obsidian unresolved verbose
obsidian tags counts sort=count
```
