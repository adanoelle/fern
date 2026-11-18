# Hyprland (fallback session)

> Hyprland is kept on fern as a second session to log into if niri or
> the garden shell is broken. It is not themed by garden and shares
> nothing with the niri session beyond the applications.

**Goes on:** fern only. `modules/host-fern.nix` sets
`programs.hyprland.enable` and forwards `ada-hyprland` to its users.

To use it, choose "Hyprland" from the session list in the
[greeter](niri.md#greeter); it is listed after Niri.

## What is configured

`den.aspects.hyprland` (`modules/desktop/hyprland.nix`) declares a
`desktop.hyprland` option tree and the Home Manager configuration
behind it. `modules/user-ada-hyprland.nix` enables it, with idle, lock
and wallpaper on. Dwindle layout, gaps 6 / 12, a 2 px border, rounding
5, blur on; the colours are a fixed set in the module, not the garden
palette. It installs `wofi`, `ghostty`, `firefox` and `wl-clipboard`.

## Binds

`SUPER` is the modifier.

| Bind | Action | Defined in |
| ---- | ------ | ---------- |
| `SUPER+Return` | `ghostty` | `hyprland.nix` |
| `SUPER+Q` | close window | `hyprland.nix` |
| `SUPER+R` | `wofi --show drun` | `hyprland.nix` |
| `SUPER+SHIFT+R` | `hyprctl reload` | `hyprland.nix` |
| `SUPER+H/J/K/L` | move focus | `hyprland.nix` |
| `SUPER+1…9`, `SUPER+SHIFT+1…9` | go to / move window to workspace | `hyprland.nix` |
| `SUPER`+right mouse drag | resize window | `hyprland.nix` |
| `SUPER+W` | re-apply the configured wallpaper | `_hyprland/wallpaper.nix` |
| `SUPER+SHIFT+W` | random image from `~/media/wallpapers` | `_hyprland/wallpaper.nix` |
| `SUPER+S` | region screenshot, annotate in satty | `screenshot.nix` |
| `SUPER+SHIFT+S` | full screenshot, annotate in satty | `screenshot.nix` |
| `SUPER+ALT+S` | region to clipboard | `screenshot.nix` |
| `SUPER+CTRL+S` | full screenshot to `~/media/screenshots` | `screenshot.nix` |

The keyboard binds defined in `hyprland.nix` are written to the
generated `hyprland.conf` with the keyword twice (`bind=bind = SUPER,
…`). The wallpaper, screenshot and mouse binds are written correctly.

## Wallpaper

`_hyprland/wallpaper.nix` starts the `awww` daemon and a one-shot user
service that sets `~/media/wallpapers/shrine.png` with a 1.2 second
fade. The service targets the output named by
`desktop.hyprland.wallpaper.monitor`, which is left at its default,
`eDP-1`. Per-monitor and per-workspace wallpapers are supported by the
module but not configured.

## Idle and lock

`_hyprland/idlelock.nix` runs `hypridle` with three steps: dim with
`brightnessctl` at 300 seconds, `hyprlock` at 600, `systemctl suspend`
at 1200. `brightnessctl` and `hyprlock` are called by name and neither
is installed on fern, so only the suspend step takes effect. A
`hyprlock.conf` is written all the same.

The niri aspect's swayidle service is tied to the graphical session,
not to niri, so it runs here too; its lock call goes to the garden
shell, which this session does not start.

## Key files

| File | Purpose |
| ---- | ------- |
| `modules/desktop/hyprland.nix` | options, look, core binds |
| `modules/desktop/_hyprland/wallpaper.nix` | awww daemon, wallpaper service and binds |
| `modules/desktop/_hyprland/idlelock.nix` | hypridle service, hyprlock config |
| `modules/user-ada-hyprland.nix` | the settings fern uses |
| `modules/desktop/screenshot.nix` | screenshot scripts and binds |
