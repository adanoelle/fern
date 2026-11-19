# Niri

> Niri is the compositor on every graphical machine: a scrollable-tiling
> Wayland compositor where windows sit in columns on a horizontal strip.
> One aspect, `den.aspects.niri`, holds the shared settings (named
> workspaces, binds, window rules, idle lock); small per-machine aspects
> add brightness keys and laptop suspend. The bar, overlays and lock
> screen are the [garden shell](garden.md), driven from niri binds.

**Goes on:** fern, yarrow, and the work laptop (through
`niri-standalone`).

## System side and the host-level import

The aspect's `nixos` side enables `programs.niri`, turns on upower (the
shell's battery indicator reads it), installs `xwayland-satellite` and
`quickshell`, and adds the GNOME and GTK desktop portals.

`programs.niri.*` options come from
[niri-flake](https://github.com/sodiboo/niri-flake), and its NixOS
module must be imported exactly once per host. An aspect can be
included more than once, so the import lives in the host aspect
instead:

- `modules/host-fern.nix` and `modules/host-yarrow.nix` each import
  `inputs.niri.nixosModules.niri`, include `den.aspects.niri`, forward
  it to their users through `provides.to-users.includes`, and set
  `programs.niri.package = pkgs.niri` (the nixpkgs build).
- For that reason niri is in neither the `workstation` role nor the
  `desktop-apps` bundle. A new host that wants niri needs the import
  and the include; see [Adding a host](../operations/adding-a-host.md).
- A standalone home has no NixOS module to bridge the options.
  `modules/desktop/niri-standalone.nix` imports niri-flake's Home
  Manager module directly and includes the same `den.aspects.niri`, so
  the work laptop gets identical settings.

## Workspaces and startup

Five named workspaces act as channels: `studio`, `research`, `writing`,
`music`, `system`. Binds and window rules refer to them by name.

At startup niri spawns `xwayland-satellite`, the garden shell
(`qs -c garden`), a kitty (placed on `research` by a window rule) and
`kitty -e btop` (placed on `system`).

## Layout

Gaps of 2 px, a 1 px border in the palette's `border` /
`border-sub` colours, no focus ring. New columns take half the output;
`Mod+R` cycles 50 %, 75 % and 100 %. The view centres the focused
column only when it would otherwise overflow. Client-side decorations
are declined, focus follows the mouse, and the touchpad uses tap,
natural scroll and clickfinger.

## Keybinds

`Mod` is Super. All binds are in `modules/desktop/niri.nix` unless a
row says otherwise.

| Bind | Action |
| ---- | ------ |
| `Mod+1` … `Mod+5` | focus channel studio / research / writing / music / system |
| `Mod+Shift+1` … `Mod+Shift+5` | move the window to that channel |
| `Mod+Shift+Tab` | focus the workspace above |
| `Mod+H` / `Mod+L` | focus column left / right |
| `Mod+J` / `Mod+K` | focus window down / up |
| `Mod+Shift+H` / `L` | move column left / right |
| `Mod+Shift+J` / `K` | move window down / up |
| `Mod+WheelScrollUp` / `Down` | focus column left / right |
| `Mod+BracketLeft` / `BracketRight` | consume or expel the window left / right |
| `Mod+N` | spawn `kitty` |
| `Mod+B` | spawn `zen-twilight` |
| `Mod+Shift+Q` | close window |
| `Mod+F` | maximize column |
| `Mod+Shift+F` | fullscreen window |
| `Mod+A` | toggle overview |
| `Mod+R` | cycle preset column widths |
| `Mod+Minus` / `Mod+Equal` | column width −10 % / +10 % |
| `Mod+V` | toggle floating |
| `XF86AudioRaiseVolume` / `LowerVolume` / `Mute` | `wpctl` on the default sink, ±5 %, capped at 100 % |
| `XF86MonBrightnessUp` / `Down` | per machine, see [below](#per-machine) |
| `Mod+Shift+E` | quit niri |
| `Mod+Shift+Slash` | niri's hotkey overlay |

These call the garden shell over QuickShell IPC
(`qs -c garden ipc call garden <call>`). They do nothing when the shell
is not running.

| Bind | IPC call | Surface |
| ---- | -------- | ------- |
| `Mod+Slash` | `toggleLauncher` | launcher |
| `Mod+Tab` | `toggleSwitcher` | switcher |
| `Mod+Comma` | `toggleSettings` | settings, including the palette picker |
| `Mod+Shift+N` | `toggleNotifications` | notification popups |
| `Mod+Shift+M` | `toggleNotificationCenter` | notification centre |
| `Mod+Escape` | `togglePowerMenu` | power menu |
| `Mod+Alt+L` | `lock` | lock screen |
| `Mod+S` | `screenshot region` | screenshot of a region |
| `Mod+Shift+S` | `screenshot window` | screenshot of a window |
| `Mod+Ctrl+S` | `screenshot output` | screenshot of an output |

Machines with the [wallpaper](wallpaper.md) aspect add `Mod+G`,
`Mod+Shift+G` and `Mod+Ctrl+G`.

## Window rules

- Startup placement: the two startup kitty windows go to `research`
  and `system`; Zen opens on `research` (the rule is in
  `modules/desktop/zen.nix`).
- Floating: app-id `garden`, title `scratchpad-terminal`, app-id
  `lazygit`.
- Full width: LibreOffice and Teams.
- Terminal windows are colour-coded by remote host tier: a window whose
  title matches a known host name gets an `urgent`, `accent` or `ok`
  border from the palette.

## Idle lock

Locking belongs to the garden shell. The aspect enables `swayidle`,
which calls the shell's `lock` IPC after 600 seconds idle and again on
`before-sleep`, so the session is locked before the machine suspends.
`Mod+Alt+L` makes the same call.

## Screenshots

The `Mod+S` family hands off to the shell, which saves the image,
copies it to the clipboard and shows a notification card. The shell
calls `grim`, `slurp`, `satty` and `wl-clipboard`; `garden.shell`
installs them, which covers yarrow and the work laptop. fern does not
take `garden.shell`, so it forwards the `screenshot` aspect
(`modules/desktop/screenshot.nix`), which installs the same four tools
and writes satty's annotation defaults to `~/.config/satty/config.toml`.
A host forwards one or the other, never both.

`screenshot-path` is set to `~/media/screenshots/` for niri's built-in
screenshot actions; the shell's window mode depends on it.

## Greeter

`den.aspects.greetd` (`modules/desktop/greetd.nix`, part of the
`workstation` role) runs greetd with tuigreet, a text-mode greeter. It
enables no compositor itself: it offers the Niri session when the host
has set `programs.niri.enable`, as fern and yarrow do. The work laptop
does not use greetd.

## Pointer

The `cursor` aspect (`modules/desktop/cursor.nix`) installs a pointer
theme drawn for this configuration: a chrome key with a red bow and a
heart charm.

**Goes on:** the [work laptop](../machines/work-laptop.md) and
[yarrow](../machines/yarrow.md).

- The art is two vector drawings in `modules/desktop/_cursor/`. The
  build renders them at 24, 32, 48, 64 and 96 px; the two smallest
  sizes use a plainer key without the charm.
- Only the arrow is drawn. Every other shape comes from Adwaita.
- The size defaults to 48 and can be set per machine with
  `home.pointerCursor.size`.
- niri re-reads the pointer theme only when its cursor settings
  change. `cursor-reload` makes a running session pick the theme up
  again; a switch runs it whenever the theme has changed.

## Per machine

| Machine | Additions |
| ------- | --------- |
| fern | `brightness-ddc`: brightness keys show the shell's OSD, then set the external monitors over DDC/CI with `ddcutil`. Its system side enables `hardware.i2c`. |
| yarrow | `brightness-backlight`: brightness keys call `brightnessctl` on the panel backlight (never below 1 %); the shell shows its OSD by watching sysfs. `idle-suspend`: a second swayidle timeout suspends after 1200 seconds idle, only when no mains supply is online. |
| work laptop | see below |

The work laptop reuses the shared aspect and overrides it in its own
layer: a longer channel table with applications pinned to channels and
started on first visit, a fixed output arrangement for its dock, its
own brightness keys, a `Mod+B` that goes to the browser channel, and
both the lock bind and swayidle turned off. The session is started from
the distribution's display manager. Details are in
[Work laptop](../machines/work-laptop.md).

## Key files

| File | Purpose |
| ---- | ------- |
| `modules/desktop/niri.nix` | the shared aspect: system side, settings, binds, swayidle |
| `modules/desktop/niri-standalone.nix` | the same settings for a standalone home |
| `modules/host-fern.nix`, `modules/host-yarrow.nix` | niri-flake import, include, forwarding, package |
| `modules/desktop/brightness-ddc.nix` | DDC/CI brightness keys |
| `modules/desktop/brightness-backlight.nix` | backlight brightness keys |
| `modules/desktop/idle-suspend.nix` | suspend when idle on battery |
| `modules/desktop/greetd.nix` | greeter and session list |
| `modules/desktop/screenshot.nix` | capture tools for hosts without `garden.shell` |
