---
description: "List Apple Notes and display a selected note's content"
allowed-tools: Bash
---

# Notes: List

Browse and read Apple Notes from the CLI without opening the Notes app.

## How it works

A `notes` script can be installed at `/usr/local/bin/notes`. It:
1. Lists all Apple Notes with numbered selection
2. User picks a number
3. Displays the note's plain text content

## Usage

Run the script directly:

```bash
notes
```

If the script is missing, recreate it:

```bash
cat > /tmp/notes && chmod +x /tmp/notes && sudo cp /tmp/notes /usr/local/bin/notes << 'SCRIPT'
#!/bin/bash
IFS=',' read -ra NOTES <<< "$(osascript -e 'tell application "Notes" to get name of every note')"
[ ${#NOTES[@]} -eq 0 ] && echo "No notes found." && exit 1
for i in "${!NOTES[@]}"; do NOTES[$i]="$(echo "${NOTES[$i]}" | xargs)"; done
echo "Apple Notes"
echo "---------------------"
for i in "${!NOTES[@]}"; do echo "  $((i+1))) ${NOTES[$i]}"; done
echo "---------------------"
echo ""
read -p "Select a note (1-${#NOTES[@]}): " choice
if [[ "$choice" -ge 1 && "$choice" -le ${#NOTES[@]} ]] 2>/dev/null; then
  name="${NOTES[$((choice-1))]}"
  echo ""
  echo "--- $name ---"
  echo ""
  osascript -e "tell application \"Notes\" to get plaintext of note \"$name\"" 2>/dev/null
else
  echo "Invalid selection." && exit 1
fi
SCRIPT
```

## Quick operations without the script

```bash
# List all note names
osascript -e 'tell application "Notes" to get name of every note'

# Read a specific note by title
osascript -e 'tell application "Notes" to get plaintext of note "Note Title"'

# Search notes by name
osascript -e 'tell application "Notes" to get name of notes whose name contains "search term"'
```

## Prerequisites

- macOS with Apple Notes
- `osascript` (included with macOS)
