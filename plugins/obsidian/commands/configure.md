---
description: Configure Obsidian plugin vault paths
allowed-tools: Read,Write,AskUserQuestion
---

Configure or update the Obsidian plugin paths used by `/capture`, `/save-link`, and `/gmail-digest`.

## What this does

Sets up `~/.claude/obsidian-plugin.json` with your personal vault and output paths so all Obsidian plugin commands work correctly.

## Steps

### 1. Check for Existing Configuration

Use the `Read` tool to read `~/.claude/obsidian-plugin.json`.

- **If the file exists:** Show the current configuration values to the user.
- **If the file does not exist:** Inform the user that no configuration exists yet.

### 2. Ask for Vault Path

Use `AskUserQuestion` to ask:
- Question: "What is the absolute path to your Obsidian vault?"
- If updating, show the current value as context in the question
- Remind the user to use an absolute path (no `~`)

### 3. Ask for Digest Output Path

Use `AskUserQuestion` to ask:
- Question: "What is the absolute path for Gmail digest output files?"
- If updating, show the current value as context in the question
- Remind the user to use an absolute path (no `~`)

### 4. Save Configuration

Use the `Write` tool to save the config to `~/.claude/obsidian-plugin.json`:

```json
{
  "vault_path": "{user's vault path}",
  "digest_output_path": "{user's digest path}"
}
```

### 5. Confirm

Show the saved configuration:

```
Obsidian plugin configured!

  vault_path:         {vault_path}
  digest_output_path: {digest_output_path}

Config saved to: ~/.claude/obsidian-plugin.json
```
