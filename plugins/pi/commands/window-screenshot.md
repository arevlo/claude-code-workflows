---
description: Use when taking a screenshot of a specific window or region on the Raspberry Pi (Wayland/labwc). Use when the user names a specific app or window to capture, or wants to select a region interactively.
---

# pi:grim:window

Screenshot a specific window or selected region on the Raspberry Pi Wayland setup using `slurp` for region selection.

## Environment

Always prefix commands with:
```bash
WAYLAND_DISPLAY=wayland-0 XDG_RUNTIME_DIR=/run/user/1000
```

## Usage

### Interactive region select -> file (user clicks and drags)
```bash
WAYLAND_DISPLAY=wayland-0 XDG_RUNTIME_DIR=/run/user/1000 grim -g "$(WAYLAND_DISPLAY=wayland-0 XDG_RUNTIME_DIR=/run/user/1000 slurp)" /tmp/screenshot.png
```

### Interactive region select -> clipboard
```bash
WAYLAND_DISPLAY=wayland-0 XDG_RUNTIME_DIR=/run/user/1000 grim -g "$(WAYLAND_DISPLAY=wayland-0 XDG_RUNTIME_DIR=/run/user/1000 slurp)" - | wl-copy
```

### Named geometry (if you know coordinates)
```bash
WAYLAND_DISPLAY=wayland-0 XDG_RUNTIME_DIR=/run/user/1000 grim -g "X,Y WxH" /tmp/screenshot.png
# Example: grim -g "0,0 1920x1080" /tmp/screenshot.png
```

## Decision

```
User names a window/app?
+-- YES -> Take full screenshot first (use pi:grim:screen), identify window bounds visually, then crop with grim -g
+-- NO  -> Use slurp for interactive selection (user drags to select region)

User says "copy to clipboard"?
+-- YES -> pipe with | wl-copy
+-- NO  -> save to /tmp/screenshot.png and Read it
```

## Workflow for Named Window

1. Run `pi:grim:screen` to get full screenshot
2. Read the image to identify the window's approximate position
3. Use `grim -g "X,Y WxH"` to crop just that window

## Note on Wayland Window Listing

labwc does not expose window geometry via standard tools. Use the full-screen-then-crop approach above, or ask the user to use slurp to select the window interactively.
