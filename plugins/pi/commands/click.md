---
description: Use when clicking a UI element on the Raspberry Pi screen — by description or coordinates. Use for "click X", "open Y", "press the button", or any mouse interaction with the desktop.
---

# pi:click

Move the mouse to a screen position and click, using ydotool (Wayland-native via uinput).

## Environment

ydotool communicates with the ydotoold daemon via socket:
```bash
YDOTOOL_SOCKET=/tmp/.ydotool ydotool ...
```

The daemon runs as a systemd user service (`ydotoold.service`) and must be active.

## Coordinate System

- Physical screen: **3840x2160** (labwc scale = 1.0, no compositor scaling)
- Screenshots taken with `grim -s 0.25` are **960x540** — multiply all coords by **4**:
  ```
  actual_x = displayed_x * 4
  actual_y = displayed_y * 4
  ```

## Workflow

1. Take screenshot: use `pi:grim:screen` (default is `-s 0.25`) -> Read image -> multiply coords by 4
2. Identify element position in displayed image (x, y)
3. Multiply by 4 -> physical pixel coords
4. Move and click

## Commands

### Left click
```bash
YDOTOOL_SOCKET=/tmp/.ydotool ydotool mousemove --absolute -x X -y Y && YDOTOOL_SOCKET=/tmp/.ydotool ydotool click 0x110
```

### Right click
```bash
YDOTOOL_SOCKET=/tmp/.ydotool ydotool mousemove --absolute -x X -y Y && YDOTOOL_SOCKET=/tmp/.ydotool ydotool click 0x111
```

### Double click
```bash
YDOTOOL_SOCKET=/tmp/.ydotool ydotool mousemove --absolute -x X -y Y && YDOTOOL_SOCKET=/tmp/.ydotool ydotool click 0x110 && YDOTOOL_SOCKET=/tmp/.ydotool ydotool click 0x110
```

## Note: Keyboard shortcuts still use xdotool

xdotool key events work fine via XWayland — only mouse movement was broken:
```bash
DISPLAY=:0 xdotool key ctrl+c
```

## Verify

After clicking, always take a follow-up screenshot with `pi:grim:screen` and confirm the expected change happened.

## Decision

```
User gives natural language target ("click Settings")?
+-- YES -> screenshot first, locate element, multiply coords by 4, click
+-- NO, gives coords -> multiply by 4, click directly

Need to verify outcome?
+-- ALWAYS -> take follow-up screenshot and read it
```
