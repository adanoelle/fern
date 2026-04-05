# Hyprland

> Hyprland is the Wayland compositor at the center of the desktop environment,
> configured with dwindle tiling, Catppuccin colors, and hjkl-based navigation.

The Hyprland configuration is a den aspect (`den.aspects.hyprland`) defined in
`modules/desktop/hyprland.nix`, with sub-modules split into
`modules/desktop/_hyprland/`. The underscore prefix convention (`_hyprland/`)
indicates a private sub-module directory belonging to the `hyprland.nix` aspect.
The main aspect file defines the window manager behavior, keybindings,
animations, and style. Sub-modules handle the bar, wallpaper, idle/lock, and the
Fern shell.

## Core settings

The compositor uses the dwindle tiling layout with these defaults:

| Setting         | Value                       |
| --------------- | --------------------------- |
| Mod key         | `SUPER`                     |
| Terminal        | Ghostty                     |
| App runner      | Wofi                        |
| Layout          | Dwindle                     |
| Gaps (inner)    | 6px                         |
| Gaps (outer)    | 12px                        |
| Border width    | 2px                         |
| Corner rounding | 5px                         |
| Active border   | `cba6f7` (Catppuccin mauve) |
| Inactive border | `303446` (Catppuccin base)  |

All style values are configurable through the `desktop.hyprland.style` option
set in the host configuration.

## Keybindings

**Window management:**

| Binding                   | Action                         |
| ------------------------- | ------------------------------ |
| `Super + Return`          | Open terminal (Ghostty)        |
| `Super + Q`               | Close active window            |
| `Super + R`               | Launch app runner (Wofi)       |
| `Super + H/J/K/L`         | Focus left/down/up/right       |
| `Super + Shift + H/J/K/L` | Move window left/down/up/right |
| `Super + 1-9`             | Switch to workspace            |
| `Super + Shift + 1-9`     | Move window to workspace       |
| `Super + F`               | Toggle fullscreen              |
| `Super + V`               | Toggle floating                |
| `Super + P`               | Toggle pseudo-tiling           |

**Screenshots** (provided by the screenshot module):

| Binding             | Action                    |
| ------------------- | ------------------------- |
| `Super + S`         | Region select → annotate  |
| `Super + Shift + S` | Full screen → annotate    |
| `Super + Alt + S`   | Region select → clipboard |
| `Super + Ctrl + S`  | Full screen → file        |

**Wallpaper:**

| Binding             | Action                          |
| ------------------- | ------------------------------- |
| `Super + W`         | Cycle workspace wallpaper       |
| `Super + Shift + W` | Random wallpaper from directory |

## Animations

Window animations use the `easeOutQuint` bezier curve:

- **Window open/close** -- slide in over 300ms
- **Border color** -- transition over 200ms
- **Fade** -- 150ms opacity transition
- **Workspace switch** -- slide over 400ms

## Layer rules

Waybar (when enabled) and QuickShell get blur and transparency via Hyprland
layer rules:

```
layerrule = blur, waybar
layerrule = ignorealpha 0.3, waybar
layerrule = blur, quickshell
layerrule = ignorealpha 0.3, quickshell
```

## Monitor configuration

Fern uses `HDMI-A-1` as the primary monitor. Moss uses auto-detection (empty
monitor string). Per-host monitor setup is configured in the user aspect
(`modules/user-ada.nix`) through the wallpaper module's `monitor` option.

## Key files

| File                                       | Purpose                                         |
| ------------------------------------------ | ----------------------------------------------- |
| `modules/desktop/hyprland.nix`             | Main den aspect: compositor config, keybindings, animations |
| `modules/desktop/_hyprland/bar.nix`        | Waybar configuration (disabled by default)      |
| `modules/desktop/_hyprland/fern.nix`       | Fern Shell integration                          |
| `modules/desktop/_hyprland/wallpaper.nix`  | swww wallpaper management                       |
| `modules/desktop/_hyprland/idlelock.nix`   | hypridle + hyprlock                             |
| `modules/desktop/screenshot.nix`           | Screenshot scripts and bindings                 |
