# Wallpaper (Hyprland)

> **Legacy.** This wallpaper machinery belongs to the
> [Hyprland fallback session](hyprland.md). System-wide theming is no longer
> Catppuccin-per-tool — it is the garden design system; see
> [The Garden Design System](garden.md).

The wallpaper module (`modules/desktop/_hyprland/wallpaper.nix`) provides a
declarative way to assign wallpapers per monitor and per workspace, with
smooth transitions handled by **awww** (an animated-wallpaper daemon in the
swww lineage).

## Wallpaper configuration

The host configuration sets wallpapers in `desktop.hyprland.wallpaper`:

```nix
wallpaper = {
  enable = true;
  path = "/home/ada/wallpapers/shrine.png";   # fallback
  monitor = "HDMI-A-1";

  # Per-monitor wallpapers
  monitors = {
    "HDMI-A-1" = "/home/ada/wallpapers/shrine.png";
  };

  # Per-workspace wallpapers (change on workspace switch)
  workspaces = {
    "1" = "/home/ada/wallpapers/totoro_house.png";
    "2" = "/home/ada/wallpapers/howl_castle.png";
    "3" = "/home/ada/wallpapers/kiki.png";
    "4" = "/home/ada/wallpapers/nausicaa.png";
    "5" = "/home/ada/wallpapers/wind_rises_plane.png";
  };

  transition = {
    type = "fade";
    duration = 1.2;
    fps = 60;
  };
};
```

Transitions are passed to `awww img` as `--transition-type`,
`--transition-duration`, and `--transition-fps`; the default is `fade` at
1.2 seconds and 60fps.

## How it works

1. `awww-daemon` is started via Hyprland `exec-once`, and a systemd oneshot
   user service (`awww-wallpaper`) waits for the daemon (30s timeout) and
   sets the initial wallpaper(s) on login
2. If per-workspace wallpapers are configured, a listener service
   (`awww-workspace-listener`) watches Hyprland's socket for workspace
   switches and calls `awww img` with the mapped image
3. Keybindings (`Super + W`, `Super + Shift + W`) cycle the current
   workspace's wallpaper or pick a random image from the wallpaper directory

## Style options

The Hyprland module exposes style options that affect the fallback session's
appearance:

| Option           | Default | Description                      |
| ---------------- | ------- | -------------------------------- |
| `style.gapsIn`   | 6       | Inner gaps between windows (px)  |
| `style.gapsOut`  | 12      | Outer gaps from screen edge (px) |
| `style.border`   | 2       | Window border width (px)         |
| `style.rounding` | 5       | Corner rounding radius (px)      |

## Theming

The Catppuccin values baked into the Hyprland stack (borders, Waybar,
hyprlock) are frozen with the fallback session. Everywhere else — terminal,
editor, git tooling, Niri borders, the shell — colors come from the garden
palette, with live palette switching at run time. See
[The Garden Design System](garden.md).

## Key files

| File                                       | Purpose                                |
| ------------------------------------------ | -------------------------------------- |
| `modules/desktop/_hyprland/wallpaper.nix`  | awww wallpaper management module       |
| `modules/desktop/hyprland.nix`             | Style options (gaps, border, rounding) |
| `modules/desktop/_hyprland/bar.nix`        | Waybar theme (fallback session)        |
| `modules/desktop/_hyprland/idlelock.nix`   | Lock screen colors (fallback session)  |
