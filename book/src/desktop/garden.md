# The Garden Design System

> Garden is the design system and desktop shell that fern *consumes*: one
> palette, one typography set, and one QuickShell-based shell (bar, launcher,
> notifications, power menu, lock screen) shared by every themed surface.
> It lives in its own repository —
> [adanoelle/garden-shell](https://github.com/adanoelle/garden-shell) — and
> this chapter documents the **integration**, not the internals.

## Why one design system

Before garden, theming was a patchwork: Catppuccin here, a hand-picked hex
there, each tool themed independently and drifting independently. Changing the
look meant hunting through a dozen modules. Garden centralizes this: the
palette is defined **once** in garden-shell and every consumer — terminal,
editor, git tooling, compositor borders, the shell itself — derives from it.
A palette change is one decision, applied everywhere.

## The den namespace

Garden-shell is itself a dendritic flake exposing den aspects under a
`garden.*` namespace. Fern mounts it in `modules/garden.nix`:

```nix
{ inputs, ... }:
{
  imports = [
    (inputs.den.namespace "garden" [ inputs.garden-shell ])
  ];
}
```

After this, fern modules take `garden` as an argument and include garden
aspects like any local aspect. The base user layer (`modules/user-ada.nix`)
includes `garden.terminal`, which pulls in `garden.palette` and
`garden.toolkit` (the `garden-themes` binary). Because it is in the **base**
layer, every host — even a future headless server — gets a garden-themed
terminal.

## Build-time palette

Garden-shell exports the palette as a Nix attribute set:

```nix
palette = inputs.garden-shell.lib.palette.colors;
```

Fern modules use it wherever colors are baked into generated config:

| Consumer | File | What it themes |
|----------|------|----------------|
| Fish prompt | `modules/shells/fish.nix` | Two-line ✧ prompt colors |
| Delta | `modules/cli/delta.nix` | Diff colors + garden tmTheme syntax |
| LazyGit | `modules/cli/lazygit.nix` | Border/selection theme overlay |
| Niri | `modules/desktop/niri.nix` | Window borders, SSH host-tier border colors |

These are **build-time**: changing them requires a rebuild. They use the
palette's semantic names (`accent`, `urgent`, `ok`, `border`, `text-1..4`,
`base-hl`), not raw hex.

## Run-time theming

The rest of the terminal stack is themed at **run time** so the palette can be
switched live, without a rebuild. `garden.terminal` seeds
`~/.config/garden/themes/` on first Home Manager activation (guarded on a
manifest file so a later rebuild never clobbers your palette choice), and
tools read from that mutable directory:

- **kitty** — `include ../garden/themes/kitty/garden-theme.conf`; reloads on
  SIGUSR1, so all instances re-color instantly
- **fish** syntax colors, **fzf** colors — sourced in `interactiveShellInit`
- **bat** — symlinked tmTheme + cache rebuild when the theme changes
- **btop**, **yazi**, **kakoune**, **zathura** — symlinked/sourced theme files
- **lazygit** — garden overlay merged via `LG_CONFIG_FILE`

Switching palettes is `garden-themes apply --name <palette>` (or the shell's
settings overlay). Eight palettes ship in `palettes.toml`:

`sumi` · `mokume` · `fuji` · `sugi` · `yoru` · `tsuchi` · `kinu` · `ishi`

The active choice is written back into the mutable
`~/.config/garden/palettes.toml` — deliberately **not** a Home
Manager-managed symlink, so runtime selection survives `just switch`.

## The shell (QuickShell)

The garden shell runs as `qs -c garden` inside the Niri session (spawned at
startup by `modules/desktop/niri.nix`). Niri keybinds drive it over
QuickShell IPC — without the shell running, these binds silently do nothing:

| Binding | IPC call | Surface |
|---------|----------|---------|
| `Super+Slash` | `toggleLauncher` | App launcher |
| `Super+Tab` | `toggleSwitcher` | Window switcher |
| `Super+Comma` | `toggleSettings` | Settings (incl. palette picker) |
| `Super+Shift+N` | `toggleNotifications` | Notification popups |
| `Super+Shift+M` | `toggleNotificationCenter` | Notification center |
| `Super+Escape` | `togglePowerMenu` | Power menu |
| `Super+Alt+L` | `lock` | Session lock (WlSessionLock + PAM) |
| `Super+S` / `+Shift` / `+Ctrl` | `screenshot region/window/output` | Screenshot flow (save + copy + card) |
| `XF86MonBrightness*` | `stepBrightnessOsd` | Brightness OSD (then `ddcutil`) |

Idle and suspend locking also route through the shell's `lock` IPC — see
[Niri § Idle & Lock](niri.md#idle--lock).

## Boundary

Fern documents **what it consumes**: the namespace mount, the palette
contract, the themes directory, and the IPC surface. How the shell is built —
QML components, the Rust `garden-core`/`garden-themes` crates, palette
design — is documented in the
[garden-shell repository](https://github.com/adanoelle/garden-shell) itself.
If a question is about the shell's internals, the answer lives there.

## Key files

| File | Purpose |
|------|---------|
| `modules/garden.nix` | Mounts the `garden.*` den namespace |
| `modules/user-ada.nix` | `garden.terminal` in the base user layer |
| `modules/desktop/niri.nix` | Shell startup + IPC keybinds + palette borders |
| `modules/fonts.nix` | Garden typography (M PLUS 1p, IBM Plex Mono) |
