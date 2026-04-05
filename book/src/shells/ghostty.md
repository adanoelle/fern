# Ghostty

> Ghostty is the terminal emulator, configured as a CLI aspect with FiraCode
> Nerd Font, Catppuccin Frappe theme, and keybindings for tabs and splits.

## Overview

The `ghostty` aspect (`modules/cli/ghostty.nix`) configures
[Ghostty](https://ghostty.org) using Home Manager's `programs.ghostty` module.
Ghostty is a GPU-accelerated terminal emulator focused on speed and
correctness.

## Configuration

```nix
den.aspects.ghostty.homeManager = { pkgs, ... }: {
  programs.ghostty = {
    enable = true;
    settings = {
      font-family = "FiraCode Nerd Font";
      font-size = 13;
      theme = "catppuccin-frappe";
      window-decoration = false;
      confirm-close-surface = false;
    };
  };
};
```

### Settings

| Setting | Value | Purpose |
|---------|-------|---------|
| `font-family` | FiraCode Nerd Font | Ligatures + icon glyphs |
| `font-size` | 13 | Default font size |
| `theme` | catppuccin-frappe | Matches the system-wide Catppuccin theme |
| `window-decoration` | false | No title bar (Hyprland handles window chrome) |
| `confirm-close-surface` | false | Close tabs without confirmation prompt |

### Keybindings

The aspect defines keybindings for tab and split management:

| Keybinding | Action |
|------------|--------|
| `Ctrl+Shift+T` | New tab |
| `Ctrl+Shift+W` | Close tab |
| `Ctrl+Tab` | Next tab |
| `Ctrl+Shift+Tab` | Previous tab |
| `Ctrl+Shift+Enter` | New split |
| `Ctrl+Shift+H/J/K/L` | Navigate splits (vim-style) |
| `Ctrl+Shift+Plus` | Increase font size |
| `Ctrl+Shift+Minus` | Decrease font size |
| `Ctrl+Shift+0` | Reset font size |

## Part of the CLI bundle

Ghostty is included in the CLI bundle:

```nix
# modules/cli/bundle.nix (excerpt)
den.aspects.cli.includes = [ den.aspects.ghostty /* ... */ ];
```

It is also set as the default terminal in the Hyprland aspect:

```nix
# modules/desktop/hyprland.nix (excerpt)
terminal = lib.mkOption { type = lib.types.str; default = "ghostty"; };
```

Pressing `Super+Return` in Hyprland opens Ghostty.

## Terminfo

The aspect sets `TERMINFO_DIRS` to include Ghostty's terminfo database, ensuring
that remote SSH sessions and tools like `tmux` correctly recognize the terminal
capabilities.

## Key files

| File | Purpose |
|------|---------|
| `modules/cli/ghostty.nix` | Ghostty configuration and keybindings |
| `modules/cli/bundle.nix` | CLI bundle (includes ghostty) |
| `modules/desktop/hyprland.nix` | Sets ghostty as default terminal |
