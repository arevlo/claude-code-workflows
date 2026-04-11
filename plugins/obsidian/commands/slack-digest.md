---
skill: obsidian:slack:digest
type: local
title: Slack Digest to Obsidian
description: Read Slack mentions, DMs, and key channels via MCP, categorize, and save a dated markdown digest to Obsidian vault
tags: [obsidian, slack, digest, automation]
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, AskUserQuestion
---

Read Slack messages via MCP tools, categorize them into bucketed summaries, and save as a dated markdown file in the Obsidian vault. Messages are NOT marked as read.

## Configuration

Configuration is stored in `~/.claude/obsidian-plugin.json`. The `digest_output_path` field is used for the output directory and a `slack` key holds Slack-specific settings.

**Output filename:** `slack-digest-YYYY-MM-DD.md` (appends counter if file exists: `slack-digest-2026-02-07-2.md`)

## Steps

### 0. Load Configuration

Before doing anything else, read the configuration file:

1. Use the `Read` tool to read `~/.claude/obsidian-plugin.json`
2. **If the file does not exist:**
   - Inform the user: "No Obsidian plugin configuration found. Please run `/Obsidian:configure` first."
   - Stop execution.
3. **If the file exists but has no `slack` key:** Run interactive setup (Step 0a below).
4. **If the `slack` key exists:** Extract config values and continue to Step 1.

### 0a. Interactive Slack Setup

Run this once to populate the `slack` config key:

1. **Discover user identity:**
   - Use `ToolSearch` to load Slack MCP tools: search for `+slack read profile`
   - Call `slack_read_user_profile` with no arguments to get the authenticated user's profile
   - Extract `user_id` and `team_id` from the response
   - Construct `workspace_url`: `https://app.slack.com/client/{team_id}`

2. **Discover workspace name:**
   - Extract workspace/team name from the profile response
   - Store as `workspace_name`

3. **Select key channels:**
   - Use `AskUserQuestion` to ask: "Which Slack channels should I monitor? Enter channel names (comma-separated) or say 'skip' to only track mentions and DMs."
   - For each channel name provided, use `slack_search_channels` to find the channel ID
   - Present matches for confirmation if ambiguous
   - Build the `key_channels` array with `{ "id": "CXXXXXXXX", "name": "channel-name" }` entries

4. **Write config:**
   - Read the current `~/.claude/obsidian-plugin.json`
   - Add the `slack` key:
     ```json
     "slack": {
       "workspace_name": "{detected name}",
       "workspace_url": "{constructed URL}",
       "user_id": "{detected ID}",
       "team_id": "{detected ID}",
       "key_channels": [
         { "id": "CXXXXXXXX", "name": "channel-name" }
       ],
       "time_window_hours": 24,
       "max_thread_depth": 10,
       "user_cache": {}
     }
     ```
   - Use `Write` to save the updated config
   - Continue to Step 1

### 1. Fetch Personal Messages

Search for messages directed at the authenticated user within the time window:

1. Calculate the `after` date: today minus `time_window_hours` (default 24h), format as `YYYY-MM-DD`
2. Use `ToolSearch` to load Slack MCP tools if not already loaded: search for `+slack search`
3. Call `slack_search_public_and_private` with query `to:me after:{YYYY-MM-DD}`
4. Paginate up to 5 pages (100 messages max)
5. Store all results with: `channel_id`, `message_ts`, `user_id`, `text`, `thread_ts`, `permalink`

### 2. Fetch Key Channel Messages

For each channel in `key_channels`:

1. Calculate `oldest` timestamp: current Unix time minus `time_window_hours * 3600`
2. Call `slack_read_channel` with the channel ID and `oldest` parameter
3. **Deduplicate:** Skip any message where `channel_id + message_ts` already exists from Step 1
4. Add new messages to the collection

### 3. Enrich Threads

For messages that have thread replies (`thread_ts` exists and `reply_count > 0`):

1. Call `slack_read_thread` with `channel_id` and `thread_ts`
2. Cap at `max_thread_depth` replies (default 10)
3. Store thread replies alongside the parent message

### 4. Resolve User IDs

1. Collect all unique `user_id` values from messages and thread replies
2. Check `user_cache` in config for previously resolved names
3. For each uncached user ID, call `slack_read_user_profile` with that user ID
4. Extract `display_name` or `real_name` (prefer display_name, fall back to real_name)
5. Update `user_cache` in `~/.claude/obsidian-plugin.json` with new mappings:
   ```json
   "user_cache": {
     "U12345": "Alice Smith",
     "U67890": "Bob Jones"
   }
   ```
6. Save the updated config file

### 5. Categorize

Assign each message to exactly **one** category, evaluated in this priority order:

| Priority | Category | Criteria |
|----------|----------|----------|
| 1 | **Action Required** | Direct questions to you, contains "can you", "please", "review", "approve", urgent/blocking language, DMs with clear requests or asks |
| 2 | **Mentions** | Contains your @-mention but is not action-oriented (FYI mentions, cc'd, thanks) |
| 3 | **Direct Messages** | From DM or MPIM channels (channel ID starts with `D` or `G`) not already categorized above |
| 4 | **Active Threads** | Thread replies in channels where you participated earlier in the thread |
| 5 | **Channel Highlights** | Notable messages from key channels that don't mention you -- important announcements, decisions, blockers |
| 6 | **Bot & Automated** | Bot users, integration messages (Jira, GitHub, Sentry, deploy bots, etc.) |

**Rules:**
- Each message appears in exactly one category
- Evaluate categories top-to-bottom; first match wins
- Skip trivial messages (emoji-only reactions, "thanks", single-word acks) unless they're DMs

### 6. Generate Markdown

Build the digest with this structure:

```markdown
---
date: YYYY-MM-DD
type: slack-digest
messages_processed: {count}
channels_scanned: {count}
time_window: {N}h
---

# Slack Digest -- {Mon DD, YYYY}

> {count} messages across {channels} channels (last {N} hours).

## Action Required ({count})

### {Summary} -- {Sender} in #{channel}
{1-3 sentence takeaway. Include what action is needed.}
**[View in Slack ->]({permalink})**

> **Thread ({N} replies):** {Brief thread summary if thread exists}

## Mentions ({count})

### {Summary} -- {Sender} in #{channel}
{1-3 sentence takeaway.}
**[View in Slack ->]({permalink})**

## Direct Messages ({count})

### {Summary} -- {Sender}
{1-3 sentence takeaway.}
**[View in Slack ->]({permalink})**

## Active Threads ({count})

### {Summary} -- #{channel}
{1-3 sentence takeaway of thread progression.}
**[View in Slack ->]({permalink})**

## Channel Highlights ({count})

### {Summary} -- {Sender} in #{channel}
{1-3 sentence takeaway.}
**[View in Slack ->]({permalink})**

## Bot & Automated ({count})

### {Summary} -- {Bot/Service} in #{channel}
{1 sentence takeaway.}
**[View in Slack ->]({permalink})**
```

**Formatting rules:**
- Skip empty sections entirely -- do not render categories with 0 messages
- Use 1-3 sentence summaries, not full message text
- Use resolved display names from `user_cache`, never raw user IDs
- **Permalinks:** Construct as `https://app.slack.com/archives/{channel_id}/p{ts_no_dot}` where `ts_no_dot` is the message timestamp with the `.` removed (e.g., `1234567890.123456` -> `p1234567890123456`)
  - Prefer Slack-provided permalinks if available in the API response
- Thread context goes in blockquotes below the main summary
- Format dates in the header as "Feb 7, 2026" style
- Order sections by the priority table above (Action Required first -> Bot & Automated last)

### 7. Save the File

Use the `obsidian` CLI to create the digest file in the vault:

```bash
DATE=$(date +%Y-%m-%d)
# Try creating the file -- if it already exists, increment counter
obsidian create path="daily-mail/slack-digest-${DATE}.md" content="..." 2>&1
# If error contains "already exists", try with -2 suffix
obsidian create path="daily-mail/slack-digest-${DATE}-2.md" content="..."
# Continue incrementing if needed
```

The CLI auto-creates intermediate folders so no `mkdir -p` is needed.

**Note:** Config loading (Step 0) still uses `Read` tool for `~/.claude/obsidian-plugin.json` since that config file is outside the vault. User cache writes still use `Write` tool for the same reason.

### 8. Confirm to User

**If no messages were found** (nothing in time window), inform the user:

```
No Slack messages found in the last {N} hours. Nothing to digest!
```

**If messages were processed**, show a summary:

```
Slack Digest Complete

  Messages processed: {total_count}
  Channels scanned: {channel_count}
  Time window: {N}h
  Categories:
    - Action Required: {n}
    - Mentions: {n}
    - Direct Messages: {n}
    - Active Threads: {n}
    - Channel Highlights: {n}
    - Bot & Automated: {n}

  Saved to: {file_path}
  Note: Messages are NOT marked as read.
```

## Tools Needed

Load via `ToolSearch` before use:
- `slack_search_public_and_private` -- Search messages across public and private channels
- `slack_read_channel` -- Read messages from a specific channel
- `slack_read_thread` -- Read thread replies
- `slack_read_user_profile` -- Resolve user IDs to display names
- `slack_search_channels` -- Find channels by name (setup only)

Direct tools (no ToolSearch needed):
- `Read` -- Read config files
- `Write` -- Save config and digest files
- `Bash` -- File existence checks, date calculations
- `Glob` -- Find existing digest files
- `AskUserQuestion` -- Interactive setup prompts

## Notes

- **No side effects:** Reading via MCP does NOT mark messages as read.
- **User cache:** Grows over runs to avoid redundant profile lookups. Cache is persisted in config.
- **Rate limiting:** Slack MCP may rate-limit. If you hit errors, wait briefly and retry once.
- **Long messages:** Summarize to 1-3 sentences. Don't include full message bodies.
- **Code blocks/snippets:** Note that code was shared but don't reproduce it in the digest.
- **Multiple runs per day:** The filename counter logic handles this gracefully.
- **Time window:** Default 24h, configurable via `time_window_hours` in config.
