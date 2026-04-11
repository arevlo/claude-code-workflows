---
skill: obsidian:task:create
type: local
title: Create Obsidian Task
description: Use when creating a new task file in the Obsidian vault with TaskBase-compatible frontmatter
allowed-tools: Bash, Read, Write, AskUserQuestion
---

# Create Obsidian Task

Create a task markdown file in the Obsidian vault using the same frontmatter schema that TaskBase uses, so it can be pulled into TaskBase later.

## Steps

1. Read vault path from `~/.claude/obsidian-plugin.json` (key: `vault_path`)

2. **Prompt for structured options** -- use a single `AskUserQuestion` with selectable options:
   - **project**: known projects from the vault's `tasks/` subdirectories, plus "Other (I'll type it)" and "None"
   - **priority**: low | medium | high | critical (default: medium)
   - **status**: pending | in_progress | under_review | completed (default: pending)
   - **due date**: today | tomorrow | next week | custom | none

3. **Check for screenshots in conversation** -- before asking for title/body, check if the user has already provided screenshot(s) (pasted inline images) earlier in the conversation or alongside the skill invocation.

   **If screenshots are present:**
   - Analyze the image content to extract all visible task-relevant information (title, description, assignee, status, points, notes, etc.)
   - Use the extracted info to pre-fill title and body -- skip asking the user to type them
   - Present the inferred title and body to the user for confirmation via `AskUserQuestion`:
     - "Use inferred title: {extracted title}"
     - "I'll type my own"
   - If the user confirms, proceed with the inferred values
   - If the user wants to type their own, fall through to the manual flow below

   **If no screenshots are present**, proceed with manual entry:

4. **Ask for title** -- output "What's the title?" as text and wait for the user's free-text response (do NOT use AskUserQuestion -- just ask and let them reply).

5. **Ask for body** -- use `AskUserQuestion` with options:
   - "None (skip)"
   - "I'll type it"
   If the user selects "I'll type it", use their typed text as the body.

   **Screenshot file attachments:** If the user provides a screenshot file path (not inline) as part of the body or in a follow-up message:
   - Copy the image to `{vault_path}/attachments/` (create the directory if needed)
   - Name the file `{title-slug}-{timestamp}.{ext}` to avoid collisions
   - Embed it in the body using standard markdown: `![screenshot](attachments/{filename})`
   - Multiple screenshots are supported -- each gets its own embed line in the body

6. **Link enrichment** -- after collecting the body, before writing the file. Scan for supported URLs and replace them with fetched content:

   **GitHub comment/review URLs:**
   - Detect URLs matching these patterns:
     - `https://github.com/{owner}/{repo}/pull/{pr}#discussion_r{id}` -- PR review comment
     - `https://github.com/{owner}/{repo}/pull/{pr}#issuecomment-{id}` -- PR/issue comment
     - `https://github.com/{owner}/{repo}/issues/{issue}#issuecomment-{id}` -- issue comment
   - Fetch via `gh` CLI (already available via Bash):
     - `discussion_r{id}` -> `gh api repos/{owner}/{repo}/pulls/comments/{id}`
     - `issuecomment-{id}` -> `gh api repos/{owner}/{repo}/issues/comments/{id}`
   - Extract `.body`, `.user.login`, `.path` (if present), `.created_at`
   - Replace the URL in the body with the comment content formatted as markdown:
     ```
     **{user}** commented on `{path}` ({date}):

     {body}
     ```
   - Keep the original link as a reference: `> Source: [GitHub comment]({url})`
   - If the comment body contains GitHub image HTML (`<img ... src="..." />`), convert to markdown image syntax

   **Slack URLs:**
   - Detect Slack URLs matching: `https://.*\.slack\.com/archives/(C[A-Z0-9]+)/p(\d+)`
   - If found, extract channel ID and message timestamp from the URL:
     - Channel ID = the `C...` segment after `/archives/`
     - Timestamp = the `p` number, converted to Slack format: insert a `.` before the last 6 digits (e.g., `p1772666267188819` -> `1772666267.188819`)
   - Use Slack MCP `slack_read_thread` with the channel and timestamp to fetch the message
   - Replace the Slack URL in the body with the actual message content (formatted as markdown)
   - Keep the original link as a reference at the bottom: `> Source: [Slack thread](original_url)`

7. Generate a UUID for the task id (use `uuidgen` via Bash)

8. Slugify project and title for the file path:
   - lowercase, replace non-alphanumeric with hyphens, collapse multiple hyphens, trim hyphens, max 80 chars
   - Path: `{vault_path}/tasks/{project-slug}/{title-slug}.md`
   - If no project, use `uncategorized` as the folder

9. Write the markdown file with this exact frontmatter format:

```markdown
---
id: {uuid}
title: "{title (escape double quotes)}"
status: {status}
priority: {priority}
project: {project or empty}
due: {due_date or empty}
created: {ISO timestamp}
updated: {ISO timestamp}
source: taskbase
---

# {title}

{body}
```

10. Create parent directories if needed (`mkdir -p`)
11. Confirm the file was created and show the path
