# Learning Plugin

Personal learning tools for vocabulary lookup and grammar/punctuation rules. Supports English and Spanish.

## Commands

### `/arevlo:learning:vocab`

Look up a word — definition, pronunciation, and a simple example.

**Usage:**
```
/arevlo:learning:vocab <word>
/arevlo:learning:vocab es <word>
```

- Default language is English
- Prefix with `es` for Spanish lookups
- Uses web search to find definitions from authoritative dictionaries

### `/arevlo:learning:grammar`

Look up a grammar or punctuation rule — usage, examples, and common mistakes.

**Usage:**
```
/arevlo:learning:grammar <rule or punctuation mark>
/arevlo:learning:grammar es <rule>
```

- Default language is English
- Prefix with `es` for Spanish lookups
- Covers grammar rules, punctuation marks, commonly confused words

## Installation

This plugin is part of the `claude-code-workflows` marketplace.

1. Add the marketplace to `~/.claude.json`:
```json
{
  "extraKnownMarketplaces": {
    "claude-code-workflows": {
      "source": {
        "source": "github",
        "owner": "arevlo",
        "repo": "claude-code-workflows"
      }
    }
  }
}
```

2. Enable the plugin in `~/.claude/settings.json`:
```json
{
  "enabledPlugins": {
    "arevlo:learning@claude-code-workflows": true
  }
}
```

3. Restart Claude Code or run `/plugins refresh`
