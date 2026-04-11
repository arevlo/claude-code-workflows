---
skill: obsidian:note:create
type: local
title: Create Obsidian Note
description: Use when creating a new note in an Obsidian vault -- detects all vaults registered on the current machine, lets user choose vault and subfolder, and writes a formatted markdown note.
allowed-tools: Bash, Read, Write, AskUserQuestion
---

# obsidian:note:create

Create a new note in any Obsidian vault registered on the current machine.

## Vault Detection

Obsidian stores registered vaults in a JSON file. Read it based on OS:

| OS | Path |
|----|------|
| Linux / Raspberry Pi | `~/.config/obsidian/obsidian.json` |
| macOS | `~/Library/Application Support/obsidian/obsidian.json` |
| Windows | `%APPDATA%\Obsidian\obsidian.json` |

Parse with:
```bash
# Linux/macOS
cat ~/.config/obsidian/obsidian.json | python3 -c "
import sys, json
d = json.load(sys.stdin)
for vid, v in d.get('vaults', {}).items():
    print(v['path'])
"
```

## Process

### Step 1 -- Detect vaults

Run the detection command for the current OS. List all vault paths found.

### Step 2 -- Choose vault

If user already named a vault (e.g. "my-notes vault"), match by the last segment of the path (`os.path.basename`). Otherwise present numbered list and ask user to pick.

### Step 3 -- Choose / create subfolder

Ask the user for a subfolder path relative to vault root (e.g. `security/raspberry-pi`). If not provided, place note at vault root.

Create folder if it doesn't exist:
```bash
mkdir -p "/path/to/vault/subfolder"
```

### Step 4 -- Determine filename

- If user provided a title, slugify it: lowercase, spaces to hyphens, strip special chars
- Default: `YYYY-MM-DD-<slug>.md`
- If user wants a specific name (no date prefix), use that exactly

Check if file already exists -- if so, warn and ask to overwrite or pick new name.

### Step 5 -- Write the note

Use frontmatter + content:

```markdown
---
date: YYYY-MM-DD
tags: [tag1, tag2]
---

# Note Title

{content}
```

- `date`: today's date (`date +%Y-%m-%d`)
- `tags`: infer from context or ask user
- Title: H1 heading matching the note subject

### Step 6 -- Confirm

Show the user:
- Full file path written
- First 5 lines of the note
- Link format: `[[note-filename]]` for internal linking

## Rules

- Never overwrite an existing file without explicit user confirmation
- Always create intermediate directories (`mkdir -p`)
- Slugify filenames -- no spaces, no special chars except hyphens
- Include frontmatter on every note
- If content is long (audit reports, summaries), write the full content -- do not truncate
- If user says "no date prefix", omit the date from the filename

## Examples

```
User: "save this to obsidian under security/raspberry-pi in the my-notes vault"
-> Detect vaults -> match "my-notes" -> mkdir security/raspberry-pi -> write note

User: "add to obsidian, personal/learnings folder"
-> Detect vaults -> select vault -> mkdir personal/learnings -> write note
```
