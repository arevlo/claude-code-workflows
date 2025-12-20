---
description: Load, save, or browse Claude Code plans from multiple sources
argument-hint: [save|latest|search <query>]
allowed-tools: mcp__notion__notion-search,mcp__notion__notion-fetch,mcp__notion__notion-create-pages,Bash,Read,Write,Glob,Grep,AskUserQuestion
---

Manage Claude Code plans - load from multiple sources, save for context preservation, or browse recent plans.

**Argument:** $ARGUMENTS

## Configuration

**Notion database name:** `_clawd` (customize to match your Notion setup)
**Plan tag in Notion:** `Plan` (to distinguish from regular contexts)

## Detect Plans Directory

Claude Code stores plans in the config directory. Check both possible locations (personal config takes priority):

```bash
# Check personal config first, then standard
if [ -d "$HOME/.claude-personal/plans" ] && ls "$HOME/.claude-personal/plans"/*.md >/dev/null 2>&1; then
  echo "$HOME/.claude-personal/plans"
elif [ -d "$HOME/.claude/plans" ] && ls "$HOME/.claude/plans"/*.md >/dev/null 2>&1; then
  echo "$HOME/.claude/plans"
else
  echo "none"
fi
```

Store this path as `$PLANS_DIR` for use in subsequent steps.

## Route by Argument

| Argument | Action |
|----------|--------|
| (empty) | Go to **Interactive List** |
| `save` | Go to **Save Plan** |
| `latest` | Go to **Load Latest** |
| `search <query>` | Go to **Search Plans** |

---

## Interactive List (default, no arguments)

Show recent plans from local Claude plans directory with summaries.

### 1. List recent plans

```bash
# Get 10 most recently modified plans
ls -lt "$PLANS_DIR"/*.md 2>/dev/null | head -10
```

### 2. Extract metadata for each plan

For each plan file found:

```bash
# Get title (first line starting with #)
head -1 "$file" | sed 's/^# //'

# Get summary (look for Goal/Summary/Overview section)
grep -A 2 "^## \(Goal\|Summary\|Overview\)" "$file" | head -3 | tail -2
```

### 3. Display formatted list

```
Recent Plans:

1. [2024-12-18] Portfolio Content Review
   Goal: Document and review portfolio content for applications

2. [2024-12-17] Design Token Pipeline
   Goal: Automate design token sync from Figma to code

3. [2024-12-15] clawd-eyes Plugin Setup
   Goal: Create GitHub repo and integrate plugin

Select a plan to continue (1-10), or 'q' to cancel:
```

### 4. Load selected plan

Use Read tool to display the full plan content, then say:
"I've loaded this plan. Ready to continue where you left off."

---

## Save Plan

Save the current conversation's plan to a chosen destination for context preservation.

### 1. Detect current plan

Check if there's an active plan file mentioned in the conversation:
- Look for plan file paths in recent system messages
- Check both directories for recently modified files (< 1 hour):
  ```bash
  find "$HOME/.claude-personal/plans" "$HOME/.claude/plans" -name "*.md" -mmin -60 2>/dev/null | head -1
  ```

If a plan file is found:
- Read its content
- Extract title and summary

If no plan file found:
- Ask user: "What would you like to save? Describe the plan or paste the content."

### 2. Show destination picker

```
Where would you like to save this plan?

1. Local Claude Plans ($PLANS_DIR)  - Quick, stays in Claude config
2. Notion (_clawd database)         - Persistent, searchable, tagged
3. GitHub Issue                     - Trackable, collaborative

Select destination:
```

Use the `$PLANS_DIR` detected earlier (either `~/.claude-personal/plans` or `~/.claude/plans`).

### 3. Save to selected destination

**If Local Claude Plans:**
- Generate filename: `{slug-from-title}.md` or use existing filename
- Write to `$PLANS_DIR` using Write tool
- Confirm: "Plan saved to $PLANS_DIR/{filename}"

**If Notion:**
- Use `mcp__notion__notion-create-pages` to create a new page in `_clawd` database
- Set properties:
  - Title: Plan title
  - Tags: `Plan`, project name (if detected)
- Set content: Full plan markdown
- Confirm with Notion page URL

**If GitHub Issue:**
- Check if `gh` CLI is installed
- Create issue with:
  ```bash
  gh issue create --title "Plan: {title}" --body "{plan content}" --label "plan"
  ```
- Confirm with issue URL

### 4. Confirmation

Show where the plan was saved with a direct link/path.

---

## Load Latest

Quickly load the most recently modified plan.

### 1. Find latest plan

```bash
# Get the most recently modified plan file
ls -t "$PLANS_DIR"/*.md 2>/dev/null | head -1
```

### 2. Load and display

Use Read tool to display the full plan content.

Say: "Loaded the most recent plan: **{title}**. Ready to continue."

---

## Search Plans

Search for plans across all sources.

**Search query:** Extract query from arguments (everything after "search ")

### 1. Search local plans

```bash
# Search in filenames and content across both directories
grep -l -i "{query}" "$HOME/.claude-personal/plans"/*.md "$HOME/.claude/plans"/*.md 2>/dev/null
```

### 2. Search Notion (if available)

Use `mcp__notion__notion-search` with query in `_clawd` database, filtered to Plan tag.

### 3. Search GitHub Issues (if in a repo)

```bash
gh issue list --search "{query} label:plan" --json number,title,createdAt --limit 10
```

### 4. Display combined results

```
Search results for "{query}":

Local Plans:
  1. [2024-12-18] Design Token Pipeline - ~/.claude-personal/plans/design-tokens.md
  2. [2024-12-17] API Refactor - ~/.claude/plans/api-refactor.md

Notion:
  3. [2024-12-15] API Design Spec - notion.so/...

GitHub Issues:
  4. [2024-12-10] #42: Plan: Authentication Flow

Select a result to load (1-10), or 'q' to cancel:
```

### 5. Load selected result

Fetch and display the full content from the appropriate source.

---

## When to Use

- **`/arevlo-context:plan`** - Start of session, pick up where you left off
- **`/arevlo-context:plan save`** - Before running out of context, preserve your plan
- **`/arevlo-context:plan latest`** - Quick resume of most recent work
- **`/arevlo-context:plan search auth`** - Find a specific plan by topic
