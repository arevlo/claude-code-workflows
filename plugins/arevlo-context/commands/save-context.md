---
description: Save current session context to Notion database
allowed-tools: mcp__notion__notion-create-pages,mcp__notion__notion-search,AskUserQuestion
---

Save the current session context to a Notion database.

## Configuration

**Database name:** `_clawd` (customize to match your Notion setup)
**Data source ID:** Update to match your database's data source ID

## Steps:

1. **Detect project** from current working directory and confirm with user:
   - Map directory names to project names (customize for your setup)
   - Or ask user to specify

2. **Ask user to select tag type** - ALWAYS show all 4 options:
   - Context (session context and learnings)
   - Summary (summary of work done)
   - Spec (technical specification)
   - Reference (reference material)

3. **Ask for a title** - suggest one based on work done this session

4. **Generate comprehensive session summary** including:
   - What was accomplished this session
   - Files created or modified
   - Key decisions made and rationale
   - Open questions or next steps

5. **Create page** in database:
   - Set Name, Project, and Tags properties
   - Add the session summary as page content

Format the content with clear sections using markdown headers.

## Template

```markdown
## Session Summary - [DATE]

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
