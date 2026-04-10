---
skill: obsidian:search
type: local
title: Vault Search
description: Search the Obsidian vault for notes matching a query. Use when finding notes, looking up topics, or locating specific content across the vault.
allowed-tools: Bash, AskUserQuestion
---

# Vault Search

Search the Obsidian vault using the CLI and display results with context.

## Steps

### 1. Parse Query

Extract the search query from `$ARGUMENTS`.

- If empty, use `AskUserQuestion` to ask: "What do you want to search for?"
- Check for flags:
  - `--folder="path"` -> restrict search to a vault subfolder
  - `--case` -> case-sensitive search
  - `--limit=N` -> max results (default 20)

### 2. Run Search

```bash
obsidian search:context query="{query}" limit={N}
```

If `--folder` was provided:
```bash
obsidian search:context query="{query}" path="{folder}" limit={N}
```

If `--case` was provided, add `case=true`.

### 3. Display Results

Format the CLI output for readability:

```
Search: "{query}" -- {N} results

  {file path}
    ...matching line with context...

  {file path}
    ...matching line with context...
```

If zero results, say so and suggest:
- Broadening the query
- Checking spelling
- Trying a different folder

### 4. Offer Follow-ups

After displaying results, offer:
- "Read one of these files? Give me the number or path."
- "Narrow the search? Add more terms."
- "Search in a specific folder?"

Wait for user input before taking action.
