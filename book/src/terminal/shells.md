# Shells

> Fish is the login shell and the one every terminal here starts. It
> carries a hand-written two-line garden prompt, vi keys and a set of
> abbreviations. Nushell and zsh are also configured: nushell as a second
> interactive shell with a starship prompt, zsh mainly so that a usable
> `~/.zshrc` exists to copy to machines without Nix. Starship and zoxide
> are wired into the shells that use them.

**Goes on:** every host (the `shells` bundle is part of the base user
layer, `modules/user-ada.nix`). The login-shell setting is NixOS-only:
see below for the work laptop.

## What the bundle contains

`modules/shells/bundle.nix` defines `den.aspects.shells`:

| Aspect | File | What it configures |
|---|---|---|
| `fish` | `modules/shells/fish.nix` | prompt, vi mode, abbreviations, `y`, notifications |
| `nushell` | `modules/shells/nushell.nix` | `extraConfig`: prompt/zoxide init, aliases, env |
| `zsh` | `modules/shells/zsh.nix` | a mirror of the fish setup in plain zsh |
| `starship` | `modules/shells/starship.nix` | prompt for nushell and zsh; off for fish |
| `zoxide` | `modules/shells/zoxide.nix` | `z` / `zi` in fish and nushell |
| `devenv` | `modules/shells/devenv.nix` | installs `devenv` from its flake input |

direnv is not part of this bundle. It is enabled (with nix-direnv) by the
C/C++ toolchain aspect; see [C and C++](../toolchains/c-cpp.md).

## Which shell runs where

- On NixOS hosts `modules/users.nix` sets `shell = pkgs.fish` for every
  user in the topology and enables `programs.fish` system-wide.
- On the work laptop the login shell is whatever the distribution
  account has (bash); Home Manager does not change it. Fish still runs
  in practice because kitty (`modules/cli/kitty.nix`) and herdr
  (`modules/cli/herdr.nix`) name the fish binary explicitly.
- Nushell and zsh are started by typing `nu` or `zsh`.

## Fish

### Prompt

The prompt is two fish functions in `fish.nix`, not starship. Colours are
garden palette values baked in at build time
(`inputs.garden-shell.lib.palette.colors`).

```
~/src/fern main·3
✧
```

| Part | Meaning |
|---|---|
| path | `prompt_pwd --full-length-dirs 2` |
| `main·3` | current branch, then `·N` when `git status --porcelain` lists N entries |
| `✧` colour | urgent colour after a failed command; accent inside a Nix shell (`IN_NIX_SHELL`); ok colour inside a Python venv (`VIRTUAL_ENV`); normal text otherwise |
| right prompt | short hostname when `SSH_CONNECTION` is set, then `$GARDEN_CHANNEL` (and `:$GARDEN_PAGE` if set) |

The rest of fish's colours (syntax highlighting, pager) are not set here;
they come from the garden theme files described in
[Garden](../desktop/garden.md).

### `GARDEN_CHANNEL`

A function run before every prompt asks niri for its workspaces
(`niri msg -j workspaces`) and exports the name of the focused one as
`GARDEN_CHANNEL`, which the right prompt shows. The variable is cleared
when the focused workspace has no name or there is no niri session
(over SSH, on a TTY), so a stale name is never shown. Nothing else in
this repository reads it.

### Vi mode

`fish_vi_key_bindings` is called from `interactiveShellInit`. The same
h/j/k/l vocabulary is used by tmux, herdr and Ghostty splits; see
[Terminals](terminals.md).

### Long-command notification

A `fish_postexec` handler sends a desktop notification
(`notify-send "fish" ...`) whenever a command took longer than 10
seconds. There is no filter on the command, so leaving an editor or a
pager open for more than 10 seconds also produces a toast on exit.
`libnotify` is installed by the aspect; a notification daemon must be
running for anything to appear.

### `y` and `yy`

`y` is defined in `fish.nix`: it runs yazi with `--cwd-file` and changes
to the directory yazi was left in. `modules/cli/yazi.nix` additionally
enables yazi's own fish integration with `shellWrapperName = "yy"`, so
`yy` does the same thing. Both exist; nushell and zsh get `yy` (zsh also
gets `y` from `zsh.nix`).

### Abbreviations

Fish abbreviations expand in place when typed, so the full command is
what lands in history.

| Source | Abbreviations |
|---|---|
| `modules/shells/fish.nix` | git: `g ga gaa gc gcm gco gp gl gd gds gg gst gstp`, taken from the shared shell aliases |
| `modules/cli/eza.nix` | `l` `la` `lt` `ll` (eza listings); the same four are aliases in bash and zsh |

`eza.nix` also enables `programs.eza` with icons, git status and
directories first, which aliases plain `eza` to carry those flags. `bat`
replaces the man pager (`MANPAGER` in `modules/cli/bat.nix`). `ls` and
`cat` themselves are not aliased.

The expansions are listed in [Aliases](../reference/aliases.md).

### One definition for the git shortcuts

The git shortcuts are defined once, as `home.shellAliases` in
`modules/git/aliases.nix` ([Git](../git/git.md)), which Home Manager
applies to fish, zsh and nushell. `fish.nix` does not define its own:
it selects the common ones from that set and makes them abbreviations
as well, so `g`, `gl`, `gst` and the rest mean the same thing in every
shell.

## Nushell

`modules/shells/nushell.nix` enables `programs.nushell` and builds one
`extraConfig` string. What it sets:

| Item | Value |
|---|---|
| Environment | `EDITOR` and `VISUAL` = `hx`; `PAGER` and `GIT_PAGER` = `delta`; `LESSHISTFILE` = `-` |
| `$env.config` | banner shown; completions: prefix matching, case-insensitive, quick, external completers off |

The prompt, zoxide and the git shortcuts are not set here. Home
Manager's own integrations add them to the generated `config.nu`:
zoxide and starship (both have nushell integration enabled in their
aspects), `yy` for yazi, `lg` for lazygit, fzf, direnv, broot's `br`,
and every entry of
`home.shellAliases`. `modules/cli/prettier.nix` adds one nushell-only
alias, `mdfmt`.

The module also sets `home.sessionVariables.SOPS_AGE_KEY_FILE`, which
applies to every shell, not only nushell; see
[Environment variables](../reference/environment-variables.md).

## Zsh

`modules/shells/zsh.nix` exists to produce a `~/.zshrc` that resembles
the fish setup and can be copied to a machine without Nix or fish:

```bash
scp ~/.zshrc <remote-host>:.zshrc
```

For that reason `dotDir` is pinned to the home directory, so the file
stays at `~/.zshrc`. It sets vi mode (with backspace, `Ctrl-W`,
`Ctrl-L`, `Ctrl-R` restored), menu completion, shared history of 50000
entries, a two-line `✧` prompt built on `vcs_info`, the `y` yazi
wrapper, and a block of integrations (bat man pager, zoxide, fzf,
direnv, and the eza aliases added by `modules/cli/eza.nix`) each
guarded by `command -v`, so they are skipped
where the tool is missing. Autosuggestions and syntax highlighting are
off.

Two things about the generated file are worth knowing:

- Starship's zsh integration is on (only the fish one is disabled) and
  Home Manager emits its init after the `PROMPT=` lines, so on a machine
  managed by this configuration zsh shows the starship prompt, not the
  `✧` one.
- Home Manager's zoxide, fzf, starship and direnv integrations are
  written with absolute `/nix/store` paths and no guard. On a remote
  host without those paths each prints a "no such file" error at
  startup; the guarded block then loads whichever tools are installed
  there, and the `✧` prompt is the one shown.

## Starship

`modules/shells/starship.nix` enables starship with
`enableFishIntegration = false`: fish keeps its own prompt. Nushell and
zsh get starship. The settings are small: a blank line between prompts,
`➜` as the success symbol, and the OS module enabled with a snowflake
for NixOS.

## Zoxide

`modules/shells/zoxide.nix` enables zoxide for fish and nushell (and,
through Home Manager's default, zsh). `z <fragment>` jumps to the best
match; `zi` picks interactively. `cd` is not replaced.

## Key files

| File | Purpose |
|---|---|
| `modules/shells/bundle.nix` | the `shells` bundle |
| `modules/shells/fish.nix` | fish prompt, vi mode, abbreviations, hooks |
| `modules/shells/nushell.nix` | nushell `extraConfig` and activation scripts |
| `modules/shells/zsh.nix` | portable zsh mirror |
| `modules/shells/starship.nix` | starship settings |
| `modules/shells/zoxide.nix` | zoxide integration |
| `modules/shells/devenv.nix` | devenv package |
| `modules/cli/eza.nix`, `modules/cli/bat.nix` | listing aliases and abbreviations, man pager |
| `modules/users.nix` | login shell on NixOS hosts |
