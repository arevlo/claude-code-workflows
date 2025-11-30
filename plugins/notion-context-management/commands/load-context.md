---
description: Search and load prior session contexts from Notion
argument-hint: <search query>
allowed-tools: mcp__notion__notion-search,mcp__notion__notion-fetch,AskUserQuestion
---

Search for and display prior session contexts from a Notion database.

Search query: $ARGUMENTS

## Configuration

**Database name:** `_clawd` (customize to match your Notion setup)

## Steps:

1. **Search database** for contexts matching the query
   - If no query provided, show recent contexts
   - Search in page titles and content

2. **Display results** showing:
   - Name/title
   - Project
   - Tags
   - Created date

3. **Ask user** which context they want to view (if multiple results)

4. **Fetch and display** the full content of the selected context

## Search Strategies

- **By Project**: Search for project name
- **By Topic**: Search for feature or topic
- **By Type**: Filter by tag (Context, Summary, Spec, Reference)
- **By Date**: Search for recent sessions

## When to Use

- Starting a new session on an existing project
- Picking up where you left off
- Need to reference prior decisions
- Looking for specs or guidelines
