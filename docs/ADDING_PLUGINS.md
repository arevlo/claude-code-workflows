# Adding Plugins

How to add new plugins to this marketplace.

## Directory Structure

```
plugins/
└── your-plugin-name/
    ├── .claude-plugin/
    │   └── plugin.json
    ├── commands/
    │   └── your-command.md
    └── README.md
```

## Plugin Configuration

### plugin.json

```json
{
  "name": "your-plugin-name",
  "description": "Brief description of what this plugin does",
  "version": "1.0.0"
}
```

### Marketplace Registration

Add your plugin path to `.claude-plugin/marketplace.json`:

```json
{
  "plugins": [
    "plugins/existing-plugin",
    "plugins/your-plugin-name"
  ]
}
```

## Command Format

Commands are Markdown files with YAML frontmatter:

```markdown
---
description: Brief description shown in command list
argument-hint: <optional arguments>
allowed-tools: Tool1,Tool2,Tool3
---

# Command Title

[Instructions for Claude Code to follow]

## Steps:

1. First step
2. Second step
3. Third step
```

### Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `description` | Yes | Shown in `/help` and command list |
| `argument-hint` | No | Hint for command arguments |
| `allowed-tools` | No | Comma-separated list of allowed tools |

### Available Tools

Common tools you might allow:

- `Bash` - Run shell commands
- `Read` - Read files
- `Write` - Write files
- `AskUserQuestion` - Ask user for input
- `mcp__notion__*` - Notion MCP tools

## Best Practices

1. **Keep commands focused** - One main action per command
2. **Include configuration section** - Let users customize
3. **Add clear steps** - Number your instructions
4. **Write a README** - Document usage and requirements
5. **Test locally first** - Use `/plugin marketplace add ./`
