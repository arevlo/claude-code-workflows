---
description: Search and load prior session contexts from multiple sources
argument-hint: <search query>
allowed-tools: mcp__plugin_Notion_notion__notion-search,mcp__plugin_Notion_notion__notion-fetch,Bash,Read,Glob,Grep,AskUserQuestion
---

Search for and display prior session contexts from multiple sources.

Search query: $ARGUMENTS

## Configuration

**Notion database name:** `_context` (customize to match your Notion setup)

## Steps:

### 1. Check available sources
Run these checks silently to determine which options to show:
- **Session Transcripts:** Check for `sessions-index.json` in project folder (see detection below)
- **Swarm Progress:** Check if `.claude/swarm/progress/` directory exists
- **Claude Plans:** Check if `~/.claude/plans/` or `~/.claude-personal/plans/` directory exists
- **Notion:** Always available (requires Notion MCP)
- **GitHub Issues:** Check if in a git repo with remote: `git remote get-url origin`
- **Docs folder:** Check if `docs/context/` directory exists using Glob
- **Local /tmp:** Check if `/tmp/claude-contexts/` directory exists

**Detecting Session Transcripts directory:**
```bash
# Convert current working directory to Claude's project path format
PROJECT_PATH=$(pwd | sed 's|/|-|g' | sed 's|^-||')
# Check both personal and work locations
TRANSCRIPTS_DIR=""
if [ -f ~/.claude-personal/projects/${PROJECT_PATH}/sessions-index.json ]; then
  TRANSCRIPTS_DIR=~/.claude-personal/projects/${PROJECT_PATH}
elif [ -f ~/.claude/projects/${PROJECT_PATH}/sessions-index.json ]; then
  TRANSCRIPTS_DIR=~/.claude/projects/${PROJECT_PATH}
fi
```

### 2. Show source picker
ALWAYS ask the user where to search - present available options:

```
Where would you like to search for context?

1. Session Transcripts (prior sessions) [only if sessions-index.json exists]
2. Swarm checkpoints (.claude/swarm/)   [only if .claude/swarm/progress exists]
3. Claude Plans (~/.claude/plans/)      [only if plans directory exists]
4. Notion (_context database)
5. GitHub Issues (in current repo)      [only if git remote exists]
6. Docs folder (./docs/context/)        [only if docs/context exists]
7. Local /tmp folder                    [only if /tmp/claude-contexts exists]

Select source:
```

### 3. Search selected source

**If Session Transcripts:**
- Read `sessions-index.json` from the detected transcripts directory
- Parse JSON and extract session entries
- For each session, display:
  - **Summary** (AI-generated)
  - **Date** (created/modified)
  - **Branch** (gitBranch)
  - **Messages** (messageCount)
  - **First prompt** (truncated)
- If query provided, filter by summary or firstPrompt containing the query
- Sort by modified date (newest first)
- Display in format:
  ```
  Session Transcripts:
    1. [Jan 24, 08:12] Optimize Chrome integration
       Branch: user.feat-chrome-ext  |  34 messages

    2. [Jan 23, 22:26] Plugin marketplace setup
       Branch: main  |  28 messages

    3. [Jan 23, 11:47] Context awareness implementation
       Branch: user.context-awareness  |  45 messages
  ```
- When user selects a session:
  - Read the corresponding `.jsonl` file
  - Parse JSONL (each line is a JSON object)
  - Extract messages with `type: "human"` or `type: "assistant"`
  - Display conversation in readable format
  - Note: JSONL files can be large - consider showing last N messages or summarizing

**If Local /tmp:**
- List files using Glob: `/tmp/claude-contexts/*.md`
- If query provided, filter filenames containing the query
- If no query, show all files (sorted by name = date)
- Display list with filenames (which contain date and project)

**If Swarm Progress:**
- Search multiple swarm directories:
  - `.claude/swarm/progress/*.md` - Auto checkpoints and agent progress
  - `.claude/swarm/research/*.md` - Research phase outputs
  - `.claude/swarm/plans/*.md` - Implementation plans
  - `.claude/swarm/context/*.md` - Consolidated context files
- Sort by modification date (newest first)
- If query provided, use Grep to filter by content
- Display with category labels:
  ```
  Swarm Checkpoints:
    1. [Progress] auto-2024-12-19-phase2.md (1h ago)
       Goal: Add user authentication
    2. [Research] 2024-12-19-auth-research.md (2h ago)
       Topic: Authentication patterns
    3. [Plan] 2024-12-19-auth-plan.md (2h ago)
       Phases: 4
  ```
- Extract metadata from files:
  - Goal/Topic from first `#` heading
  - Phase from `Phase:` line (for progress files)
  - Number of phases from `### Phase` headings (for plans)

**If Notion:**
- Search `_context` database with the query
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

**If Claude Plans:**
- Detect plans directory (check both): `~/.claude-personal/plans/` or `~/.claude/plans/`
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

**Session Transcripts:**
- Read the `.jsonl` file for the selected session
- Parse each line as JSON
- Filter for message types: `human`, `assistant`
- For large transcripts (>100 messages), ask user:
  - Show last N messages
  - Show full transcript
  - Show summary only (from index)
- Display conversation in readable format:
  ```
  [Human] First message...
  [Assistant] Response...
  ```

**Local files (/tmp, docs, swarm, plans):**
- Use Read tool to display the full markdown content

**Notion:**
- Use `mcp__plugin_Notion_notion__notion-fetch` to retrieve and display page content

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
