# Garden

> Garden is the palette and desktop shell this configuration consumes:
> one set of colours shared by the terminal stack, the editor, git
> tooling and the compositor, plus a QuickShell-based shell (bar,
> launcher, notifications, power menu, lock screen). It lives in its own
> repository, [adanoelle/garden-shell](https://github.com/adanoelle/garden-shell),
> and arrives as the `garden-shell` flake input. This page covers only
> how fern uses it.

**Goes on:** `garden.terminal` on fern, yarrow and the work laptop;
`garden.shell` (the QML shell and its helpers) on the work laptop only.

## The namespace

garden-shell exposes den aspects. `modules/garden.nix` mounts them as
the `garden` namespace, so any module can take `garden` as an argument
and include `garden.terminal` or `garden.shell` like a local aspect
(see [Aspects](../architecture/aspects.md) for the vocabulary).

| Aspect | Included from | Brings |
| ------ | ------------- | ------ |
| `garden.terminal` | `modules/user-ada-desktop.nix` | the themed terminal stack; pulls in `garden.palette` and `garden.toolkit` (the `garden-themes` binary) |
| `garden.shell` | `modules/host-yarrow.nix`, `modules/user-ada-work.nix` | everything above, plus the QML shell deployed to `~/.config/quickshell/garden`, its settings file and the screenshot tools it calls |

`garden.terminal` is deliberately not in the base user layer
(`modules/user-ada.nix`): yarrow and the work laptop already receive it
through `garden.shell`, and including it twice duplicates the kitty
include. For the same reason yarrow forwards `desktop-apps` and
`garden.shell` rather than `ada-desktop`. A
headless host that wants the themed terminal has to include it
explicitly.

On fern nothing in this flake includes `garden.shell`. The niri aspect
still installs `quickshell` and starts `qs -c garden`, so on fern the
shell's QML has to be present in
`~/.config/quickshell/garden` by some other means; without it the bar
and overlays do not appear.

## Build-time palette

garden-shell exports the colours of the palette marked active in its
`palettes.toml`, at the revision pinned in `flake.lock`:

```nix
palette = inputs.garden-shell.lib.palette.colors;
```

These consumers bake those colours into generated configuration, by
semantic name (`accent`, `urgent`, `ok`, `border`, `text-1` …) rather
than hex:

| Consumer | File |
| -------- | ---- |
| niri window borders, including the host-tier rules | `modules/desktop/niri.nix` |
| fish prompt | `modules/shells/fish.nix` |
| delta | `modules/cli/delta.nix` |
| lazygit base theme | `modules/cli/lazygit.nix` |

They change only on a rebuild, and only when the locked garden-shell
revision changes its active palette. Switching palette at run time does
not touch them.

## Run-time theming

Everything else follows the palette chosen at run time. `garden-themes`
generates one theme file per tool under `~/.config/garden/themes/`, and
each tool reads its file from that mutable directory:

| Tool | How it picks the theme up | Wired in |
| ---- | ------------------------- | -------- |
| kitty | `include` of the generated colours, plus a `globinclude` of the font chosen in the shell's settings | garden-shell |
| fish, fzf | sourced at interactive shell start | garden-shell |
| bat, btop, yazi | symlinked into each tool's theme directory at shell start | garden-shell |
| kakoune, zathura | sourced / included from the tool's config | garden-shell |
| lazygit | overlay file appended through `LG_CONFIG_FILE` | garden-shell |
| helix | `theme = "garden"`, an out-of-store link to the generated file | `modules/cli/helix.nix` |
| ghostty | optional `config-file` includes for colours and font | `modules/cli/ghostty.nix` |
| Obsidian (work laptop) | CSS snippet linked into the notes vault | `modules/desktop/obsidian.nix` |

Two behaviours are worth knowing:

- **First activation seeds the files.** `garden.palette` copies
  `palettes.toml` to `~/.config/garden/` once, as a plain file, and on
  later activations only adds built-in palettes that are new.
  `garden.terminal` then runs `garden-themes apply` if no theme files
  exist yet. Neither step overwrites a palette choice made at run time,
  which is why `palettes.toml` must never become a Home Manager symlink.
- **Switching** is `garden-themes apply --name <palette>`, or the
  shell's settings overlay (`Mod+Comma`). The available palettes are
  those in the locked revision's `_config/palettes.toml`; they are
  described in garden-shell's own
  [book](https://github.com/adanoelle/garden-shell/tree/main/book/src/palette).

On machines that carry the [wallpaper](wallpaper.md) aspect, the
painting on the wall follows the palette as well.

## The shell

`modules/desktop/niri.nix` starts the shell with the session
(`qs -c garden`) and binds keys to its IPC calls: launcher, switcher,
settings, notifications, power menu, lock and screenshots. The one bind
table is in [Niri](niri.md#keybinds). Idle and before-sleep locking go
through the same `lock` call.

Fonts are installed by `den.aspects.fonts` (`modules/fonts.nix`): M PLUS
1 as the default sans-serif and serif, IBM Plex Mono as the default
monospace.

## Key files

| File | Purpose |
| ---- | ------- |
| `modules/garden.nix` | mounts the `garden` namespace |
| `modules/user-ada-desktop.nix` | includes `garden.terminal` (fern, yarrow) |
| `modules/host-yarrow.nix`, `modules/user-ada-work.nix` | include `garden.shell` (yarrow, work laptop) |
| `modules/desktop/niri.nix` | shell startup, IPC binds, palette borders |
| `modules/fonts.nix` | font packages and fontconfig defaults |

How the shell is built, the palette design and the design documents
live in the [garden-shell](https://github.com/adanoelle/garden-shell)
repository, not here.
