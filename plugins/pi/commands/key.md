---
description: Use when sending keyboard shortcuts or special keys on the Raspberry Pi. Use for "press Enter", "hit Escape", "Ctrl+C", "Alt+F4", or any key combination.
---

# pi:key

Send keyboard shortcuts and special keys via xdotool on the Raspberry Pi.

## Environment

```bash
DISPLAY=:0 xdotool key <keysym>
```

## Common Keys

### Navigation
```bash
DISPLAY=:0 xdotool key Return       # Enter
DISPLAY=:0 xdotool key Escape       # Esc
DISPLAY=:0 xdotool key Tab          # Tab
DISPLAY=:0 xdotool key BackSpace    # Backspace
DISPLAY=:0 xdotool key Delete       # Delete
DISPLAY=:0 xdotool key space        # Spacebar
```

### Arrow keys
```bash
DISPLAY=:0 xdotool key Up
DISPLAY=:0 xdotool key Down
DISPLAY=:0 xdotool key Left
DISPLAY=:0 xdotool key Right
```

### Common shortcuts
```bash
DISPLAY=:0 xdotool key ctrl+c       # Copy
DISPLAY=:0 xdotool key ctrl+v       # Paste
DISPLAY=:0 xdotool key ctrl+a       # Select all
DISPLAY=:0 xdotool key ctrl+z       # Undo
DISPLAY=:0 xdotool key ctrl+f       # Find
DISPLAY=:0 xdotool key ctrl+w       # Close tab/window
DISPLAY=:0 xdotool key ctrl+shift+t # New terminal tab
DISPLAY=:0 xdotool key alt+F4       # Close window
DISPLAY=:0 xdotool key super        # Super/Win key
```

### Function keys
```bash
DISPLAY=:0 xdotool key F1
DISPLAY=:0 xdotool key F5           # Refresh
DISPLAY=:0 xdotool key F11          # Fullscreen
```

## Key Syntax

- Modifiers: `ctrl`, `alt`, `shift`, `super`
- Combine with `+`: `ctrl+shift+Escape`
- X11 keysym names — for special chars see `xdotool key --help`

## Note on Wayland

xdotool works via XWayland. For typing text (not shortcuts), prefer `wtype` — see `pi:type`.
