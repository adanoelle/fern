# Terminals and CLI tools

> Kitty is the everyday terminal: the Niri session opens it, it starts
> fish, and its colours follow the garden palette at run time. Ghostty is
> installed alongside it with its own keybindings; it is the default
> window for presentations.
> Both come from the `cli` bundle, which also installs the editors and
> command-line tools listed at the end of this page.

**Goes on:** every host (the `cli` bundle is part of the base user
layer, `modules/user-ada.nix`). Garden colours need the garden terminal
layer, which graphical hosts and the work laptop include; see
[Garden](../desktop/garden.md).

## Kitty

`modules/cli/kitty.nix`. Niri binds `Mod+N` to `kitty` and starts one at
login ([Niri](../desktop/niri.md)).

| Setting | Value | Why |
|---|---|---|
| font | IBM Plex Mono, 11 pt, cell height 120% | |
| `shell` | the fish binary from the store | fish even where the login shell is not fish (work laptop) |
| `hide_window_decorations` | yes | the compositor draws borders |
| `window_padding_width` | `12 16 12 16` | |
| `allow_remote_control` | yes | lets `kitty @ set-colors` restyle a running window |
| `cursor_shape` | beam | |
| `copy_on_select` | clipboard | |
| `confirm_os_window_close` | 0 | no close prompt |
| `enable_audio_bell` | no | |

No colours are set in this module. The palette, and the mono face when
one is chosen in the garden settings, are included from mutable files
that the garden tooling writes; that mechanism is described in
[Garden](../desktop/garden.md).

The module also forces `TERMINFO_DIRS` to the kitty and Ghostty terminfo
directories together, so programs find either terminal's entry.

## Ghostty

`modules/cli/ghostty.nix`. It is what [`present`](presenterm.md) opens
by default.

| Setting | Value |
|---|---|
| `font-family` | FiraCode Nerd Font |
| `font-size` | 11 |
| `config-file` | `?~/.config/garden/themes/ghostty/garden-theme`, `?~/.config/garden/fonts/ghostty` |

The two includes are optional (`?`). The first is the active garden
palette; no `theme` is set, so without that file Ghostty uses its
built-in colours. The second is the garden mono face; it is loaded after
the main file, so when present it overrides `font-family` above. Ghostty
reloads both on `SIGUSR2`.

No shell is set, so Ghostty runs the account's login shell.

| Keys | Action |
|---|---|
| `Alt+T` / `Alt+W` | new tab / close tab |
| `Alt+1` … `Alt+5` | go to tab |
| `Alt+Shift+V` / `Alt+Shift+S` | split right / split down |
| `Alt+H/J/K/L` | move between splits |
| `Ctrl+Alt+H/J/K/L` | resize split by 10 |
| `Shift+PageUp` / `Shift+PageDown` | scroll a page |
| `Ctrl+=` / `Ctrl+-` / `Ctrl+0` | font size up / down / reset |
| `Ctrl+Shift+C` / `Ctrl+Shift+V` | copy / paste |
| `Shift+Enter` | insert a literal newline |

## One key vocabulary

The multiplexers are bound to line up with the terminals and the
compositor:

| Layer | Move | Split right / down |
|---|---|---|
| Niri | `Super` + `h/j/k/l` | |
| Ghostty | `Alt` + `h/j/k/l` | `Alt+Shift+V` / `Alt+Shift+S` |
| tmux | `Ctrl-Space`, then `h/j/k/l` | prefix `v` / `s` |
| herdr | `Super+Space`, then `h/j/k/l` | prefix `v` / `s` |
| fish | vi mode | |

## Tools in the `cli` bundle

`modules/cli/bundle.nix` lists them; each is one file in `modules/cli/`.
"Package only" means the aspect installs the program and nothing else.

| Aspect | What is configured |
|---|---|
| `helix` | Default editor (`EDITOR=hx`). `garden` theme linked from the mutable garden themes directory, relative line numbers, mouse off, auto-save, `Space Space` file picker, `Space w` / `Space q`. Markdown is formatted on save with prettier at 80 columns; Rust auto-format is off. |
| `kakoune` | Second editor with `kak-lsp`. Garden colours, relative numbers, word wrap, Wayland clipboard on yank, 2-space indent. LSP is enabled for nix, rust, python, typescript and javascript and expects the servers on `PATH`. |
| `tmux` | Prefix `Ctrl-Space`, vi keys, mouse, 50000 lines of history, windows and panes numbered from 1. `v`/`s` split in the current directory, `h/j/k/l` move, `H/J/K/L` resize, `n` new window, `w` close pane (confirm), `S` session chooser. |
| `herdr` | See [Agent sessions](agent-sessions.md). |
| `claude-code` | See [Agent sessions](agent-sessions.md). |
| `presenterm` | See [Presenting](presenterm.md). |
| `yazi` | File manager. Fish integration with the wrapper named `yy`; natural sort, directories first, hidden files off; image preview limits. See [Shells](shells.md) for `y`/`yy`. |
| `lazygit` | Garden colours only; the base setup is in the git suite ([Git](../git/git.md)). |
| `delta` | Diff pager with the garden theme ([Git](../git/git.md)). |
| `btop` | `garden` colour theme, transparent background, vim keys, process tree sorted by CPU. |
| `fzf` | Fish integration (key bindings). Colours come from the garden theme. |
| `broot` | Non-modal, git status shown, an `edit` verb that opens `$EDITOR`; nushell integration (`br`). |
| `eza` | Icons, git column, directories first; the `l`/`la`/`lt`/`ll` fish abbreviations ([Shells](shells.md)). |
| `bat` | Package, plus `MANPAGER` so man pages are rendered through bat. |
| `prettier` | Package and `~/.prettierrc` (80 columns, prose wrap always, no semicolons, single quotes); nushell alias `mdfmt`. |
| `hyfetch` | fastfetch backend with a pride-flag preset. |
| `rbw` | Bitwarden client; see [Password manager](../security/password-manager.md). |
| `crypt` | Installs `age`. |
| `kitty`, `ghostty` | Above. |
| `duf`, `dust`, `fd`, `glow`, `jq`, `nix-diff`, `nix-tree`, `procs`, `ripgrep`, `tree` | Package only. |

Other files in `modules/cli/` (for example the database clients) are not
in this bundle; they are included by the layers that need them.

## Key files

| File | Purpose |
|---|---|
| `modules/cli/bundle.nix` | the `cli` bundle |
| `modules/cli/kitty.nix` | kitty settings, `TERMINFO_DIRS` |
| `modules/cli/ghostty.nix` | Ghostty settings, garden includes, keybindings |
| `modules/cli/tmux.nix` | tmux prefix and bindings |
| `modules/cli/helix.nix`, `modules/cli/kakoune.nix` | editors |
| `modules/desktop/niri.nix` | spawns kitty |
