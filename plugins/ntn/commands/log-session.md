---
description: Use when the user wants to write a structured summary of the current Claude Code session to a Notion "Claude Log"-style database. Triggers on "log this session", "log to claude log", "/log-session", "document this session in notion", "/ntn:log-session", "save a session log", or any variant of capturing what was done this session into a Notion log database. Should NOT trigger on generic "save notes", "log this to obsidian", or single-message summarization requests — this skill specifically writes to a configured Notion database with a date-prefixed title and structured body sections.
allowed-tools: Bash, Read, Write, AskUserQuestion, mcp__claude_ai_Notion__notion-fetch, mcp__claude_ai_Notion__notion-create-pages
---

# Log Session to Notion

Summarize the current Claude Code session and create a structured page in a
configured Notion database. The output looks like a tidy engineering log entry:
date-prefixed title, sections that adapt to what actually happened
(implementation work, tests, risks, branch state), and Notion-flavored
markdown in the body.

## Why each step exists

- **Per-project config, not global.** Different projects log to different
  databases (one Notion workspace per hackathon/team). A single global config
  would force every project through one DB.
- **Resolve the data source ID once.** Notion v6 needs a `data_source_id`,
  not a database ID, for `notion-create-pages`. Caching it after the first
  successful resolve makes subsequent runs one-shot.
- **Adaptive body sections.** Sessions vary — some are pure investigation,
  some ship code, some update Notion. Forcing the same 8 headings every time
  produces empty "Tests: n/a" filler. Build the body from what actually
  happened.
- **Show the draft before writing.** Notion pages are easy to create and
  annoying to clean up. A one-screen preview catches wrong titles, missing
  context, or "I didn't actually finish that" overclaiming before it lands.

## Configuration

Stored at `.claude/ntn-log.json` (relative to the repo root, *not* `~/.claude`
— each repo has its own log DB).

```json
{
  "database_url": "https://www.notion.so/<workspace>/<db-id>?v=<view-id>",
  "data_source_id": "<resolved-data-source-id>",
  "title_property": "Name"
}
```

If the file is missing or any required key is absent, run Step 1a. Otherwise
skip to Step 2.

## Steps

### 1. Resolve target database

Read `.claude/ntn-log.json` with `Read`.

- File missing or `database_url`/`data_source_id` missing → **1a**.
- All present → continue to Step 2.

#### 1a. First-run setup

Use `AskUserQuestion` once:

- Question: `Paste the Notion database URL for this project's session log.`

Then call `mcp__claude_ai_Notion__notion-fetch` with the URL. Expect a
`<database>` response that lists one or more data sources. If exactly one
data source is present, use its ID. If multiple, show their names and ask the
user to pick. Extract the `data_source_id` (the UUID part of
`collection://<uuid>`).

Optionally ask:

- Question: `What is the title property of this database? (default: Name)`
  — only if you want to support non-default schemas. For most workspaces,
  default to `Name` without asking.

Write `.claude/ntn-log.json` (create `.claude/` if missing). Use `Write`. The
parent directory may not exist; create it first with `mkdir -p .claude`.

### 2. Gather session context

The body sections are built from what actually happened in this session. Use
the conversation context plus quick `Bash` probes:

- **Recent commits on the current branch** — `git log --oneline <main>..HEAD`
  where `<main>` comes from `git symbolic-ref refs/remotes/origin/HEAD` or
  defaults to `main`. Use the original branch's commits, not commits from
  before this session.
- **Files changed in this session** — your conversation history is
  authoritative here (you know what you Edited/Wrote). `git status -s` and
  `git diff --stat <main>..HEAD` are useful cross-checks.
- **External writes** — Notion pages updated, GitHub PRs opened, deploys
  triggered, etc. These come from your tool-call history, not git.

Don't run heavy probes (`find`, full-repo greps). The conversation already
knows the shape of the work; git is the disambiguator.

### 3. Build the title

Format: `YYYY-MM-DD — <short topic>`

- Date: today, from the environment (`Today's date is YYYY-MM-DD` in the
  system prompt) or `date +%Y-%m-%d`.
- Topic: 4–12 words capturing the headline change. Past tense, concrete.
  Good: `Agent 2 (Notion Tools): six tools shipped on agent/tools`. Bad:
  `worked on stuff`, `Ring War updates`.

If the session has a clear scope (a branch name, a ticket, an agent role,
a feature flag), put it in the topic.

### 4. Build the body

Use **Notion-flavored markdown**. Pick from these sections — include a
section only if it has real content. Order them roughly as listed.

- `## What I did` — bullet list, past tense, one bullet per discrete change.
  Always include this section. Mention files/paths in backticks. Don't dump
  full diffs.
- `## Tests` — only if tests were added/run/changed. Note the count, runner,
  and timing if known (e.g. "14 Vitest tests, ~290ms, under 5s budget").
- `## Side-effect specs / firm contracts` — only when the session produced
  an API/interface that other agents or future-you will rely on. List the
  contracts compactly (one line each).
- `## Workarounds` — only when a blocker forced a non-standard approach.
  State the blocker, the workaround, and the planned cleanup.
- `## Risks / things to know` — only when there are non-obvious failure
  modes or assumptions a reader could trip on. Skip if everything is
  textbook.
- `## Notion updates` — only when this session edited Notion (pages
  created/updated, Index DB rows touched, etc.).
- `## Process notes` — only when the *way* the work happened is itself
  noteworthy (a hook fired, a goal was set, an unusual coordination pattern
  was used). Skip routine sessions.
- `## Branch state` — only when commits were made. Show a compact `git log`
  excerpt of the new commits, fenced as a code block.

If a section has no content, **omit it entirely** — don't write "n/a" or
"none."

### 5. Preview and confirm

Show the user the proposed title and body in the chat (don't fence the whole
body; just preview it as you'd render it in Notion). Then ask one
`AskUserQuestion`:

- Question: `Log this session entry to the Claude Log database?`
- Options:
  - `Yes, log it` — proceed to Step 6.
  - `Edit before logging` — ask what to change, revise, re-preview, re-ask.
  - `Cancel` — stop.

Skip the confirmation step if the user's invocation already implies "just do
it" (e.g. they said `/ntn:log-session --no-confirm` or "just log it, don't
ask"). Use judgment — when in doubt, confirm.

### 6. Write to Notion

Call `mcp__claude_ai_Notion__notion-create-pages` with:

```json
{
  "parent": {
    "type": "data_source_id",
    "data_source_id": "<from-config>"
  },
  "pages": [{
    "properties": { "<title_property>": "<title>" },
    "icon": "📓",
    "content": "<the markdown body>"
  }]
}
```

The icon is optional — `📓` is a sensible default for a log entry. Pick a
different emoji if the session had a distinctive shape (e.g. `🛠️` for
implementation work, `🐛` for a bug fix, `📋` for planning).

### 7. Confirm to the user

Tell the user the page URL and the title. Short — one or two lines.

```
Logged: [<title>](<page-url>)
```

## Body composition examples

**Example 1 — implementation session, multiple commits:**

```markdown
## What I did

- Implemented six Notion-API tools on branch `agent/tools` (the Ring War
  worktree at `ring-war-tools`).
- Three Order tools (`vault_ring`, `audit_public`, `unmake_ring`) and three
  Shadow tools.
- One file per tool plus a barrel `src/tools/index.ts`.

## Tests

- 14 Vitest tests across 6 files, all passing in ~290ms (budget was 5s).
- `npm run check` clean.

## Workarounds

- Blocked on Agent 1's `src/types.ts`. Wrote `src/tools/_types.ts` as a
  local shim; swap imports when Agent 1 lands the real file on `main`.

## Branch state

```
agent/tools  ccce051  tools: barrel re-exporting all six
             0979dad  tool: leak_whisper + test
             ...
```
```

**Example 2 — investigation-only session, no code:**

```markdown
## What I did

- Audited `src/billing/` for the duplicate-charge bug. Root cause is in
  `applyCoupon()` at `src/billing/coupon.ts:142` — it adds the discount
  twice when the order has both a percentage coupon and free shipping.
- No fix yet; ticket filed.

## Risks / things to know

- Only triggers when shipping zone is non-US. Domestic orders are fine.
- The fix is non-trivial because the coupon stack ordering is
  load-bearing for the tax engine.
```

Notice how the second example omits Tests, Side-effect specs, Workarounds,
Notion updates, Process notes, and Branch state — the session didn't have
those.

## What to avoid

- **Don't paraphrase the user's actual commit messages.** Quote them in the
  Branch state section verbatim.
- **Don't fabricate test counts or timings.** If you didn't run tests this
  session, omit the Tests section. Same for `npm run check` and similar.
- **Don't repeat the conversation transcript.** This is a log entry, not a
  replay. One bullet per outcome, not one per tool call.
- **Don't include the entire body if the user just wanted a preview.**
  Render the preview inline, then only write on confirmation.
- **Don't store the database URL in memory or CLAUDE.md.** It belongs in
  `.claude/ntn-log.json`. Memory is for things that span sessions; this is a
  project-config fact that lives with the repo.

## When this skill does NOT apply

- "Save notes to obsidian" / "add this to my vault" → use `obsidian:` family.
- "Log this conversation to a file" / "export the transcript" → use
  `/export`, not this skill.
- "Update the Ring War Index DB row for X" → use `mcp__claude_ai_Notion__`
  tools directly with the specific page ID; this skill writes new pages,
  not property edits to existing ones.
- A session that did nothing of substance (single Q&A, no file changes, no
  external writes) — tell the user there's nothing worth logging and ask if
  they want to log it anyway.
