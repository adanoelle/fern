# Ghostty

> Ghostty is the secondary terminal emulator: kitty is the primary,
> garden-themed terminal, while Ghostty is kept as a fast, batteries-included
> alternative. It follows the garden palette and mono face at run time
> through two optional includes (see
> [The Garden Design System](../desktop/garden.md)).

## Overview

The `ghostty` aspect (`modules/cli/ghostty.nix`) configures
[Ghostty](https://ghostty.org) using Home Manager's `programs.ghostty` module.
Ghostty is a GPU-accelerated terminal emulator focused on speed and
correctness.

## Configuration

```nix
den.aspects.ghostty.homeManager = { config, ... }: {
  programs.ghostty = {
    enable = true;
    settings = {
      font-family = "FiraCode Nerd Font";
      font-size = 11;
      config-file = [
        "?${config.xdg.configHome}/garden/themes/ghostty/garden-theme"
        "?${config.xdg.configHome}/garden/fonts/ghostty"
      ];
      keybind = [ /* tabs, splits, font size — see below */ ];
    };
  };
};
```

### Settings

| Setting | Value | Purpose |
|---------|-------|---------|
| `font-family` | FiraCode Nerd Font | Ligatures + icon glyphs |
| `font-size` | 11 | Default font size |
| `config-file` | garden theme + font | Active garden palette (written by `garden-themes`) and mono face (written by the shell); both optional, reloaded on SIGUSR2 |

### Keybindings

The aspect defines keybindings for tabs, splits, and font size:

| Keybinding | Action |
|------------|--------|
| `Alt+T` / `Alt+W` | New tab / close tab |
| `Alt+1-5` | Go to tab 1–5 |
| `Alt+Shift+V` / `Alt+Shift+S` | New split right / down |
| `Alt+H/J/K/L` | Navigate splits (vim-style) |
| `Ctrl+Alt+H/J/K/L` | Resize splits |
| `Shift+PageUp/PageDown` | Scroll by page |
| `Ctrl+Equal` / `Ctrl+Minus` / `Ctrl+0` | Font size up / down / reset |
| `Shift+Enter` | Insert literal newline |
| `Ctrl+Shift+C/V` | Copy / paste |

## Part of the CLI bundle

Ghostty is included in the CLI bundle:

```nix
# modules/cli/bundle.nix (excerpt)
den.aspects.cli.includes = [ den.aspects.ghostty /* ... */ ];
```

It is also the default terminal of the
[Hyprland fallback session](../desktop/hyprland.md) (`Super+Return`); the
primary Niri session spawns kitty.

## Key files

| File | Purpose |
|------|---------|
| `modules/cli/ghostty.nix` | Ghostty configuration and keybindings |
| `modules/cli/bundle.nix` | CLI bundle (includes ghostty) |
| `modules/desktop/hyprland.nix` | Sets ghostty as default terminal (fallback session) |
