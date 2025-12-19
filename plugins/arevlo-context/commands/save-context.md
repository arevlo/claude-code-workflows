---
description: Save current session context to multiple destinations
allowed-tools: mcp__notion__notion-create-pages,mcp__notion__notion-search,Bash,Write,Glob,AskUserQuestion
---

Save the current session context to your choice of storage destinations.

## Configuration

**Notion database name:** `_clawd` (customize to match your Notion setup)
**Notion data source ID:** Update to match your database's data source ID

## Steps:

### 1. Detect project
Detect project from current working directory:
- Map directory names to project names (customize for your setup)
- Or ask user to specify

### 2. Check available destinations
Run these checks silently to determine which options to show:
- **Local /tmp:** Always available
- **Notion:** Always available (requires Notion MCP)
- **GitHub Issue:** Check if in a git repo with remote: `git remote get-url origin`
- **Docs folder:** Check if `docs/` directory exists using Glob
- **Plans folder:** Check if `plans/` directory exists using Glob

### 3. Show destination picker
ALWAYS ask the user where to save - present available options:

```
Where would you like to save this context?

1. Quick save to /tmp (recommended for checkpoints)
2. Notion (_clawd database)
3. GitHub Issue (in current repo)     [only if git remote exists]
4. Docs folder (./docs/context/)      [only if docs/ exists]
5. Plans folder (./plans/)            [only if plans/ exists]

Select destination:
```

**Note:** Option 1 (/tmp) is fastest and recommended for quick checkpoints during work.
Use Notion or GitHub for persistent, searchable context storage.

### 4. Ask for tag type
ALWAYS show all 4 options:
- Context (session context and learnings)
- Summary (summary of work done)
- Spec (technical specification)
- Reference (reference material)

### 5. Ask for a title
Suggest one based on work done this session.

### 6. Generate session summary
Create comprehensive session summary including:
- What was accomplished this session
- Files created or modified
- Key decisions made and rationale
- Open questions or next steps

### 7. Save to selected destination

**If Local /tmp:**
- Create directory `/tmp/claude-contexts/` if it doesn't exist
- Save as markdown file: `{YYYY-MM-DD}-{HH-mm}-{project}.md`
- Use Write tool
- Also update swarm context pointer if `.claude/swarm/` exists:
  ```bash
  # Update latest context pointer for swarm integration
  if [ -d ".claude/swarm/context" ]; then
    echo "/tmp/claude-contexts/{filename}" > .claude/swarm/context/latest-save.txt
  fi
  ```
- Report full path to user

**If Notion:**
- Use `mcp__notion__notion-create-pages` to create page in `_clawd` database
- Set Name (title), Project (select), and Tags (multi-select) properties
- Add session summary as page content

**If GitHub Issue:**
- First check if `gh` CLI is installed by running: `which gh`
- If NOT installed, show this message and stop:
  ```
  GitHub CLI (gh) is not installed. Install it to use GitHub Issues for context storage.

  Install with:
    brew install gh          # macOS
    sudo apt install gh      # Ubuntu/Debian
    winget install GitHub.cli  # Windows

  After installing, authenticate with: gh auth login
  ```
- If installed, get repo from: `git remote get-url origin`
- Parse owner/repo from the remote URL (handle both SSH and HTTPS formats)
- Create issue using:
  ```bash
  gh issue create --title "[{Tag}] {title}" --body "{content}"
  ```
- Title prefix based on tag: `[Context]`, `[Summary]`, `[Spec]`, or `[Reference]`
- Report issue URL to user

**If Docs folder:**
- Create `docs/context/` subdirectory if it doesn't exist
- Save as markdown file: `{YYYY-MM-DD}-{slug-title}.md`
- Slugify title: lowercase, replace spaces with hyphens, remove special characters
- Use Write tool
- Report relative path to user

**If Plans folder:**
- First check if a plan with similar name already exists in `plans/`
- If exists, ask user: "A plan '{filename}' already exists. Overwrite or create new?"
- Save as markdown file: `{slug-title}.md` (no date prefix for plans)
- Slugify title: lowercase, replace spaces with hyphens, remove special characters
- Use Write tool
- Report relative path to user

## Content Template

```markdown
# Session Context: {title}

**Project:** {project}
**Date:** {YYYY-MM-DD HH:mm}
**Tags:** {tag type}

---

## What Was Accomplished
[List of accomplishments]

---

## Files Modified

| File | Change |
|------|--------|
| path/to/file | Description of change |

---

## Key Decisions
- [Decision 1]
- [Decision 2]

---

## Open Questions / Next Steps
1. [Next step]
```
