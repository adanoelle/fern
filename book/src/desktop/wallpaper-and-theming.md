# Wallpaper & Theming

> Wallpapers are managed by swww with per-workspace images, fade transitions,
> and Hyprland keybindings for cycling.

The wallpaper module (`nix/home/desktop/hyprland/wallpaper.nix`) provides a
declarative way to assign wallpapers per monitor and per workspace, with smooth
transitions handled by swww.

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

## Transition types

swww supports these transition effects:

`simple`, `fade`, `left`, `right`, `top`, `bottom`, `wipe`, `wave`, `grow`,
`center`, `any`, `outer`, `random`

The default is `fade` at 1.2 seconds and 60fps.

## How it works

1. A systemd oneshot service (`swww-wallpaper`) starts swww and sets the initial
   wallpaper on login
2. If per-workspace wallpapers are configured, a Hyprland workspace listener
   detects workspace switches and calls `swww img` with the mapped image
3. Keybindings (`Super + W`, `Super + Shift + W`) cycle or randomize wallpapers

## Style options

The Hyprland module exposes style options that affect the overall desktop
appearance:

| Option           | Default | Description                      |
| ---------------- | ------- | -------------------------------- |
| `style.gapsIn`   | 6       | Inner gaps between windows (px)  |
| `style.gapsOut`  | 12      | Outer gaps from screen edge (px) |
| `style.border`   | 2       | Window border width (px)         |
| `style.rounding` | 5       | Corner rounding radius (px)      |

## Color scheme

The desktop uses the Catppuccin Frapp&eacute; palette throughout:

| Element                 | Color              | Hex              |
| ----------------------- | ------------------ | ---------------- |
| Active window border    | Mauve              | `#cba6f7`        |
| Inactive window border  | Base               | `#303446`        |
| Waybar background       | Base (translucent) | `#303446` at 80% |
| Lock screen input field | Base               | `#303446`        |
| Lock screen border      | Mauve              | `#ca9ee6`        |
| Lock screen text        | Text               | `#c6d0f5`        |

The same palette is used in Ghostty (`catppuccin-frappe`), Helix
(`catppuccin_frappe`), and delta (custom ada-theme based on Catppuccin Mocha).

## Key files

| File                                      | Purpose                                |
| ----------------------------------------- | -------------------------------------- |
| `nix/home/desktop/hyprland/wallpaper.nix` | swww wallpaper management module       |
| `nix/home/desktop/hyprland/core.nix`      | Style options (gaps, border, rounding) |
| `nix/home/desktop/hyprland/bar.nix`       | Waybar Catppuccin theme                |
| `nix/home/desktop/hyprland/idlelock.nix`  | Lock screen Catppuccin colors          |
| `nix/home/cli/ghostty.nix`                | Terminal Catppuccin theme              |
| `nix/home/cli/helix.nix`                  | Editor Catppuccin theme                |
