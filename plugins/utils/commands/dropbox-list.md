---
description: Use when the user wants to list, browse, or find files and folders in their Dropbox. Triggers on "list dropbox", "what's in dropbox", "show dropbox files", "browse dropbox".
allowed-tools: Bash
---

# Dropbox List

List files and folders in Dropbox using rclone.

## Default Behavior

When invoked, immediately run both `rclone lsd dropbox:` (folders) and `rclone ls dropbox: --max-depth 1` (files) to show everything at the root. If the user specifies a path, list that path instead. Do NOT ask the user what to list — just list it.

## Commands

| Action | Command |
|--------|---------|
| List top-level folders | `rclone lsd dropbox:` |
| List files in a folder | `rclone ls dropbox:path/to/folder` |
| List with details (size, date) | `rclone lsl dropbox:path/to/folder` |
| List folders only | `rclone lsd dropbox:path/to/folder` |
| Tree view (1 level deep) | `rclone tree dropbox:path --max-depth 1` |
| Find files by name | `rclone ls dropbox: --include "*.pdf"` |

## Prerequisites

- [rclone](https://rclone.org/) installed and configured with a `dropbox:` remote

## Notes

- Remote name is `dropbox:` (with colon)
- Paths are relative to Dropbox root — no leading slash
- `lsd` = directories only, `ls` = files only, `lsl` = files with size/date
- Add `--max-depth N` to limit recursion depth
