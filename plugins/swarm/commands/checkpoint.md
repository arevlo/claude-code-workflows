---
description: Create checkpoint using /export for full session capture
allowed-tools: Bash,Write,Read,Glob,AskUserQuestion
---

Quick checkpoint with full session export + minimal summary.

## Usage

```
/checkpoint [label]
```

## Examples

```
/checkpoint "research-complete"
/checkpoint "before-refactor"
/checkpoint
```

## Steps

### 1. Generate timestamp and label

Extract label from arguments or use default:

```bash
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LABEL="${args:-manual}"
```

### 2. Trigger /export for full session capture

**IMPORTANT:** The `/export` command must be executed by the user or Claude via the command interface.

Prompt the user:

```
Checkpoint initiated.

Please run the following command:

/export

Then save the output to: .claude/swarm/exports/checkpoint-${TIMESTAMP}-${LABEL}.txt

(You can download the export or copy to clipboard, then save to the path above)
```

Wait for user confirmation that export was saved.

### 3. Generate minimal working summary

Extract from current working memory (do NOT re-read files):

```markdown
## Checkpoint: ${LABEL}

**Timestamp:** ${TIMESTAMP}

### Current Goal

[What are you working on?]

### Work Completed

- [Bullet point summary of what's been done]
- [Focus on outcomes, not details]

### Files Modified

- `path/to/file.ts` - [What changed]
- `path/to/other.ts` - [What changed]

### Current Phase/Status

[Where are you in the task?]

### Immediate Next Steps

1. [Next action]
2. [After that]

### Context Pointers

- Full export: .claude/swarm/exports/checkpoint-${TIMESTAMP}-${LABEL}.txt
- Research: [path if exists]
- Plan: [path if exists]
```

### 4. Save summary

Write summary to:

```
.claude/swarm/progress/summary-${TIMESTAMP}-${LABEL}.md
```

### 5. Update metrics

```bash
jq ".last_checkpoint = \"${TIMESTAMP}\"" .claude/swarm/guardian/metrics.json > tmp && mv tmp .claude/swarm/guardian/metrics.json
```

### 6. Report completion

```
✓ Checkpoint created: ${LABEL}

Full export: .claude/swarm/exports/checkpoint-${TIMESTAMP}-${LABEL}.txt
Summary: .claude/swarm/progress/summary-${TIMESTAMP}-${LABEL}.md

To resume from this checkpoint later, use: /resume
```

## Notes

- Checkpoint includes FULL session via /export (complete safety net)
- Summary is minimal for memory efficiency
- Use /resume to load from checkpoint in future sessions
- Checkpoints auto-expire after 30 days (configurable)

## Difference from /save-context

| Feature | /checkpoint | /save-context |
|---------|------------|---------------|
| Speed | Fast (~5s) | Slower (picker + generation) |
| Destination | Local only | Notion/GitHub/Local |
| Format | Export + summary | Full session summary |
| Use case | Mid-task savepoints | End of session archival |
| Integration | None | Notion/GitHub |
