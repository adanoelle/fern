# Niri

> Niri is the primary compositor. Windows live in columns on an infinite
> horizontal strip — new windows never resize existing ones, they extend the
> strip. Paired with the [garden shell](garden.md) for bar, overlays, and
> lock, it forms the whole desktop. Hyprland is retained only as a
> [fallback session](hyprland.md).

## Why scrollable tiling, why channels

Classic tiling forces a zero-sum fight over screen area: every new window
shrinks the others. Niri's scrollable strip removes that pressure — a column
takes the width it wants (half, three-quarters, full) and the strip simply
grows. This suits a workflow of a few focused columns per activity rather
than a mosaic of tiny tiles.

Activities map to five **named workspaces used as channels** — *studio*,
*research*, *writing*, *music*, *system* — instead of anonymous numbers.
`Super+1-5` focuses a channel, `Super+Shift+1-5` moves the focused window to
one. Naming makes window rules stable (`open-on-workspace = "research"`) and
keeps muscle memory tied to intent, not position.

The configuration is a den aspect (`den.aspects.niri`,
`modules/desktop/niri.nix`) with both a `nixos` and a `homeManager` side.

## System side (nixos)

- `programs.niri.enable = true` — option provided by
  [niri-flake](https://github.com/sodiboo/niri-flake); the package is pinned
  to nixpkgs' `niri` in `host-fern.nix` (avoids a niri-flake fetchGit
  evaluation issue).
- `hardware.i2c.enable = true` — DDC/CI brightness control of external
  monitors via `ddcutil`; the `users` aspect adds users to the `i2c` group
  when this is on.
- `services.upower.enable` — battery/power state on D-Bus for the garden bar.
- System packages: `xwayland-satellite` (XWayland), `ddcutil`, and
  `quickshell` — quickshell lives here (not in greetd) because the garden
  shell and its IPC binds belong to the niri session.
- XDG portals: `xdg-desktop-portal-gnome` + `xdg-desktop-portal-gtk`.

### The host-level import gotcha

The niri-flake NixOS module is imported **once at the host level**
(`modules/host-fern.nix`), not inside the aspect — an upstream module
imported from an aspect that gets included twice causes duplicate option
declarations. Consequences:

- `den.aspects.niri` is deliberately **not** in the `desktop-apps` bundle or
  the workstation role; its `homeManager` side sets `programs.niri.*`
  options that only exist on hosts importing the niri-flake module.
- Hosts opt in by importing the module *and* including the aspect; users get
  it via the host's `provides.to-users` forwarding.
- A new host that wants Niri needs both (see the troubleshooting note in
  CLAUDE.md).

## Session startup

`spawn-at-startup` launches:

- `xwayland-satellite` — X11 app support
- `qs -c garden` — the **garden shell**; the IPC keybinds silently do
  nothing without it (see [The Garden Design System](garden.md))
- `kitty` (opens on *research*) and `kitty -e btop` (opens on *system*), via
  `at-startup` window rules

## Layout & keybinds

Layout: 2px gaps, 1px borders in garden palette colors
(`inputs.garden-shell.lib.palette.colors`), focus ring off, preset column
widths of 50/75/100%, spring animations for workspace and view movement.

| Binding | Action |
|---------|--------|
| `Super+H/L`, `Super+J/K` | Focus column left/right, window down/up |
| `Super+Shift+H/L/J/K` | Move column/window |
| `Super+WheelScroll` | Focus column left/right (25ms cooldown) |
| `Super+N` / `Super+B` | Spawn kitty / firefox |
| `Super+Shift+Q` | Close window |
| `Super+F` / `Super+A` | Maximize column / toggle overview |
| `Super+R`, `Super+Minus/Equal` | Preset / relative column widths |
| `Super+V` | Toggle floating |
| `Super+BracketLeft/Right` | Consume/expel window (tabbed columns) |
| `Super+S` / `+Shift` / `+Ctrl` | Garden screenshot: region / window / output |
| `XF86Audio*` | Volume via `wpctl` |
| `XF86MonBrightness*` | Garden OSD, then `ddcutil setvcp 10` (DDC/CI) |

Screenshots land in `~/media/screenshots/` — `screenshot-path` is set
explicitly because garden's window-mode screenshot
(`niri msg action screenshot-window`) depends on it; the default would
resurrect `~/Pictures/Screenshots`.

The launcher, switcher, settings, notifications, power menu, and lock binds
all drive the garden shell over QuickShell IPC — the full table is in
[Garden § The shell](garden.md#the-shell-quickshell).

## Window rules

- **Scratchpads float**: `garden` app-id, `scratchpad-terminal` title,
  `lazygit` app-id.
- **SSH host-tier borders**: terminal windows are color-coded by title so a
  remote shell is identifiable at a glance — HPC hosts (*frontier*, *andes*,
  *summit*) get the urgent red border, `dgx-*` GPU boxes get accent gold,
  *homelab* gets ok green. Colors come from the garden palette, so tiers
  stay consistent with the rest of the system.

## Idle & Lock

Locking is delegated to the garden shell rather than a standalone locker —
one lock implementation (WlSessionLock + PAM, in garden-shell) serves the
keybind, the idle timeout, and suspend:

- niri implements `ext-idle-notify-v1`; **swayidle** listens and, after
  **600s** idle, calls `qs -c garden ipc call garden lock`.
- swayidle's `before-sleep` event fires the same lock call while holding a
  logind inhibitor, so the screen is locked *before* the machine suspends —
  no unlocked-frame flash on resume.
- Manual lock is `Super+Alt+L` (same IPC call).

The old Hyprland-era hypridle/hyprlock setup survives only for the fallback
session — see [Idle & Lock (Hyprland)](idle-and-lock.md).

## Hyprland fallback

Hyprland remains installed as a secondary greetd session for regression
testing and as a safety net — see [Hyprland (Legacy Fallback)](hyprland.md).

## Key files

| File | Purpose |
|------|---------|
| `modules/desktop/niri.nix` | The niri aspect (nixos + homeManager sides) |
| `modules/host-fern.nix` | niri-flake module import + aspect include + package pin |
| `modules/desktop/greetd.nix` | Login sessions (Niri primary, Hyprland fallback) |
| `modules/users.nix` | `i2c` group membership when `hardware.i2c` is enabled |
