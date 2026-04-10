---
description: Use when performing multi-step UI interactions on the Raspberry Pi — navigating menus, fixing settings, filling forms, or any task requiring screenshot + act + verify loops.
---

# pi:ui

Orchestrate multi-step UI interactions on the Raspberry Pi by chaining screenshot, action, and verification.

## Core Loop

```
screenshot -> analyze -> act -> screenshot -> verify -> repeat if needed
```

## Sub-skills

| Task | Skill |
|------|-------|
| Take screenshot | `pi:grim:screen` |
| Click element | `pi:click` |
| Type text | `pi:type` |
| Keyboard shortcut | `pi:key` |

## Workflow

1. **Capture current state** — run `pi:grim:screen` (uses `-s 0.25` by default -> 960x540 image, converted to JPEG), Read `/tmp/screenshot.jpg`
2. **Analyze** — identify what needs to happen, locate target element
3. **Act** — use `pi:click`, `pi:type`, or `pi:key`
4. **Verify** — run `pi:grim:screen` again, confirm expected change
5. **Repeat** if the goal requires more steps

## Coordinate Math (always required before clicking)

Screenshots from `grim -s 0.25` are quarter-resolution (960x540). Multiply all displayed coords by **4** to get physical pixel positions:
```
actual_x = displayed_x * 4
actual_y = displayed_y * 4
```

Physical screen is 3840x2160. The multiplier is always **4** when using the default `-s 0.25` screenshot.

## Example: Toggle a Checkbox in a Settings Dialog

```
1. pi:grim:screen -> locate "Output" tab at displayed (450, 80) x 4 = actual (1800, 320)
2. pi:click (1800, 320) -> Settings panel opens
3. pi:grim:screen -> verify Settings dialog
4. pi:click -> target checkbox coords (x4)
5. pi:grim:screen -> verify checkbox state changed
6. pi:key Return -> confirm/close dialog
7. pi:grim:screen -> verify main window
```

## Tips

- **Always verify after each action** — don't chain multiple clicks without checking state
- **Menus disappear quickly** — screenshot immediately after they open
- **Dialogs may shift layout** — re-read coordinates from fresh screenshot, don't reuse old ones
- **When stuck** — take a screenshot and re-analyze before retrying
- **Mouse clicks use ydotool** — `YDOTOOL_SOCKET=/tmp/.ydotool ydotool mousemove --absolute -x X -y Y`
- **Keyboard shortcuts use xdotool** — `DISPLAY=:0 xdotool key ctrl+c`
