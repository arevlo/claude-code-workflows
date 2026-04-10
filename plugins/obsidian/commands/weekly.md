---
skill: obsidian:weekly
type: local
title: Weekly Review
description: Generate a weekly review from daily notes, tasks, and tags. Use when creating a weekly summary, review, or retrospective.
allowed-tools: Bash, AskUserQuestion
---

# Weekly Review

Synthesize a week's daily notes, tasks, and tags into a structured weekly review document.

## Steps

### 1. Determine Date Range

Default: Monday of the current week through today.

Check `$ARGUMENTS` for:
- `--from=YYYY-MM-DD` -> custom start date
- `--to=YYYY-MM-DD` -> custom end date

Calculate the date range:
```bash
# Default: Monday of current week
if [ -z "$FROM" ]; then
  FROM=$(date -v-monday +%Y-%m-%d)
fi
if [ -z "$TO" ]; then
  TO=$(date +%Y-%m-%d)
fi
```

### 2. Detect Daily Note Pattern

```bash
obsidian daily:path
```

Use the returned path to understand the naming pattern (e.g., `YYYY-MM-DD.md` in a `daily-note/` folder).

### 3. Read Daily Notes

For each date in the range, read the daily note:

```bash
obsidian read path="{daily-note-folder}/{date}.md"
```

Collect all content. Skip dates where no note exists (weekends, missed days).

### 4. Gather Task Snapshot

```bash
obsidian tasks todo total
obsidian tasks done total
```

Get counts for open and completed tasks across the vault.

### 5. Gather Tag Distribution

```bash
obsidian tags counts sort=count
```

Get the top tags used this week for thematic analysis.

### 6. Synthesize Review

From the collected daily notes, extract and organize:

- **Accomplishments** -- What was completed, shipped, or resolved
- **In Progress** -- Work started but not yet finished
- **Blockers** -- Issues flagged, things stuck
- **Next Week** -- Upcoming priorities, planned work

Use the tag distribution to identify themes (e.g., heavy `#dev` week vs `#meetings` week).

### 7. Generate Week Number

```bash
date +%Y-W%V
```

### 8. Save Review

```bash
obsidian create path="reviews/weekly/{YYYY}-W{WW}.md" content="..."
```

Use this template:

```markdown
---
date: YYYY-MM-DD
type: weekly-review
week: YYYY-WWW
range: "{from} -> {to}"
---

# Weekly Review -- {YYYY}-W{WW}

> {from} -> {to} | {N} daily notes reviewed

## Accomplishments

{Bulleted list of completed work, shipped features, resolved issues}

## In Progress

{Bulleted list of ongoing work}

## Blockers

{Bulleted list of blockers, or "None" if clear}

## Task Snapshot

- Open: {todo_count}
- Completed: {done_count}

## Top Tags

{Top 5-10 tags by count}

## Next Week

{Priorities and planned work for the coming week}
```

### 9. Confirm

```
Weekly review saved: reviews/weekly/{YYYY}-W{WW}.md

  Period: {from} -> {to}
  Daily notes: {N} reviewed
  Tasks: {done} done, {todo} open
```
