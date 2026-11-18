# Aliases & Commands

> Every shell alias, fish abbreviation, shell function, git alias and
> `gh` alias the configuration defines, where each is set, and where
> the three shells disagree about what a name means. Also the custom
> commands the configuration installs.

**Goes on:** every machine, except where a table says otherwise. The
tables were generated from the evaluated Home Manager configuration;
the commands to do that again are at
[the end of the page](#regenerating-this-page).

`just` recipes are not listed here. They are on
[Day to Day](../operations/day-to-day.md#recipes).

## How the layers interact

Several mechanisms define short names, and they overlap:

| Mechanism | Set in | Reaches |
| --- | --- | --- |
| `home.shellAliases` | `modules/git/*.nix` | fish, zsh and Nushell |
| eza listing aliases | `modules/cli/eza.nix`, one definition for all shells | fish, bash and zsh; Nushell gets only the `eza` alias |
| fish abbreviations | `programs.fish.shellAbbrs` in several modules | fish only |

When a name is defined twice:

- **fish:** an abbreviation expands as it is typed, so at an
  interactive prompt the abbreviation wins over an alias of the same
  name. The alias still applies in scripts and `fish -c`.
- **zsh:** eza's listing aliases are written inside a `command -v eza`
  guard, because `~/.zshrc` is copied to machines without Nix; Home
  Manager's own eza integration is off for zsh.

## Names that differ between shells

The git shortcuts and the eza listings are not among them: each has
one definition (`modules/git/aliases.nix`, `modules/cli/eza.nix`) used
by every shell that has them.

| Name | fish (interactive) | zsh | Nushell |
| --- | --- | --- | --- |
| `l` | `eza -l` | same | not defined |
| `ll` | `eza -l --sort=modified --reverse` | same | not defined |
| `la` | `eza -la` | same | not defined |
| `lt` | `eza -lT --level=2` | same | not defined |
| `ls`, `lla` | `eza`, `eza -la` | same | not defined (`ls` is the Nushell builtin) |
| `mdfmt` | not defined | not defined | `prettier --write` |
| `y` | Yazi wrapper function | Yazi wrapper function | not defined |

In all three shells `eza` itself is aliased to
`eza --icons auto --git --group-directories-first`.

## Shell aliases

From `home.shellAliases`; present in fish, zsh and Nushell unless the
table above says a shell overrides the name.

### Git shortcuts (`modules/git/aliases.nix`)

| Alias | Expands to |
| --- | --- |
| `g` | `git status -sb` |
| `ga` | `git add` |
| `gaa` | `git add -A` |
| `gc` | `git commit` |
| `gcm` | `git commit -m` |
| `gp` | `git push` |
| `gpu` | `git push -u origin HEAD` |
| `gl`, `gpl` | `git pull` |
| `gf` | `git fetch` |
| `gd` | `git diff` |
| `gds` | `git diff --staged` |
| `gg` | `git log --graph --decorate --oneline --all` |
| `gst` | `git stash` |
| `gstp` | `git stash pop` |
| `gco` | `git checkout` |
| `gb` | `git branch` |
| `gid` | `git whoami` |
| `wtn` | `git wt-new` |
| `wtl` | `git wtl` |

### GitHub CLI (`modules/git/github.nix`)

| Alias | Expands to |
| --- | --- |
| `pr` | `gh pr` |
| `prc` | `gh pr create` |
| `prl` | `gh pr list` |
| `prv` | `gh pr view` |
| `prs` | `gh pr status` |
| `prw` | `gh pr view --web` |
| `issue` | `gh issue` |
| `issuec` | `gh issue create` |
| `issuel` | `gh issue list` |
| `repo` | `gh repo` |
| `repow` | `gh repo view --web` |
| `ghci` | `gh pr checks` |
| `ghapprove` | `gh pr review --approve` |
| `myprs` | `gh pr list --author @me` |
| `myreviews` | `gh pr list --reviewer @me` |

### Git tools (`modules/git/tools.nix`)

| Alias | Expands to |
| --- | --- |
| `lg` | `lazygit` |
| `lgs` | `lazygit status` |
| `lgf` | `lazygit log` |
| `tig` | `tig` |
| `tiga` | `tig --all` |
| `tigs` | `tig status` |
| `absorb` | `git absorb` |
| `gafix` | `git absorb --and-rebase` |

### Help and identity (`modules/git/help.nix`, `modules/git/identities.nix`)

| Alias | Expands to |
| --- | --- |
| `g-help` | `cat ~/.config/git/quick-ref.txt` |
| `g-aliases` | `git list-aliases` |
| `g-ref` | Prints a one-line reminder of the common shortcuts |
| `git-help`, `g-examples` | `tldr git` |
| `git-id` | `git id` |
| `git-who` | `git config user.email` |

## Fish abbreviations

`g`, `ga`, `gaa`, `gc`, `gcm`, `gco`, `gp`, `gl`, `gd`, `gds`, `gg`,
`gst` and `gstp` are also abbreviations in fish, with the expansions
listed under [Git shortcuts](#git-shortcuts-modulesgitaliasesnix).
`modules/shells/fish.nix` takes them from the shared shell aliases.

| Abbreviation | Expands to | Set in | Goes on |
| --- | --- | --- | --- |
| `l` | `eza -l` | `modules/cli/eza.nix` | every machine |
| `la` | `eza -la` | `modules/cli/eza.nix` | every machine |
| `ll` | `eza -l --sort=modified --reverse` | `modules/cli/eza.nix` | every machine |
| `lt` | `eza -lT --level=2` | `modules/cli/eza.nix` | every machine |
| `dk` | `duckdb` | `modules/cli/duckdb.nix` | work laptop |
| `dkq` | `duckdb -c` | `modules/cli/duckdb.nix` | work laptop |
| `vpn`, `vpnoff`, `vpns` | Connect, disconnect and show the status of the work VPN client | `modules/user-ada-work.nix` | work laptop |

## Shell functions

| Function | Shells | What it does | Set in |
| --- | --- | --- | --- |
| `y` | fish, zsh | Runs Yazi and changes to the directory it exited in | `modules/shells/fish.nix`, `modules/shells/zsh.nix` |
| `yy` | fish | Yazi's own wrapper with the same effect; the name is pinned | `modules/cli/yazi.nix` |
| `lg` | fish, zsh, Nushell | Home Manager's lazygit wrapper, which changes to the directory lazygit exited in. It shares its name with the `lg` shell alias; either way `lg` starts lazygit | Home Manager's lazygit module, enabled by `modules/git/tools.nix` |

## Nushell-only aliases

Defined in `modules/cli/prettier.nix`.

| Alias | Expands to |
| --- | --- |
| `mdfmt` | `prettier --write` |

## Git aliases

Used as `git <alias>`. Identical on every machine.

### Everyday (`modules/git/aliases.nix`)

| Alias | Expands to |
| --- | --- |
| `s` | `status -sb` |
| `ss` | `status` |
| `a` | `add` |
| `aa` | `add -A` |
| `ap` | `add -p` |
| `au` | `add -u` |
| `c` | `commit` |
| `cm` | `commit -m` |
| `fixup` | `commit --fixup` |
| `wip` | Stage everything and commit as `WIP` |
| `b` | `branch -vv` |
| `ba` | `branch -a` |
| `bd` | `branch -d` |
| `co` | `checkout` |
| `cob` | `checkout -b` |
| `com` | `checkout main` |
| `d` | `diff` |
| `dc` | `diff --cached` |
| `dh` | `diff HEAD` |
| `l` | `log --graph` with a coloured one-line format |
| `ll` | `log --graph --oneline --decorate --all` |
| `last` | `log -1 HEAD --stat` |
| `today` | Today's commits by the current `user.name`, one line each |
| `p` | `push` |
| `pf` | `push --force-with-lease` |
| `pu` | `push -u origin HEAD` |
| `pl` | `pull` |
| `plr` | `pull --rebase` |
| `f` | `fetch` |
| `fa` | `fetch --all` |
| `st` | `stash` |
| `stp` | `stash pop` |
| `stl` | `stash list` |
| `std` | `stash drop` |
| `wta` | `worktree add` |
| `wtl` | `worktree list` |
| `wtr` | `worktree remove` |
| `wtp` | `worktree prune` |
| `wt-new` | `worktree add ../<name> -b <name>` for the name given |
| `whoami` | Prints `name <email>` from the active identity |
| `identity` | `config --get-regexp '^user\.'` |
| `snapshot` | Creates an annotated `snapshot-<timestamp>` tag |
| `snapshots` | Lists snapshot tags, newest first |
| `last-snapshot` | Prints the newest snapshot tag |
| `aliases` | `config --get-regexp '^alias\.'` |
| `root` | `rev-parse --show-toplevel` |
| `current` | `rev-parse --abbrev-ref HEAD` |

### Safety (`modules/git/safety.nix`)

| Alias | Expands to |
| --- | --- |
| `pushf`, `pushforce` | `push --force-with-lease` |
| `undo` | `reset --soft HEAD~1` |
| `uncommit` | `reset HEAD~1` |
| `unstage` | `reset HEAD --` |
| `amend` | `commit --amend --no-edit` |
| `discard` | `checkout --` |
| `save` | `stash push -m` |
| `pop` | `stash pop` |
| `amendmsg` | `commit --amend` |
| `cleanup` | Deletes local branches already merged, except `main` and `master` |
| `prune-branches` | Prunes `origin`, then deletes local branches whose upstream is gone |
| `check` | `status`, then `diff --stat` |
| `safe-status` | `status --porcelain` |

### GitHub (`modules/git/github.nix`)

Each runs the `gh` command of the same shape.

| Alias | Runs |
| --- | --- |
| `pr-create`, `pr-list`, `pr-checkout`, `pr-view`, `pr-status`, `pr-merge`, `pr-checks` | `gh pr <verb>` |
| `pr-web` | `gh pr view --web` |
| `pr-approve` | `gh pr review --approve` |
| `pr-comment` | `gh pr review --comment` |
| `issue-create`, `issue-list`, `issue-view` | `gh issue <verb>` |
| `repo-clone`, `repo-fork` | `gh repo <verb>` |
| `repo-web` | `gh repo view --web` |
| `my-prs` | `gh pr list --author @me` |
| `my-reviews` | `gh pr list --reviewer @me` |
| `my-issues` | `gh issue list --assignee @me` |

### Tools (`modules/git/tools.nix`)

| Alias | Runs |
| --- | --- |
| `lg`, `visual` | `lazygit` |
| `t` | `tig` |
| `ta` | `tig --all` |
| `ts` | `tig status` |
| `tb` | `tig blame` |
| `absorb` | `git-absorb` |
| `fix` | `git-absorb --and-rebase` |

### Help and identity (`modules/git/help.nix`, `modules/git/identities.nix`)

| Alias | Expands to |
| --- | --- |
| `h` | `help` |
| `help-config` | `config --list --show-origin` |
| `help-aliases` | `config --get-regexp '^alias\.'` |
| `help-commands` | `help -a` |
| `help-guides` | `help -g` |
| `list-aliases`, `la` | Sorted list of every alias |
| `id` | Prints the active name and email |
| `id-full` | `config --get-regexp '^user\.'` |
| `id-list` | `config --get-regexp '^includeif\.'` |

## `gh` aliases

Used as `gh <alias>`. Defaults of the `aliases` option in
`modules/git/github.nix`.

| Alias | Expands to |
| --- | --- |
| `co` | `pr checkout` |
| `pv` | `pr view --web` |
| `prm` | `pr list --author @me` |
| `prr` | `pr list --reviewer @me` |

## Custom commands

Scripts the configuration builds and puts on `PATH`.

| Command | What it does | Set in | Goes on |
| --- | --- | --- | --- |
| `present` | Opens a presenterm deck in a styled fullscreen terminal; see [presenterm](../terminal/presenterm.md) | `modules/cli/presenterm.nix` | every machine |
| `claude-notify`, `claude-brief` | Hook scripts for Claude Code sessions; see [Agent Sessions](../terminal/agent-sessions.md) | `modules/cli/claude-code.nix` | every machine |
| `studio-mode` | `on [frames]`, `off`, `status`: forces a small PipeWire buffer while recording; see [Audio](../services/audio.md) | `modules/audio/audio-laptop.nix` | yarrow |
| `garden-study` | Lists or switches the wallpaper study and painting; see [Wallpaper](../desktop/wallpaper.md) | `modules/desktop/wallpaper.nix` | work laptop |
| `dpeek` | Quick look at a data file through DuckDB; see [Data Tools](../toolchains/data-tools.md) | `modules/cli/duckdb.nix` | work laptop |
| Work-portal browser launcher | Starts the system Chrome with an isolated profile for one work web portal; see [the work laptop](../machines/work-laptop.md) | `modules/foreign/repd-chrome.nix` | work laptop |

## Regenerating this page

```bash
U='.#nixosConfigurations.fern.config.home-manager.users.ada'
nix eval --json "$U.home.shellAliases"
nix eval --json "$U.programs.fish.shellAliases"   # adds the eza aliases
nix eval --json "$U.programs.fish.shellAbbrs"
nix eval --json "$U.programs.nushell.shellAliases"
nix eval --json "$U.programs.git.settings.alias"
nix eval --json "$U.programs.gh.settings.aliases"
```

Replace `fern` with `yarrow`, or use
`'.#homeConfigurations."<user>@<hostname>".config'` as the prefix for
the work laptop. The Nushell-only and zsh-only aliases are in the
module text, not in an option: read `modules/shells/nushell.nix` and
`modules/shells/zsh.nix`.

## Key files

| File | Defines |
| --- | --- |
| `modules/git/aliases.nix` | Everyday git aliases and the git shell shortcuts |
| `modules/git/safety.nix`, `github.nix`, `tools.nix`, `help.nix`, `identities.nix` | The other git alias groups and their shell aliases |
| `modules/shells/fish.nix` | Fish abbreviations and the `y` function |
| `modules/shells/nushell.nix` | Nushell-only aliases |
| `modules/shells/zsh.nix` | zsh-only aliases and the `y` function |
| `modules/cli/eza.nix` | eza aliases and abbreviations |
