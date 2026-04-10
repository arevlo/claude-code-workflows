---
description: Use when managing MCP servers - toggling on/off, checking status, enabling or disabling MCPs. Triggers on "mcp", "toggle mcp", "disable mcp", "enable mcp", "manage mcps", "mcp status".
allowed-tools: Bash, Read
---

# MCP Server Toggle Manager

Interactive manager for enabling/disabling MCP servers. Saves full configs to `~/.claude/mcps/` so they can be re-enabled without reconfiguring.

## How to run

Execute the toggle script:

```bash
bash ~/.claude/scripts/mcp-toggle.sh
```

This opens an interactive menu (via `gum`) with options:
- **Disable MCPs** - select from currently enabled MCPs to turn off
- **Enable MCPs** - select from previously disabled MCPs to restore
- **Show status** - see all MCPs and their current state

## How it works

- On every run, it snapshots all current user-scoped MCP configs from `~/.claude.json` into `~/.claude/mcps/{name}.json`
- Disabling uses `claude mcp remove -s user` (the config is preserved in the backup)
- Enabling uses `claude mcp add-json -s user` to restore from the saved config
- Changes require restarting Claude Code to take effect

## Config storage

- Backup configs: `~/.claude/mcps/`
- Each file is `{server-name}.json` containing the full MCP server config object
- These files persist across sessions so you never lose a config

## Prerequisites

- [`gum`](https://github.com/charmbracelet/gum) installed
- [`jq`](https://stedolan.github.io/jq/) installed

## Setup

Create the toggle script at `~/.claude/scripts/mcp-toggle.sh`. The script should:

1. Read all MCP server entries from `~/.claude.json` (the `mcpServers` object)
2. Back up each config to `~/.claude/mcps/{name}.json`
3. Present an interactive menu using `gum choose`
4. On disable: run `claude mcp remove -s user <name>`
5. On enable: run `claude mcp add-json -s user '<json>'` from the backup file

## Notes

- Only manages **user-scoped** MCPs (from `~/.claude.json`)
- Does not touch plugin MCPs, project MCPs, or remote MCPs
- Requires `gum` and `jq` to be installed
