---
description: Use when typing text into the focused window on the Raspberry Pi. Use for "type X", "enter text", "fill in the field", or any keyboard text input.
---

# pi:type

Send text input to the currently focused window on the Raspberry Pi.

## Two Approaches

| Situation | Tool | Environment |
|-----------|------|-------------|
| Plain text | `wtype` | Wayland |
| Keyboard shortcuts (Ctrl+C, Alt+F4) | `xdotool key` | XWayland |

## Commands

### Plain text -> wtype (preferred for text)
```bash
WAYLAND_DISPLAY=wayland-0 XDG_RUNTIME_DIR=/run/user/1000 wtype "text here"
```

### Text with special chars or paste workaround
```bash
WAYLAND_DISPLAY=wayland-0 XDG_RUNTIME_DIR=/run/user/1000 wtype -- "-text starting with dash"
```

### Keyboard shortcuts -> xdotool key
```bash
DISPLAY=:0 xdotool key ctrl+v
DISPLAY=:0 xdotool key ctrl+a
DISPLAY=:0 xdotool key ctrl+shift+t
```

## Notes

- Click the target field first (use `pi:click`) before typing
- For passwords or special Unicode: wtype handles UTF-8 natively
- If wtype has no effect, the focused window may be under X11 — fall back to `DISPLAY=:0 xdotool type "text"`

## Fallback (X11 app)
```bash
DISPLAY=:0 xdotool type "text here"
```
