---
description: Save session progress for resuming after /clear (mid-task checkpoints with full state)
allowed-tools: Bash,Write,Read,Glob
---

Captures a complete progress snapshot so the session can be cleared and resumed without re-inspection.

## Usage

```
/progress-save
```

Use before `/clear` on a long multi-step session, at natural checkpoints, or when the user says "save progress", "save my place", "context save".

## Steps

### 1. Gather Context

- Review recent conversation for current in-progress state
- Check if a plan file exists in the project's `plans/` directory
- Identify all completed work, in-progress items, and remaining steps

### 2. Find Save Location

Priority order:
1. Project-specific progress directory if configured
2. `/tmp/claude-progress-YYYYMMDD.md` — fallback

Get today's date:

**bash/zsh:**
```bash
date +%Y-%m-%d
```

**PowerShell:**
```powershell
Get-Date -Format "yyyy-MM-dd"
```

### 3. Write Progress File

```markdown
# Progress: [Task Name]
_Saved: [date]_
_Plan file: [path]_

## Completed
[Steps done — include artifact IDs, file paths, what was built]

## In Progress
[Exact current step with state: position, batch number, partial results]

## Remaining
[Steps in order with enough technical detail to execute without re-inspecting.
Include concrete values: IDs, positions, counts, variable IDs]

## Key State
- Component IDs (getNodeById calls)
- Variable IDs (setBoundVariable calls)
- Layout positions (x, y, w, h)
- Helper function snippets to paste verbatim
- Fonts to pre-load
- Section/page IDs

## Known Issues
[Workarounds, gaps, timeout patterns to watch for]

## Resume From Here
[Single self-contained prompt to paste after /clear:
- Path to this file and plan file
- Which skill to invoke first
- Exact next action with specific parameters]
```

### 4. Report to User

After writing:
1. Say: **"Progress saved to `[path]`"**
2. Show one-line summary: X steps done, Y remaining
3. Copy the **Resume prompt** to clipboard:
   - **macOS:** `echo '<prompt>' | pbcopy`
   - **Linux:** `echo '<prompt>' | xclip -selection clipboard`
   - **Windows PowerShell:** `Set-Clipboard '<prompt>'`
4. Say: **"Resume prompt copied to clipboard. Run `/clear` and paste to continue."**

Do NOT run `/clear` automatically.

## Rules

- **Be specific**: Real node IDs, variable IDs, x/y coordinates — not prose descriptions
- **Include code snippets**: Helper functions in the Key State section so the next session doesn't re-derive them
- **Capture positional state**: For canvas work, record the exact next x/y coordinate
- **One resume prompt**: Self-contained, no multi-step setup required
- **Ephemeral is fine**: `/tmp/` files survive until reboot; good enough for same-day resumption

## Differences from /checkpoint

| Aspect | /progress-save | /checkpoint |
|--------|---------------|-------------|
| Detail | Comprehensive state dump | Minimal snapshot |
| Resume prompt | Yes, clipboard-ready | No |
| Key state | Full IDs, positions, snippets | Just files and next steps |
| Use case | Before /clear on long sessions | Quick mid-task saves |
