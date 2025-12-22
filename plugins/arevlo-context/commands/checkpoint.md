---
description: Quick checkpoint of current session state (faster than /save-context)
allowed-tools: Bash,Write,Read,Glob
---

Create a fast checkpoint without the full save-context flow. Designed for mid-task use.

## Usage

```
/checkpoint              # Auto-generate label from current work
/checkpoint <label>      # Use specific label
```

**Examples:**
```
/checkpoint
/checkpoint "auth-middleware-done"
/checkpoint "before-refactor"
```

## Steps

### 1. Detect current state

Gather minimal context:
- Current working directory (project name)
- Recent git changes if available:
  ```bash
  git diff --name-only HEAD~1 2>/dev/null | head -10 || echo "(no git changes)"
  ```

### 2. Generate checkpoint content

Create a minimal checkpoint (NOT a full session summary):

```markdown
# Checkpoint: {label or auto-generated}

**Project:** {project}
**Saved:** {ISO timestamp}
**Type:** Quick checkpoint

---

## Current Goal
[One sentence - what you're working on]

## Work Completed
- [Bullet points of what's done]

## Files Modified
- `path/to/file.ts`
- `path/to/other.ts`

## Next Steps
1. [Immediate next action]
2. [Following action]

---

_Resume with: /load-context or manually read this file_
```

### 3. Save checkpoint

**Create directories if needed:**

**bash/zsh:**
```bash
mkdir -p .claude/swarm/progress
```

**PowerShell:**
```powershell
New-Item -ItemType Directory -Force -Path ".claude/swarm/progress"
```

**Generate filename:**
- Format: `checkpoint-{YYYYMMDD-HHmm}-{label}.md`
- Sanitize label: lowercase, replace spaces with hyphens, remove special chars
- If no label provided, use "quick" as default

**Save using Write tool** to `.claude/swarm/progress/checkpoint-{timestamp}-{label}.md`

### 4. Update context pointer

**bash/zsh:**
```bash
mkdir -p .claude/swarm/context
echo ".claude/swarm/progress/checkpoint-{filename}" > .claude/swarm/context/latest-save.txt
```

**PowerShell:**
```powershell
New-Item -ItemType Directory -Force -Path ".claude/swarm/context"
".claude/swarm/progress/checkpoint-{filename}" | Out-File -FilePath ".claude/swarm/context/latest-save.txt"
```

### 5. Report success (one line)

Output a single line confirmation:
```
Checkpoint saved: .claude/swarm/progress/checkpoint-{filename}
```

## Differences from /save-context

| Aspect | /checkpoint | /save-context |
|--------|-------------|---------------|
| Speed | Fast (no prompts) | Slower (interactive) |
| Format | Minimal | Comprehensive |
| Destination | Local only | Multiple options |
| Use case | Mid-task saves | End of session |
| Prompts | None | Destination, tag, title |

## When to Use

- Before starting a risky change
- After completing a significant step
- When context feels heavy
- Before `/compact`
- As a quick save point during long sessions

## Notes

- Checkpoints are lightweight - create them freely
- Use `/load-context` to find and load checkpoints later
- Checkpoints are stored alongside swarm progress files
- The latest checkpoint pointer helps `/auto --resume` find state
