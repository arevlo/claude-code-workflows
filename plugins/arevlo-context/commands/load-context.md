---
description: Search and load prior session contexts from multiple sources
argument-hint: <search query>
allowed-tools: mcp__notion__notion-search,mcp__notion__notion-fetch,Bash,Read,Glob,Grep,AskUserQuestion
---

Search for and display prior session contexts from multiple sources.

Search query: $ARGUMENTS

## Configuration

**Notion database name:** `_clawd` (customize to match your Notion setup)

## Steps:

### 1. Check available sources
Run these checks silently to determine which options to show:
- **Local /tmp:** Check if `/tmp/claude-contexts/` directory exists
- **Notion:** Always available (requires Notion MCP)
- **GitHub Issues:** Check if in a git repo with remote: `git remote get-url origin`
- **Docs folder:** Check if `docs/context/` directory exists using Glob
- **Plans folder:** Check if `plans/` directory exists using Glob
- **Claude Plans:** Check if `~/.claude-personal/plans/` OR `~/.claude/plans/` directory exists

### 2. Show source picker
ALWAYS ask the user where to search - present available options:

```
Where would you like to search for context?

1. Local /tmp folder                  [only if /tmp/claude-contexts exists]
2. Notion (_clawd database)
3. GitHub Issues (in current repo)    [only if git remote exists]
4. Docs folder (./docs/context/)      [only if docs/context exists]
5. Plans folder (./plans/)            [only if plans/ exists]
6. Claude Plans (~/.claude/plans/)    [only if ~/.claude{-personal}/plans exists]

Select source:
```

### 3. Search selected source

**If Local /tmp:**
- List files using Glob: `/tmp/claude-contexts/*.md`
- If query provided, filter filenames containing the query
- If no query, show all files (sorted by name = date)
- Display list with filenames (which contain date and project)

**If Notion:**
- Search `_clawd` database with the query
- If no query provided, show recent contexts
- Search in page titles and content

**If GitHub Issues:**
- First check if `gh` CLI is installed by running: `which gh`
- If NOT installed, show this message and stop:
  ```
  GitHub CLI (gh) is not installed. Install it to search GitHub Issues.

  Install with:
    brew install gh          # macOS
    sudo apt install gh      # Ubuntu/Debian
    winget install GitHub.cli  # Windows

  After installing, authenticate with: gh auth login
  ```
- If installed, search issues:
  ```bash
  gh issue list --search "{query}" --json number,title,createdAt --limit 10
  ```
- If no query, list recent issues
- Display issue numbers, titles, and dates

**If Docs folder:**
- List files using Glob: `docs/context/*.md`
- If query provided, use Grep to search file content for matches
- If no query, show all files
- Display filenames with dates (extracted from filename)

**If Plans folder:**
- List files using Glob: `plans/*.md`
- If query provided, use Grep to search file content for matches
- If no query, show all files
- Display filenames (plans are typically named by feature/topic)

**If Claude Plans:**
- Detect plans directory:
  - Check `~/.claude-personal/plans/` first (personal config)
  - Fall back to `~/.claude/plans/` (standard config)
- List files using Bash: `ls -lt {plans_dir}/*.md | head -20` (sorted by modified date)
- For each plan file, extract metadata:
  - **Title:** First line starting with `#` (use `head -1`)
  - **Summary:** Look for `## Goal`, `## Summary`, or `## Overview` section, take first 1-2 lines
  - **Modified date:** From `ls -l` output
- If query provided, use Grep to filter by title/content match
- Display in format:
  ```
  1. [2024-12-18] Portfolio Content Review
     Goal: Document and review portfolio content...

  2. [2024-12-17] Design Token Pipeline
     Goal: Automate design token sync from Figma...
  ```
- Sort by modified date (newest first)

### 4. Display results
Show results with:
- Title/filename
- Date (from filename or metadata)
- Preview (first 2 lines if available)

### 5. Ask user which context to view
If multiple results found, ask user to select which one to view.

### 6. Fetch and display full content

**Local files (/tmp or docs):**
- Use Read tool to display the full markdown content

**Notion:**
- Use `mcp__notion__notion-fetch` to retrieve and display page content

**GitHub Issues:**
- Use: `gh issue view {number} --json body`
- Display the issue body

## Search Strategies

- **By Project**: Search for project name
- **By Topic**: Search for feature or topic
- **By Type**: Search for tag (Context, Summary, Spec, Reference)
- **By Date**: Search for date string or "recent"

## When to Use

- Starting a new session on an existing project
- Picking up where you left off
- Need to reference prior decisions
- Looking for specs or guidelines
