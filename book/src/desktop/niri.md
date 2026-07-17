# Niri

> Niri is the primary compositor: a scrollable-tiling Wayland compositor where
> windows live in columns on an infinite horizontal strip, paired with the
> garden shell (QuickShell) for the bar and overlays. Hyprland remains
> available as a [fallback session](hyprland.md).

The Niri configuration is a den aspect (`den.aspects.niri`) defined in
`modules/desktop/niri.nix`, with both a `nixos` side and a `homeManager` side.

## System side (nixos)

The `nixos` side enables the compositor and its supporting hardware/portal
plumbing:

- `programs.niri.enable = true` (option provided by
  [niri-flake](https://github.com/sodiboo/niri-flake))
- `hardware.i2c.enable = true` — DDC/CI brightness control of external
  monitors via `ddcutil`; the `users` aspect adds users to the `i2c` group
  when this is on
- System packages: `xwayland-satellite` (XWayland support) and `ddcutil`
- XDG portals: `xdg-desktop-portal-gnome` + `xdg-desktop-portal-gtk`

## Home Manager side

The `homeManager` side writes the full Niri config via
`programs.niri.settings`, themed with the garden-shell palette
(`inputs.garden-shell.lib.palette`).

### Named workspaces (channels)

Five named workspaces act as channels: **studio**, **research**, **writing**,
**music**, **system**. `Super+1-5` focuses them, `Super+Shift+1-5` moves the
focused window.

### Startup

`spawn-at-startup` launches:

- `xwayland-satellite` — X11 app support
- `qs -c garden` — the garden shell (QuickShell); the IPC binds below
  silently do nothing without it
- `kitty` (opens on *research*) and `kitty -e btop` (opens on *system*), via
  `at-startup` window rules

### Garden shell IPC binds

The garden shell overlays are driven over QuickShell IPC:

| Binding | Action |
|---------|--------|
| `Super+Slash` | `qs -c garden ipc call garden toggleLauncher` |
| `Super+Tab` | `qs -c garden ipc call garden toggleSwitcher` |
| `Super+Comma` | `qs -c garden ipc call garden toggleSettings` |

### Other notable binds

| Binding | Action |
|---------|--------|
| `Super+H/L`, `Super+J/K` | Focus column left/right, window down/up |
| `Super+Shift+H/L/J/K` | Move column/window |
| `Super+N` / `Super+B` | Spawn kitty / firefox |
| `Super+F` / `Super+A` | Maximize column / toggle overview |
| `Super+R`, `Super+Minus/Equal` | Preset / relative column widths |
| `Print` / `Super+Print` | Screenshot (to `~/media/screenshots/`) / window screenshot |
| `XF86MonBrightness*` | External monitor brightness via `ddcutil setvcp 10` |
| `XF86Audio*` | Volume via `wpctl` |

Window rules also float scratchpads (`garden`, `scratchpad-terminal`,
`lazygit`) and color-code borders for SSH host tiers (HPC/GPU/homelab) by
window title.

## The host-level import gotcha

The niri-flake NixOS module is imported **once at the host level**
(`modules/host-fern.nix`), not inside the aspect — importing it from an
aspect that gets included twice causes duplicate option declarations. For the
same reason:

- `den.aspects.niri` is deliberately **not** in the `desktop-apps` bundle or
  the workstation role. Its `homeManager` side sets `programs.niri.*` options
  that only exist for users on hosts that import the niri-flake module.
- Hosts opt in by including `den.aspects.niri` alongside the module import,
  and it reaches users via the host's `provides.to-users` machinery.
- A new host that wants Niri needs both the import and the include (see the
  troubleshooting note in CLAUDE.md).

## Key files

| File | Purpose |
|------|---------|
| `modules/desktop/niri.nix` | The niri aspect (nixos + homeManager sides) |
| `modules/host-fern.nix` | niri-flake module import + aspect include |
| `modules/desktop/greetd.nix` | Login sessions (Niri primary, Hyprland fallback) |
| `modules/users.nix` | `i2c` group membership when `hardware.i2c` is enabled |
