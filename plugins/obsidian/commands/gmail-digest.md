---
description: Analyze unread Gmail emails and create a bucketed digest in Obsidian vault
allowed-tools: mcp__claude-in-chrome__tabs_context_mcp,mcp__claude-in-chrome__tabs_create_mcp,mcp__claude-in-chrome__navigate,mcp__claude-in-chrome__read_page,mcp__claude-in-chrome__javascript_tool,mcp__claude-in-chrome__computer,Write,Bash,AskUserQuestion,Read
---

Open Gmail in Chrome, read all unread emails, categorize them into bucketed summaries, save as a dated markdown file in the Obsidian vault, and mark emails as read.

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

### 1. Open Gmail Unread View

Use `mcp__claude-in-chrome__tabs_create_mcp` to create a new tab, then `mcp__claude-in-chrome__navigate` to:

```
https://mail.google.com/mail/u/0/#search/is%3Aunread
```

Wait for the page to load fully.

### 2. Read the Unread Email List

Use `mcp__claude-in-chrome__read_page` to extract the list of unread emails visible on the page. Capture:
- Sender name
- Subject line
- Snippet/preview text
- Approximate time received

If there are **no unread emails**, skip to Step 7 and inform the user:
```
No unread emails found. Nothing to digest!
```

### 3. Deep Read Each Email

For each unread email in the list:

1. **Click into the email** using `mcp__claude-in-chrome__computer` (click on the email row). Opening an email in Gmail **automatically marks it as read**.
2. **Read the full content** using `mcp__claude-in-chrome__read_page` to get the complete email body, sender details, and any attachments info.
3. **Navigate back** to the unread list. Use `mcp__claude-in-chrome__navigate` to go back to `https://mail.google.com/mail/u/0/#search/is%3Aunread` (the list will now show remaining unread emails).
4. **Repeat** until all unread emails have been read.

**Pagination:** If after reading all visible emails the unread list still shows more emails (pagination), continue reading those as well.

**Important:** Keep a running list of all email data collected. For each email, store:
- Sender (name and email)
- Subject
- Date/time
- Full body content (or meaningful summary for very long emails)
- Whether it's part of a thread
- Any action items or requests mentioned

### 4. Analyze & Categorize

Bucket every email into exactly one of these categories:

- **Action Required** — Emails needing a response, decision, or task from the user
- **Calendar & Scheduling** — Meeting invites, schedule changes, RSVPs
- **Conversations** — Ongoing threads, replies, discussions
- **FYI / Informational** — Newsletters, announcements, product updates, notifications
- **Automated / System** — Receipts, shipping confirmations, alerts, service notifications, automated reports

For each email, determine:
- **Category** (one of the above)
- **Key takeaway** (1-2 sentence summary of what matters)
- **Urgency** (if applicable, especially for Action Required items)

### 5. Generate Markdown

Build the digest markdown file with this structure:

```markdown
---
date: YYYY-MM-DD
type: gmail-digest
emails_processed: {count}
---

# Gmail Digest — {Mon DD, YYYY}

> {count} unread emails processed and marked as read.

## Action Required ({count})

### {Subject} — {Sender Name}
{Key takeaway / summary. Include urgency or deadlines if mentioned.}

...

## Calendar & Scheduling ({count})

### {Subject} — {Sender Name}
{Key takeaway / summary.}

...

## Conversations ({count})

### {Subject} — {Sender Name}
{Key takeaway / summary. Note thread context if relevant.}

...

## FYI / Informational ({count})

### {Subject} — {Sender Name}
{Key takeaway / summary.}

...

## Automated / System ({count})

### {Subject} — {Sender Name}
{Key takeaway / summary.}

...
```

**Rules:**
- Only include category sections that have emails. Skip empty categories entirely.
- Order categories by importance: Action Required first, Automated/System last.
- Each email entry should be concise — 1-3 sentences max for the summary.
- Use the sender's display name, not their email address.
- Format dates in the header as "Feb 7, 2026" style.

### 6. Save the File

Determine the filename:

```bash
DATE=$(date +%Y-%m-%d)
OUTPUT_DIR="{digest_output_path from config}"
BASE="${OUTPUT_DIR}/gmail-digest-${DATE}"
FILE="${BASE}.md"

# If file already exists, append a counter
if [ -f "$FILE" ]; then
  COUNTER=2
  while [ -f "${BASE}-${COUNTER}.md" ]; do
    COUNTER=$((COUNTER + 1))
  done
  FILE="${BASE}-${COUNTER}.md"
fi

echo "$FILE"
```

Use the `Write` tool to save the markdown content to the resolved file path.

### 7. Confirm to User

Show a summary:

```
Gmail Digest Complete

  Emails processed: {count}
  Categories:
    - Action Required: {n}
    - Calendar & Scheduling: {n}
    - Conversations: {n}
    - FYI / Informational: {n}
    - Automated / System: {n}

  Saved to: {digest_output_path}/gmail-digest-YYYY-MM-DD.md
  All emails marked as read.
```

## Notes

- **Reading = marking as read:** Opening each email in Gmail's web UI automatically marks it as read. No additional action is needed to mark emails as read.
- **Long emails:** For very long emails (marketing newsletters, legal notices), summarize the key point rather than capturing everything.
- **Attachments:** Note if an email has attachments but don't attempt to download them.
- **Errors:** If Gmail fails to load or Chrome is unresponsive, inform the user and suggest they check their browser/internet connection.
- **Multiple runs per day:** The filename counter logic handles this gracefully.
