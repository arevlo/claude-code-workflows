---
description: Sync and consolidate findings from all agents into prioritized action items
allowed-tools: Bash,Read,Write
---

Consolidate all agent findings into a prioritized list of action items.

## Usage

```
/sync [--to-notion] [--to-github]
```

**Arguments:**
- `--to-notion` - Also save to Notion database
- `--to-github` - Create GitHub issues for critical items

## Steps:

1. **Gather all reports:**

   **bash/zsh (macOS, Linux, Git Bash, WSL):**
   ```bash
   # Collect all report files from last 60 minutes
   find .claude/swarm/reports -name "*.md" -mmin -60
   ```

   **PowerShell (Windows):**
   ```powershell
   # Collect all report files from last 60 minutes
   Get-ChildItem .claude/swarm/reports -Filter "*.md" |
     Where-Object { $_.LastWriteTime -gt (Get-Date).AddMinutes(-60) }
   ```

2. **Parse and deduplicate:**
   - Read each report
   - Extract issues with:
     - Severity (critical, warning, suggestion)
     - File location
     - Description
     - Suggested fix
   - Deduplicate by file:line combination

3. **Prioritize issues:**
   ```
   Priority scoring:
   - Critical (unhandled errors, security) = 100
   - Type errors = 80
   - Complexity warnings = 60
   - Style suggestions = 40
   - Documentation = 20
   ```

4. **Generate consolidated report:**
   - Write to `.claude/swarm/sync/sync-<timestamp>.md`
   - Format:
   ```markdown
   # Swarm Sync Report
   Generated: <timestamp>
   Agents: reviewer, type-analyzer, silent-hunter
   
   ## Critical (Fix Now)
   - [ ] figma.ts:45 - Unhandled promise rejection
   - [ ] api.ts:120 - Missing error boundary
   
   ## High Priority
   - [ ] handler.ts:120 - Reduce complexity (15 → <10)
   - [ ] types.ts:30 - Add explicit return type
   
   ## Suggestions
   - [ ] utils.ts:15 - Consider extracting helper
   ```

5. **Update shared context:**
   - Write summary to `.claude/swarm/context/latest.md`
   - This file can be loaded by main Claude session

6. **If `--to-notion`:**
   - Use Notion MCP to create tasks
   - Link to relevant code locations

7. **If `--to-github`:**
   - Create issues for critical items
   ```bash
   gh issue create --title "Fix: <issue>" --body "<details>"
   ```

## Output

```
SYNC COMPLETE
═══════════════════════════════════════════════════

Processed: 12 reports from 3 agents
Timeframe: Last 60 minutes

CONSOLIDATED ISSUES
┌──────────┬───────┬─────────────────────────────────┐
│ Priority │ Count │ Summary                         │
├──────────┼───────┼─────────────────────────────────┤
│ Critical │ 2     │ Unhandled async, missing catch  │
│ High     │ 4     │ Complexity, types               │
│ Medium   │ 3     │ Patterns, structure             │
│ Low      │ 5     │ Style, docs                     │
└──────────┴───────┴─────────────────────────────────┘

Report saved: .claude/swarm/sync/sync-1705312200.md
Context updated: .claude/swarm/context/latest.md

Next steps:
1. Review critical issues first
2. Run /load-context swarm to bring findings into session
3. Fix issues and agents will re-analyze automatically
```

## Notes

- Sync consolidates without stopping agents
- Agents continue watching and will catch new issues
- Use `/load-context swarm` to bring findings into main session
