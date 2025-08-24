# 🖥️ Desktop Environment - Hyprland Configuration

> **Purpose:** Complete Wayland desktop environment with Hyprland compositor  
> **Type:** Feature Suite  
> **Status:** Stable

## Overview

A modern, performant desktop environment built on Hyprland, a dynamic tiling
Wayland compositor. This configuration provides a complete desktop experience
with automatic tiling, beautiful animations, and extensive customization.

## Quick Start

```bash
# Key bindings (SUPER = Windows/Cmd key)
SUPER + Return      # Open terminal (Ghostty)
SUPER + D           # Open launcher (Rofi)
SUPER + Q           # Close window
SUPER + M           # Exit Hyprland
SUPER + [1-9]       # Switch workspace
SUPER + Shift + [1-9] # Move window to workspace

# Window management
SUPER + [H/J/K/L]   # Focus window (Vim-like)
SUPER + V           # Toggle floating
SUPER + F           # Toggle fullscreen
SUPER + P           # Toggle pseudo-tiling
```

## What's Inside

| Component       | Purpose                  | Configuration Location           |
| --------------- | ------------------------ | -------------------------------- |
| `hyprland/`     | Compositor configuration | Main window management           |
| `waybar/`       | Status bar               | System monitoring and workspaces |
| `hypridle.nix`  | Idle management          | Screen dimming and suspension    |
| `hyprlock.nix`  | Screen locker            | Security and lock screen         |
| `hyprpaper.nix` | Wallpaper manager        | Per-workspace wallpapers         |
| `mako.nix`      | Notification daemon      | Desktop notifications            |
| `rofi.nix`      | Application launcher     | App search and window switcher   |
| `wlogout.nix`   | Session manager          | Power menu                       |
| `default.nix`   | Module orchestration     | Imports and dependencies         |

## Core Components

### 🪟 Hyprland Compositor

Dynamic tiling with animations:

**Features:**

- Automatic window tiling
- Smooth animations
- Touch gestures support
- Multi-monitor ready
- Per-workspace layouts

**Configuration:**

- `hyprland/default.nix` - Main configuration
- `hyprland/keybinds.nix` - Keyboard shortcuts
- `hyprland/rules.nix` - Window rules
- `hyprland/animations.nix` - Visual effects

### 📊 Waybar Status Bar

Information-rich status bar:

**Widgets:**

- Workspace indicators
- CPU/Memory/Disk usage
- Network status
- Battery level
- Clock and calendar
- System tray

**Features:**

- Click actions for all modules
- Hover tooltips with details
- Custom scripts integration
- Dynamic styling

### 🎨 Desktop Services

**Hypridle** - Intelligent idle management:

```bash
# Configuration
5 minutes  → Screen dims
10 minutes → Screen locks
15 minutes → Suspend
```

**Hyprlock** - Secure screen locking:

- Password authentication
- Custom lock screen layout
- Media controls while locked

**Hyprpaper** - Dynamic wallpapers:

- Per-workspace wallpapers
- Smooth transitions
- Low resource usage

**Mako** - Notification system:

- Grouped notifications
- Action buttons
- Priority levels
- Do not disturb mode

### 🚀 Rofi Launcher

Powerful application launcher:

**Modes:**

- `drun` - Desktop applications
- `run` - Command execution
- `window` - Window switcher
- `ssh` - SSH connections
- `filebrowser` - File browsing

**Usage:**

```bash
SUPER + D          # Open launcher
SUPER + Tab        # Window switcher
SUPER + Shift + S  # SSH menu
```

## Window Management

### Layouts

Hyprland supports multiple layouts:

1. **Tiling** (default) - Automatic tile arrangement
2. **Pseudo** - Single window with others hidden
3. **Floating** - Free window positioning

### Window Rules

Common window rules configured:

```nix
# Examples from configuration
windowrulev2 = [
  "float,class:^(pavucontrol)$"      # Audio control floats
  "size 800 600,class:^(thunar)$"    # File manager size
  "center,class:^(rofi)$"            # Center launcher
  "pin,title:^(Picture-in-Picture)$" # Pin PiP windows
];
```

### Workspaces

10 workspaces configured with:

- Per-workspace wallpapers
- Persistent workspace assignments
- Multi-monitor support
- Smooth switching animations

## Keybindings

### Essential Shortcuts

| Binding          | Action     | Description          |
| ---------------- | ---------- | -------------------- |
| `SUPER + Return` | Terminal   | Open Ghostty         |
| `SUPER + Q`      | Close      | Close focused window |
| `SUPER + D`      | Launcher   | Open Rofi            |
| `SUPER + M`      | Exit       | Exit Hyprland        |
| `SUPER + V`      | Float      | Toggle floating      |
| `SUPER + F`      | Fullscreen | Toggle fullscreen    |

### Navigation

| Binding             | Action    | Description           |
| ------------------- | --------- | --------------------- |
| `SUPER + [H/J/K/L]` | Focus     | Move focus (Vim-like) |
| `SUPER + [1-9]`     | Workspace | Switch to workspace   |
| `SUPER + Tab`       | Cycle     | Cycle through windows |
| `ALT + Tab`         | Switch    | Window switcher       |

### Window Movement

| Binding                     | Action | Description          |
| --------------------------- | ------ | -------------------- |
| `SUPER + Shift + [H/J/K/L]` | Move   | Move window          |
| `SUPER + Shift + [1-9]`     | Send   | Send to workspace    |
| `SUPER + Mouse`             | Drag   | Drag floating window |

### Screenshots

| Binding                 | Action | Description              |
| ----------------------- | ------ | ------------------------ |
| `Print`                 | Full   | Screenshot entire screen |
| `SUPER + Print`         | Area   | Screenshot selection     |
| `SUPER + Shift + Print` | Window | Screenshot window        |

## Customization

### Changing Wallpapers

Edit workspace wallpapers:

```nix
# In hyprland/hyprpaper.nix
preload = [
  "~/Pictures/Wallpapers/wallpaper1.jpg"
  "~/Pictures/Wallpapers/wallpaper2.jpg"
];

wallpaper = [
  "DP-1,~/Pictures/Wallpapers/wallpaper1.jpg"
  "HDMI-A-1,~/Pictures/Wallpapers/wallpaper2.jpg"
];
```

### Waybar Styling

Customize appearance:

```css
/* In waybar/style.css */
* {
  font-family: 'JetBrainsMono Nerd Font';
  font-size: 13px;
}

#workspaces button.active {
  background: #64b5f6;
  color: #000000;
}
```

### Animation Tweaks

Adjust animation settings:

```nix
# In hyprland/animations.nix
animations = {
  enabled = true;
  bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

  animation = [
    "windows, 1, 7, myBezier"
    "windowsOut, 1, 7, default, popin 80%"
    "border, 1, 10, default"
  ];
};
```

## Troubleshooting

### Hyprland Won't Start

```bash
# Check logs
journalctl -u greetd -b

# Test configuration
Hyprland -c ~/.config/hypr/hyprland.conf --test

# Start manually
Hyprland > /tmp/hypr.log 2>&1
```

### Waybar Issues

```bash
# Restart waybar
killall waybar
waybar &

# Check configuration
waybar -c ~/.config/waybar/config -s ~/.config/waybar/style.css
```

### Screen Tearing

```nix
# Enable VRR in configuration
misc = {
  vrr = 1;  # Variable refresh rate
  no_direct_scanout = false;
};
```

### Multi-Monitor Setup

```nix
# Configure monitors in hyprland.conf
monitor = [
  "DP-1,2560x1440@144,0x0,1"
  "HDMI-A-1,1920x1080@60,2560x0,1"
];
```

## Performance Tips

1. **Disable animations** if on older hardware
2. **Reduce blur** for better performance
3. **Use `gamescope`** for gaming
4. **Enable direct scanout** for fullscreen apps
5. **Adjust `vfr`** (variable frame rate) settings

## Integration

### With Other Modules

- **Terminal**: Ghostty configured as default
- **Editor**: Helix with Hyprland integration
- **Shell**: Status integration with Starship
- **Git**: Git status in Waybar
- **Audio**: Volume control in Waybar

### Application Recommendations

Works best with:

- **Browser**: Firefox with Wayland support
- **File Manager**: Thunar or PCManFM
- **Media**: mpv for video playback
- **Image Viewer**: imv or swayimg

## See Also

- **[Home Modules](../)** - Parent module directory
- **[Ghostty Terminal](../ghostty.nix)** - Terminal configuration
- **[Shell Configuration](../shells/)** - Shell integration
- **[Hyprland Wiki](https://wiki.hyprland.org/)** - Official documentation

---

_A desktop environment that adapts to your workflow, not the other way around._
