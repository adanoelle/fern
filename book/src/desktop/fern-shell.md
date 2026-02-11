# Fern Shell (QuickShell)

> Fern Shell is a custom status bar built with QuickShell, replacing Waybar as
> the primary panel. It runs as a hardened systemd user service.

Fern Shell is an external project (`adanoelle/fern-shell`) consumed as a flake
input. The Home Manager module in `nix/home/desktop/hyprland/fern.nix`
integrates it into the desktop environment as a systemd user service with
optional OBS integration and theme watching.

## What it provides

- **fern-shell** -- The QuickShell-based status bar
- **fern-theme** -- Theme package for consistent styling
- **fernctl** -- CLI control tool for the bar
- **quickshell** -- The QuickShell runtime

## Optional components

### OBS bridge

When `fern.obs.enable = true`, a companion daemon (`fern-obs`) runs alongside
the shell to expose OBS status in the bar. It runs as a separate systemd service
with tight resource limits (50MB memory, 10 tasks).

### Theme watcher

When `fern.themeWatcher.enable = true`, a service watches for theme changes and
reloads the shell styling live.

## Systemd hardening

The fern-shell service runs with restricted permissions:

```ini
[Service]
PrivateTmp = true
ProtectSystem = strict
ProtectHome = read-only
MemoryMax = 200M
TasksMax = 50
```

The OBS daemon adds restart-on-failure with exponential backoff (`RestartSec=5`,
standard systemd backoff).

## Hyprland integration

The module adds layer rules so QuickShell surfaces get blur and transparency:

```
layerrule = blur, quickshell
layerrule = ignorealpha 0.3, quickshell
```

## Configuration in host

```nix
desktop.hyprland.fern = {
  enable = true;
  obs.enable = false;
  themeWatcher.enable = false;
};
```

Waybar (`bar.enable`) should be set to `false` when using Fern Shell to avoid
running two bars.

## Key files

| File                                 | Purpose                                             |
| ------------------------------------ | --------------------------------------------------- |
| `nix/home/desktop/hyprland/fern.nix` | Home Manager module for Fern Shell                  |
| `flake.nix`                          | `fern` input pointing to adanoelle/fern-shell       |
| `flake.parts/40-hosts.nix`           | Imports `fern-shell` and `fern-fonts` NixOS modules |
