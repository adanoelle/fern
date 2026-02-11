# Shell Aliases & Commands

> All shell aliases, Git aliases, and just commands available in the
> configuration.

## Just commands

Defined in the `justfile` at the repository root:

| Command           | Description                                 |
| ----------------- | ------------------------------------------- |
| `just`            | List all available recipes                  |
| `just switch`     | Rebuild and switch (`nixos-rebuild switch`) |
| `just test`       | Test rebuild without switching              |
| `just test-trace` | Test with `--show-trace`                    |
| `just dry`        | Dry build only                              |
| `just rollback`   | Rollback to previous generation             |
| `just update`     | Update flake inputs                         |
| `just fmt`        | Format Nix files with `nixpkgs-fmt`         |
| `just check`      | Run `nix flake check`                       |
| `just lint`       | Format then check                           |
| `just gc`         | Garbage collect old generations             |
| `just book-serve` | Serve docs with live reload                 |
| `just book-build` | Build docs to `book/build/`                 |
| `just book-nix`   | Pure Nix documentation build                |

## Git aliases (git config)

Defined in `nix/home/git/aliases.nix`. Use as `git <alias>`.

### Status & info

| Alias     | Command                       |
| --------- | ----------------------------- |
| `s`       | `status -sb`                  |
| `ss`      | `status`                      |
| `current` | `rev-parse --abbrev-ref HEAD` |
| `root`    | `rev-parse --show-toplevel`   |

### Staging

| Alias | Command        |
| ----- | -------------- |
| `a`   | `add`          |
| `aa`  | `add --all`    |
| `ap`  | `add --patch`  |
| `au`  | `add --update` |

### Commits

| Alias   | Command           |
| ------- | ----------------- |
| `c`     | `commit`          |
| `cm`    | `commit -m`       |
| `amend` | `commit --amend`  |
| `fixup` | `commit --fixup`  |
| `wip`   | `commit -m "WIP"` |

### Branches

| Alias | Command            |
| ----- | ------------------ |
| `b`   | `branch -vv`       |
| `ba`  | `branch -vv --all` |
| `co`  | `checkout`         |
| `cob` | `checkout -b`      |
| `com` | `checkout main`    |

### Diffs

| Alias | Command         |
| ----- | --------------- |
| `d`   | `diff`          |
| `dc`  | `diff --cached` |
| `dh`  | `diff HEAD`     |

### Logs

| Alias   | Command               |
| ------- | --------------------- |
| `l`     | Fancy graph log       |
| `ll`    | `log --oneline --all` |
| `last`  | `log -1 HEAD --stat`  |
| `today` | Today's commits       |

### Push & pull

| Alias | Command                   |
| ----- | ------------------------- |
| `p`   | `push`                    |
| `pf`  | `push --force-with-lease` |
| `pu`  | `push -u origin HEAD`     |
| `pl`  | `pull`                    |
| `plr` | `pull --rebase`           |
| `f`   | `fetch`                   |
| `fa`  | `fetch --all`             |

### Stash

| Alias | Command      |
| ----- | ------------ |
| `st`  | `stash`      |
| `stp` | `stash pop`  |
| `stl` | `stash list` |
| `std` | `stash drop` |

### Reset & undo

| Alias      | Command                |
| ---------- | ---------------------- |
| `undo`     | `reset HEAD~1 --mixed` |
| `uncommit` | `reset --soft HEAD~1`  |
| `unstage`  | `reset HEAD --`        |

### Worktrees

| Alias    | Command                  |
| -------- | ------------------------ |
| `wta`    | Add worktree             |
| `wtl`    | List worktrees           |
| `wtr`    | Remove worktree          |
| `wtp`    | Prune worktrees          |
| `wt-new` | New worktree with branch |

### Snapshots

| Alias           | Command               |
| --------------- | --------------------- |
| `snapshot`      | Create stash snapshot |
| `snapshots`     | List snapshots        |
| `last-snapshot` | Show last snapshot    |

### Tools

| Alias    | Command        |
| -------- | -------------- |
| `lg`     | Launch lazygit |
| `t`      | Launch tig     |
| `absorb` | Run git-absorb |

### Identity

| Alias     | Command                   |
| --------- | ------------------------- |
| `id`      | Show name and email       |
| `id-full` | Show full identity config |
| `id-list` | List includeIf sections   |

## Shell aliases

Defined across Nushell config and various home modules.

### Git shell aliases

| Alias | Expands to                  |
| ----- | --------------------------- |
| `g`   | `git status`                |
| `ga`  | `git add`                   |
| `gaa` | `git add --all`             |
| `gc`  | `git commit`                |
| `gcm` | `git commit -m`             |
| `gco` | `git checkout`              |
| `gp`  | `git push`                  |
| `gl`  | `git pull`                  |
| `gd`  | `git diff`                  |
| `gds` | `git diff --staged`         |
| `gdc` | `git diff --cached`         |
| `gg`  | `git log --oneline --graph` |
| `gst` | `git status`                |
| `gid` | `git-id` (show identity)    |

### Worktree shell aliases

| Alias    | Expands to              |
| -------- | ----------------------- |
| `wtn`    | New worktree            |
| `wtl`    | List worktrees          |
| `wts`    | Switch worktree         |
| `wtr`    | Remove worktree         |
| `wtst`   | Worktree status         |
| `cdwt`   | cd to worktree          |
| `cdmain` | cd to main worktree     |
| `wtf`    | New feature worktree    |
| `wtfix`  | New fix worktree        |
| `wtexp`  | New experiment worktree |
| `wtc`    | New Claude worktree     |
| `wtd`    | Worktree dashboard      |
| `wtp`    | Parallel worktree ops   |

### Claude shell aliases

| Alias | Expands to                        |
| ----- | --------------------------------- |
| `cc`  | `claude` (safety wrapper)         |
| `ccs` | `claude-safe` (worktree required) |
| `ccw` | `claude-wt` (session manager)     |
| `ccn` | `claude-wt new`                   |
| `ccf` | `claude-wt finish`                |
| `ccl` | `claude-wt list`                  |
| `ccc` | `claude-wt clean`                 |
| `ccm` | `claude-monitor`                  |

### Tool aliases

| Alias | Expands to |
| ----- | ---------- |
| `lg`  | `lazygit`  |
| `hx`  | `helix`    |

### Nushell-specific

| Alias   | Expands to                   |
| ------- | ---------------------------- |
| `mdfmt` | `prettier --parser markdown` |

## Nix run apps

Available via `nix run .#<name>`:

| App          | Description                        |
| ------------ | ---------------------------------- |
| `book-serve` | Serve mdBook docs with live reload |
| `book-build` | Build mdBook docs to `book/build/` |
