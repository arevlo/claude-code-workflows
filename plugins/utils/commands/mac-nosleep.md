---
description: "Toggle macOS sleep prevention (keeps Mac awake with lid closed)"
argument-hint: "<on|off|status>"
allowed-tools: Bash
---

# Mac No-Sleep Toggle

Prevents macOS from sleeping even with the lid closed (requires power connected).

**Usage:** `/mac-nosleep on` | `/mac-nosleep off` | `/mac-nosleep status`

Run the appropriate command based on the argument:

- **on**: `sudo pmset -a disablesleep 1 && echo "nosleep ON — Mac will stay awake with lid closed (keep power connected)"`
- **off**: `sudo pmset -a disablesleep 0 && echo "nosleep OFF — normal sleep behavior restored"`
- **status**: `pmset -g | grep -E 'disablesleep|sleep'`

If no argument is provided, run the status command and show the user current state.

**Important:** Always remind the user to run `/mac-nosleep off` when done, or sleep will stay disabled permanently.
