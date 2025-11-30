---
description: Create or update prompts/changelogs in Notion database for Figma Make
allowed-tools: mcp__notion__notion-create-pages,mcp__notion__notion-search,mcp__notion__notion-fetch,mcp__notion__notion-update-page,AskUserQuestion
---

Create or update entries in a Notion database for Figma Make workflows.

## Configuration

**Database name:** `_make` (customize to match your Notion setup)
**Data source ID:** Update to match your database's data source ID

## Steps:

1. **Detect project** from current working directory:
   - Map directory names to project names (customize for your setup)
   - Or ask user to specify

2. **Ask entry type**: Prompt or Changelog

3. **For Changelogs - Check for existing page**:
   - Search database for `Changelog: [Make] {Project}` with Tags=Changelog
   - If found: fetch page and check if today's date section exists
     - Today exists → append to that section
     - Today missing → add new date section at TOP (below callout)
   - If not found: create new changelog page

4. **Ask for title** (new pages only):
   - Prompts: `Prompt: {Feature Name}`
   - Changelogs: `Changelog: [Make] {Project Name}`

5. **For Prompts - Auto-search related context**:
   - Search context database for specs/context matching project
   - Search prompts database for previous prompts on same project
   - Show top 5 matches and confirm which to include as references

6. **Generate content**:

   **For Prompts** (clear, actionable for Figma Make):
   - Bold one-liner describing what to build
   - Problem/Context (2-3 sentences WHY)
   - Reference links to Notion specs/context from step 5
   - Clear instructions with ASCII diagrams if needed
   - Keep focused on ONE feature

   **For Changelogs** (new or update):
   - Use `<mention-date start="YYYY-MM-DD"/>` for today
   - Overview of what was accomplished
   - Components with file paths
   - Status indicator

7. **Create or Update**:
   - **New page**: notion-create-pages with Name, Project, Tags
   - **Update changelog**: notion-update-page with insert_content_after or replace_content_range

## Key Guidelines

**For Prompts:**
- Be explicit about spatial relationships (use ASCII diagrams)
- Include actual CSS variables when styling is involved
- Reference original prompts for follow-ups
- One feature per prompt
- Always link to Notion specs/context

**For Changelog Updates:**
- Newest entries at TOP (below callout, above older dates)
- Same date = append to existing section, don't create duplicate
- Include file paths for components modified
