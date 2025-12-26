---
description: Export full session then compact working memory
allowed-tools: Bash,Write,Read,Glob,AskUserQuestion
---

Proactively reduce context usage while preserving everything via /export.

## Usage

```
/compact
```

## When to Use

- After reading many files (>20)
- Before starting a new major phase
- When responses feel slower
- When guardian shows WARNING (60% estimate)
- Preventatively during long sessions

## Steps

### 1. Preserve Everything First

Prompt the user:

```
Compaction initiated.

Please run the following command to preserve full session:

/export

Then save the output to: .claude/swarm/exports/pre-compact-$(date +%Y%m%d-%H%M%S).txt

(You can download the export or copy to clipboard, then save to the path above)
```

Wait for user confirmation that export was saved.

### 2. Extract Current Essentials

From working memory (do NOT re-read files), extract:

```markdown
## Current Essentials

**Compacted:** $(date -Iseconds)

### Active Goal

[What are you trying to accomplish?]

### Current Phase

[Where are you in the process?]

### Key Files (Paths Only - No Contents!)

- `path/to/file1.ts` - [Purpose/role]
- `path/to/file2.ts` - [Purpose/role]
- `path/to/file3.ts` - [Purpose/role]

### Immediate Next Actions

1. [Specific next step]
2. [Then this]
3. [Then this]

### Important Context Pointers

- Research findings: [path if exists]
- Implementation plan: [path if exists]
- Full pre-compact export: .claude/swarm/exports/pre-compact-[timestamp].txt
```

### 3. Archive Verbose Details

Take any verbose details from working memory and save to:

```
.claude/swarm/context/detailed-$(date +%Y%m%d-%H%M%S).md
```

This might include:
- Detailed analysis that's been done
- File contents that were read
- Lengthy explanations
- Background information

### 4. Clear Mental Cache

From working memory, DROP:

- ❌ File contents (reference paths instead)
- ❌ Verbose explanations (saved to detailed file)
- ❌ Conversation history details (in /export)
- ❌ Background context (in archives)

KEEP in working memory:

- ✓ Goal + phase
- ✓ File paths (not contents)
- ✓ Immediate next steps
- ✓ Pointers to research/plans

### 5. Report Compaction

```
✓ Context compacted

Full session preserved: .claude/swarm/exports/pre-compact-[timestamp].txt
Detailed findings archived: .claude/swarm/context/detailed-[timestamp].md

Working memory now holds:
- Active goal: [goal]
- Current phase: [phase]
- File references: [count] files (paths only)
- Next steps: [immediate actions]

Estimated reduction: 60-80% context freed
Full details available in export if needed.
```

## Expected Outcome

**Before compaction:**
- Working memory holds: file contents, conversation details, verbose explanations
- Context usage: 60-70% (estimated)

**After compaction:**
- Working memory holds: goal, phase, file paths, next steps
- Context usage: 20-30% (estimated)
- Everything preserved in exports for reference

## Notes

- Compaction is SAFE - nothing is lost (exported first)
- Use when context feels "heavy" or guardian warns
- Can reference detailed files or exports if needed later
- Enables longer sessions without hitting limits
