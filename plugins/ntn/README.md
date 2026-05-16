# ntn

Hackathon-grade Notion Developer Platform helpers — for projects built on the
Notion Workers runtime (`ntn` CLI) or that keep their working log inside a
Notion workspace.

## Installation

```
/plugin install ntn@claude-code-workflows
```

## Commands

| Command | Description |
|---------|-------------|
| `/ntn:log-session` | Summarize the current Claude Code session and create a structured page in a configured Notion database (the "Claude Log"). |

## Configuration

Each project that uses `/ntn:log-session` keeps its config in
`.claude/ntn-log.json` (relative to the repo root). The skill creates this on
first run by asking for the Notion database URL.

```json
{
  "database_url": "https://www.notion.so/<workspace>/<db-id>?v=<view-id>",
  "data_source_id": "<resolved-data-source-id>",
  "title_property": "Name"
}
```

- `data_source_id` is resolved once on first run via the Notion MCP and cached
  — subsequent runs don't pay that cost.
- `title_property` defaults to `Name`. Override if your DB's title column is
  named differently.
