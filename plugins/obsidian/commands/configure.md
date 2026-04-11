---
skill: obsidian:configure
type: local
title: Configure Obsidian Plugin
description: Configure Obsidian plugin vault paths
tags: [obsidian, configuration, setup]
allowed-tools: Bash, Read, Write, AskUserQuestion
---

Configure or update the Obsidian plugin paths used by `/Obsidian:capture`, `/Obsidian:save-link`, and `/Obsidian:gmail-digest`.

## What this does

Sets up `~/.claude/obsidian-plugin.json` with your personal vault and output paths so all Obsidian plugin commands work correctly.

## Steps

### 1. Check for Existing Configuration

Use the `Read` tool to read `~/.claude/obsidian-plugin.json`.

- **If the file exists:** Show the current configuration values to the user.
- **If the file does not exist:** Inform the user that no configuration exists yet.

### 2. Auto-detect Vault Path

Try to detect the vault path from the CLI:
```bash
obsidian vault info=path
```

- **If successful:** Show the detected path and use it as the default suggestion in the next step.
- **If it fails** (Obsidian not running or CLI not installed): Skip auto-detect, proceed to manual entry.

### 3. Ask for Vault Path

Use `AskUserQuestion` to ask:
- Question: "What is the absolute path to your Obsidian vault?"
- If auto-detected, show the detected path and ask: "Detected vault at `{path}`. Use this, or enter a different path?"
- If updating, show the current value as context in the question
- Remind the user to use an absolute path (no `~`)

### 4. Ask for Digest Output Path

Use `AskUserQuestion` to ask:
- Question: "What is the absolute path for Gmail digest output files?"
- If updating, show the current value as context in the question
- Remind the user to use an absolute path (no `~`)

### 5. Save Configuration

Use the `Write` tool to save the config to `~/.claude/obsidian-plugin.json`:

```json
{
  "vault_path": "{user's vault path}",
  "digest_output_path": "{user's digest path}"
}
```

### 6. Confirm

Show the saved configuration:

```
Obsidian plugin configured!

  vault_path:         {vault_path}
  digest_output_path: {digest_output_path}

Config saved to: ~/.claude/obsidian-plugin.json
```
