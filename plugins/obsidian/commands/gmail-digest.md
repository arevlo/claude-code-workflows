---
skill: obsidian:gmail:digest
type: local
title: Gmail Digest to Obsidian
description: Analyze unread Gmail emails and create a bucketed digest in Obsidian vault
tags: [obsidian, gmail, digest, automation]
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, mcp__claude_ai_Gmail__gmail_search_messages, mcp__claude_ai_Gmail__gmail_read_message, mcp__claude_ai_Gmail__gmail_read_thread
---

Use the Gmail MCP to fetch all unread emails, categorize them into bucketed summaries, and save as a dated markdown file in the Obsidian vault.

## Configuration

Configuration is stored in `~/.claude/obsidian-plugin.json`. The `digest_output_path` field is used for the output directory.

**Output filename:** `gmail-digest-YYYY-MM-DD.md` (appends counter if file exists: `gmail-digest-2026-02-07-2.md`)

## Steps

### 0. Load Configuration

Before doing anything else, read the configuration file:

1. Use the `Read` tool to read `~/.claude/obsidian-plugin.json`
2. **If the file does not exist:**
   - Inform the user: "No Obsidian plugin configuration found. Let's set it up."
   - Use `AskUserQuestion` to ask for their Obsidian vault path (absolute path, no `~`)
   - Use `AskUserQuestion` to ask for their digest output directory (absolute path, no `~`)
   - Use `Bash` to create the config file:
     ```bash
     mkdir -p ~/.claude && cat > ~/.claude/obsidian-plugin.json << 'ENDCONFIG'
     {
       "vault_path": "{user's vault path}",
       "digest_output_path": "{user's digest path}"
     }
     ENDCONFIG
     ```
   - Continue with the values provided
3. **If the file exists:** Parse the JSON and extract `digest_output_path` for use in subsequent steps
4. **Parse filtered sources (optional):** If `filtered_sources` exists in config, extract:
   - `figma_comments.enabled` (boolean)
   - `figma_comments.sender_patterns` (array of strings)
   - `figma_comments.section_title` (string)

### 1. Fetch Unread Emails

Use `mcp__claude_ai_Gmail__gmail_search_messages` with query `is:unread` and `maxResults: 100` to get all unread emails.

If there are **no unread emails**, skip to Step 5 and inform the user:
```
No unread emails found. Nothing to digest!
```

**Pagination:** If the response includes a `nextPageToken`, call again with that token to fetch additional pages. Continue until all unread emails are collected.

### 2. Read Each Email

For each unread email returned in Step 1:

1. **Read the full message** using `mcp__claude_ai_Gmail__gmail_read_message` with the email's `messageId`.
2. **Extract key data** from the response:
   - Sender (name and email address)
   - Subject line
   - Date/time received
   - Full body content (or meaningful summary for very long emails)
   - Thread ID (to identify conversations)
   - Whether it has attachments
   - Any action items or requests mentioned

3. **Extract action links** from the email body. The MCP returns the email content directly, so scan for URLs:

   **URL patterns by email type:**
   - **Google Docs/Sheets** (`*@docs.google.com`, `comments-noreply@docs.google.com`):
     - URLs containing `/document/d/`, `/spreadsheets/d/`, or `/presentation/d/`
     - Comment-specific URLs with `?disco=` or `#comment-id` parameters
   - **Figma** (`via Figma`, `*@figma.com`):
     - URLs matching `figma.com/file/` or `figma.com/design/`
     - Include any `?node-id=` parameters
   - **Calendar invites** (`calendar-notification@google.com`):
     - Google Calendar URLs with `/event?eid=`
   - **GitHub** (`notifications@github.com`):
     - github.com URLs for PRs, issues, or comments
   - **Jira** (`*@atlassian.net`):
     - Jira URLs with `/browse/` or `/issues/`

   **Link selection rules:**
   - Choose the most specific/actionable link (comment link > document link)
   - Prefer links in the main email body over footer links
   - Skip unsubscribe, privacy policy, and footer links
   - Handle Gmail tracking redirects: if URL contains `google.com/url?q=`, extract the `q=` parameter
   - Clean up HTML entities (`&amp;` -> `&`) and decode URL encoding
   - Set to `null` if no valid action link is found

4. **For threads with multiple messages**, optionally use `mcp__claude_ai_Gmail__gmail_read_thread` with the `threadId` to get full conversation context.

**Important:** Keep a running list of all email data collected for categorization.

### 3. Analyze & Categorize

#### Step 3a: Filter Special Sources (if configured)

If `filtered_sources.figma_comments.enabled` is true:

1. Iterate through all collected emails
2. For each email, check if the sender email or display name contains ANY of the patterns in `sender_patterns`:
   - Check if sender email contains "@figma.com" (case-insensitive)
   - Check if sender display name contains "via Figma" (case-insensitive)
3. If matched:
   - Move email to a separate "Figma Comments" collection
   - Remove from the main email list to prevent duplication
4. Continue with remaining emails for standard categorization

#### Step 3b: Bucket Standard Categories

Bucket every *remaining* email (after filtering) into exactly one of these categories:

- **Action Required** -- Emails needing a response, decision, or task from the user
- **Calendar & Scheduling** -- Meeting invites, schedule changes, RSVPs
- **Conversations** -- Ongoing threads, replies, discussions
- **FYI / Informational** -- Newsletters, announcements, product updates, notifications
- **Automated / System** -- Receipts, shipping confirmations, alerts, service notifications, automated reports

For each email, determine:
- **Category** (one of the above)
- **Key takeaway** (1-2 sentence summary of what matters)
- **Urgency** (if applicable, especially for Action Required items)

### 4. Generate Markdown

Build the digest markdown file with this structure:

```markdown
---
date: YYYY-MM-DD
type: gmail-digest
emails_processed: {total_count}
filtered_emails: {filtered_count}
---

# Gmail Digest -- {Mon DD, YYYY}

> {total_count} unread emails processed.

## Action Required ({count})

### {Subject} -- {Sender Name}
{Key takeaway / summary. Include urgency or deadlines if mentioned.}
**[Take action ->]({action_link})** _(if action link exists)_

...

## Calendar & Scheduling ({count})

### {Subject} -- {Sender Name}
{Key takeaway / summary.}
**[View event ->]({action_link})** _(if action link exists)_

...

## Conversations ({count})

### {Subject} -- {Sender Name}
{Key takeaway / summary. Note thread context if relevant.}
**[View thread ->]({action_link})** _(if action link exists)_

...

## FYI / Informational ({count})

### {Subject} -- {Sender Name}
{Key takeaway / summary.}
**[View ->]({action_link})** _(if action link exists)_

...

## Automated / System ({count})

### {Subject} -- {Sender Name}
{Key takeaway / summary.}
**[View ->]({action_link})** _(if action link exists)_

...

## Figma Comments ({count})

### {Subject} -- {Sender Name}
{Key takeaway / summary of the Figma comment or notification.}
**[View comment ->]({action_link})** _(if action link exists)_

...
```

**Rules:**
- Only include category sections that have emails. Skip empty categories entirely.
- Order categories by importance: Action Required first, Automated/System, then Figma Comments last.
- Only include the Figma Comments section if there are filtered emails.
- Each email entry should be concise -- 1-3 sentences max for the summary.
- Use the sender's display name, not their email address.
- Format dates in the header as "Feb 7, 2026" style.
- Update frontmatter to track `filtered_emails` count separately from standard categories.
- **Action links:** Include clickable links only when they exist. Common link text patterns:
  - Google Docs comments: "View comment", "Reply"
  - Calendar invites: "View event", "RSVP", "Yes/No/Maybe"
  - Slack: "View in Slack", "Reply in thread"
  - GitHub: "View pull request", "View issue"
  - Jira: "View issue", "View in Jira"
  - Figma: "View comment", "Open in Figma"
- If no action link is found in the email, use a fallback:
  - For emails that clearly need action: Add `**Check Gmail:** Search for "[Subject snippet]" to access link`
  - For informational emails: Omit the link line entirely
- Never output broken markdown links like `**[View ->]()**` (empty href)

### 5. Save the File

Use the `obsidian` CLI to create the digest file in the vault:

```bash
DATE=$(date +%Y-%m-%d)
# Try creating the file -- if it already exists, increment counter
obsidian create path="daily-mail/gmail-digest-${DATE}.md" content="..." 2>&1
# If error contains "already exists", try with -2 suffix
obsidian create path="daily-mail/gmail-digest-${DATE}-2.md" content="..."
# Continue incrementing if needed
```

The CLI auto-creates intermediate folders so no `mkdir -p` is needed.

**Note:** Step 0 still uses `Read` tool for `~/.claude/obsidian-plugin.json` since that config file is outside the vault.

### 6. Confirm to User

**If no unread emails were found** (skipped from Step 1), just inform the user:

```
No unread emails found. Nothing to digest!
```

**If emails were processed**, show a summary:

```
Gmail Digest Complete

  Emails processed: {total_count}
  Categories:
    - Action Required: {n}
    - Calendar & Scheduling: {n}
    - Conversations: {n}
    - FYI / Informational: {n}
    - Automated / System: {n}
    - Figma Comments: {n}

  Saved to: {digest_output_path}/gmail-digest-YYYY-MM-DD.md
```

## Notes

- **No Chrome required:** This skill uses the Gmail MCP (`mcp__claude_ai_Gmail__*`) instead of browser automation. Much faster and more reliable.
- **Emails stay unread:** The Gmail MCP reads emails without marking them as read (read-only access). The digest note no longer claims emails were "marked as read."
- **Long emails:** For very long emails (marketing newsletters, legal notices), summarize the key point rather than capturing everything.
- **Attachments:** Note if an email has attachments but don't attempt to download them.
- **Multiple runs per day:** The filename counter logic handles this gracefully.
- **Rate limits:** If fetching many emails, the MCP handles pagination. Process emails in batches if needed.
