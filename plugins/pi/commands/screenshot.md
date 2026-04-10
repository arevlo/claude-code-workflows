---
description: Use when taking a screenshot of the full screen or a specific monitor on the Raspberry Pi (Wayland/labwc). Use for "screenshot", "capture screen", "take a screenshot", or when you need to see what's on the display.
---

# pi:grim:screen

Screenshot the full screen or a named output on the Raspberry Pi Wayland setup.

## Environment

Always prefix grim commands with:
```bash
WAYLAND_DISPLAY=wayland-0 XDG_RUNTIME_DIR=/run/user/1000
```

## Available Outputs

- `HDMI-A-1` — primary display (3840x2160)

## Default: Quarter-resolution capture (-s 0.25)

Always use `-s 0.25` by default. This captures at **960x540**, which is:
- ~4x smaller file than full-res (~124KB PNG vs ~941KB)
- Sufficient resolution for reading UI elements and navigation
- Claude analyzes this ~4x faster than full-res (fewer API tiles)

**Coordinate multiplier: always x4** when using `-s 0.25`. Coords in the image must be multiplied by 4 before passing to `pi:click`.

### Default capture -> file (PNG)
```bash
WAYLAND_DISPLAY=wayland-0 XDG_RUNTIME_DIR=/run/user/1000 grim -s 0.25 /tmp/screenshot.png
```

### Default capture -> JPEG (recommended — 3x smaller for Claude)

`ffmpeg` is available. Convert PNG -> JPEG after capture for maximum speed:
```bash
WAYLAND_DISPLAY=wayland-0 XDG_RUNTIME_DIR=/run/user/1000 grim -s 0.25 /tmp/screenshot.png && ffmpeg -y -i /tmp/screenshot.png -q:v 5 /tmp/screenshot.jpg 2>/dev/null
```
Then Read `/tmp/screenshot.jpg`. Result: ~37KB vs 124KB PNG. ffmpeg adds ~0.33s but saves significant Claude analysis time.

### Default capture -> clipboard
```bash
WAYLAND_DISPLAY=wayland-0 XDG_RUNTIME_DIR=/run/user/1000 grim -s 0.25 - | wl-copy
```

## Full-resolution capture (use only when needed)

For pixel-perfect reading of small text or when `-s 0.25` misses detail:
```bash
WAYLAND_DISPLAY=wayland-0 XDG_RUNTIME_DIR=/run/user/1000 grim /tmp/screenshot.png
```
No multiplier needed — coords are 1:1 with physical pixels.

## Fast taskbar/region crop

To inspect a small region (e.g. the panel):
```bash
WAYLAND_DISPLAY=wayland-0 XDG_RUNTIME_DIR=/run/user/1000 grim -g "0,2120 3840x40" -s 0.25 /tmp/taskbar.png
```

## Specific output

```bash
WAYLAND_DISPLAY=wayland-0 XDG_RUNTIME_DIR=/run/user/1000 grim -s 0.25 -o HDMI-A-1 /tmp/screenshot.png
```

## Decision

- No args from user -> capture full screen with `-s 0.25`, convert to JPEG, Read `/tmp/screenshot.jpg`
- User says "copy to clipboard" -> pipe with `| wl-copy` instead of saving to file
- User names a monitor -> use `-o <output-name>`
- Pixel-perfect detail needed -> omit `-s 0.25` for full 3840x2160
- After capturing to file -> use Read tool to view it
