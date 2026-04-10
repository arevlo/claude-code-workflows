# pi

Raspberry Pi remote desktop control for Wayland/labwc via SSH. Lets Claude Code interact with a Pi's graphical desktop -- taking screenshots, clicking UI elements, typing text, sending keyboard shortcuts, and orchestrating multi-step UI workflows.

## Installation

```
/install-plugin pi@claude-code-workflows
```

## Commands

| Command | Description |
|---------|-------------|
| `/click` | Click a UI element by description or coordinates using ydotool |
| `/screenshot` | Capture the full screen or a specific monitor using grim |
| `/window-screenshot` | Capture a specific window or region using grim + slurp |
| `/key` | Send keyboard shortcuts or special keys via xdotool |
| `/type` | Type text into the focused window using wtype |
| `/ui` | Orchestrate multi-step UI interactions (screenshot-act-verify loops) |

## How It Works

The plugin operates over SSH to a Raspberry Pi running a Wayland compositor (labwc). It uses:

- **grim** for screenshots (default quarter-resolution for fast analysis)
- **ydotool** for mouse movement and clicks (Wayland-native via uinput)
- **wtype** for typing text into Wayland windows
- **xdotool** for keyboard shortcuts (via XWayland)
- **slurp** for interactive region selection

Screenshots are captured at 25% resolution by default (960x540 from a 3840x2160 display). All coordinates from screenshots must be multiplied by 4 before passing to click commands.

## Requirements

- Raspberry Pi with **labwc** (or another Wayland compositor)
- **grim** -- screenshot utility for Wayland
- **slurp** -- region selection tool for Wayland
- **ydotool** + **ydotoold** -- Wayland-compatible mouse/keyboard automation
- **wtype** -- Wayland text input tool
- **xdotool** -- X11 keyboard automation (works via XWayland)
- **ffmpeg** (optional) -- for PNG-to-JPEG conversion to reduce screenshot size
- **wl-copy** (from wl-clipboard, optional) -- for clipboard operations
