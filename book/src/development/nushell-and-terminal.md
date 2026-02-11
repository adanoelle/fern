# Nushell & Terminal

> Nushell is the default shell with structured data pipelines, Starship prompt,
> Zoxide navigation, and Ghostty as the terminal emulator.

## Nushell

Nushell (`nu`) is the default login shell, configured in
`nix/home/shells/nushell.nix`. Unlike Bash or Zsh, Nushell treats command output
as structured data (tables, records, lists), making it powerful for system
administration and data exploration.

### Shell settings

| Setting              | Value   |
| -------------------- | ------- |
| Completion algorithm | Prefix  |
| Banner               | Enabled |
| Editor               | `hx`    |
| Pager                | `delta` |

### Integrations

- **Starship** prompt auto-initialized via `~/.cache/starship/init.nu`
- **Zoxide** directory jumper via `~/.cache/zoxide/init.nu`
- **Git aliases** defined directly in Nushell config:

| Alias | Command                     |
| ----- | --------------------------- |
| `gst` | `git status`                |
| `gaa` | `git add --all`             |
| `gcm` | `git commit -m`             |
| `gco` | `git checkout`              |
| `gp`  | `git push`                  |
| `gl`  | `git pull`                  |
| `gg`  | `git log --oneline --graph` |
| `gds` | `git diff --staged`         |
| `gdc` | `git diff --cached`         |

### Environment variables

Set in the Nushell environment:

```
EDITOR = hx
VISUAL = hx
PAGER = delta
GIT_PAGER = delta
```

## Starship prompt

Starship (`nix/home/shells/starship.nix`) provides a minimal, fast prompt:

- New line before each prompt
- Success indicator: `[->](bold green)`
- OS indicator: a snowflake for NixOS

Starship automatically shows context-aware segments: git branch, language
version, command duration, etc.

## Zoxide

Zoxide (`nix/home/shells/zoxide.nix`) replaces `cd` with a frecency-based
directory jumper. After visiting a directory once, `z partial-name` jumps back
to it from anywhere. Nushell integration is enabled.

## Ghostty terminal

Ghostty (`nix/home/cli/ghostty.nix`) is the terminal emulator:

| Setting   | Value              |
| --------- | ------------------ |
| Font      | FiraCode Nerd Font |
| Font size | 11                 |
| Theme     | catppuccin-frappe  |

### Keybindings

| Binding                 | Action                        |
| ----------------------- | ----------------------------- |
| `Ctrl + Shift + T`      | New tab                       |
| `Ctrl + Shift + W`      | Close tab                     |
| `Ctrl + Shift + D`      | Split right                   |
| `Ctrl + Shift + E`      | Split down                    |
| `Alt + H/J/K/L`         | Navigate splits               |
| `Shift + Enter`         | Multi-line input              |
| `Ctrl + =` / `Ctrl + -` | Increase / decrease font size |

## Key files

| File                           | Purpose                           |
| ------------------------------ | --------------------------------- |
| `nix/home/shells/nushell.nix`  | Nushell configuration and aliases |
| `nix/home/shells/starship.nix` | Starship prompt settings          |
| `nix/home/shells/zoxide.nix`   | Zoxide integration                |
| `nix/home/shells/devenv.nix`   | devenv installation               |
| `nix/home/cli/ghostty.nix`     | Ghostty terminal configuration    |
| `nix/modules/users.nix`        | Sets Nushell as login shell       |
