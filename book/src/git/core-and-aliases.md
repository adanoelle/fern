# Core & Aliases

> The core aspect configures SSH signing, delta diffs, and performance tuning.
> The aliases aspect adds 100+ Git and shell aliases for fast daily workflows.

## Core configuration

The `git-core` aspect (`modules/git/core.nix`) defines `programs.gitCore`
options that set up the fundamental Git experience.

### SSH commit signing

All commits are signed with SSH keys by default:

```nix
programs.git.signing = {
  key = cfg.signingKey;
  signByDefault = true;
  format = "ssh";
};
```

This means every commit gets a cryptographic signature that GitHub and other
forges can verify.

### Delta pager

[Delta](https://github.com/dandavison/delta) replaces the default Git diff
pager with side-by-side diffs, syntax highlighting, and a Catppuccin Frappe
theme. The core aspect sets:

- Side-by-side layout
- Line numbers
- Catppuccin Frappe theme (from the delta aspect at `modules/cli/delta.nix`)
- Navigate mode for jumping between files in large diffs

### Performance tuning

```nix
programs.git.extraConfig = {
  core.preloadIndex = true;
  core.multiPackIndex = true;
  core.commitGraph = true;
  core.untrackedCache = true;
  feature.manyFiles = true;
};
```

These settings optimize Git for large repositories:
- **preloadIndex** -- Parallel index loading
- **multiPackIndex** -- Faster object lookup across multiple packfiles
- **commitGraph** -- Precomputed commit graph for faster `log` and `merge-base`
- **untrackedCache** -- Cache untracked file status between commands
- **manyFiles** -- Enable all optimizations for repos with many files

### Other defaults

- **Pull**: Rebase strategy (`pull.rebase = true`)
- **Push**: Auto-setup remote tracking (`push.autoSetupRemote = true`)
- **Fetch**: Prune stale branches, 3 parallel connections
- **Merge**: diff3 conflict style, rerere enabled
- **Rebase**: autoSquash, autoStash
- **Diff**: Histogram algorithm

## Aliases

The `git-aliases` aspect (`modules/git/aliases.nix`) defines aliases in two
categories: Git aliases (used as `git <alias>`) and shell aliases (standalone
commands).

### Key Git aliases

| Alias | Command | Category |
|-------|---------|----------|
| `s` | `status -sb` | Status |
| `a` | `add` | Staging |
| `ap` | `add -p` | Staging (interactive) |
| `c` | `commit` | Commit |
| `cm` | `commit -m` | Commit with message |
| `ca` | `commit --amend` | Amend last commit |
| `co` | `checkout` | Checkout |
| `cob` | `checkout -b` | New branch |
| `d` | `diff` | Diff |
| `ds` | `diff --staged` | Staged diff |
| `l` | `log --oneline -20` | Recent log |
| `lg` | Pretty graph log | Full graph |
| `pushf` | `push --force-with-lease` | Safe force push |
| `undo` | `reset HEAD~1 --mixed` | Undo last commit (keep changes) |
| `uncommit` | `reset --soft HEAD~1` | Uncommit (keep staged) |

### Key shell aliases

| Alias | Command | Purpose |
|-------|---------|---------|
| `g` | `git status` | Quick status |
| `ga` | `git add` | Stage files |
| `gc` | `git commit` | Commit |
| `gp` | `git push` | Push |
| `gl` | `git pull` | Pull |
| `gd` | `git diff` | Diff |
| `gco` | `git checkout` | Checkout |
| `gcob` | `git checkout -b` | New branch |
| `gid` | Show current identity | Identity check |
| `lg` | `lazygit` | TUI git client |
| `wtn` | `wt new` | New worktree |
| `wts` | `wt switch` | Switch worktree |
| `cc` | `claude` | Claude Code |
| `ccn` | `claude-wt new` | New Claude session |

See [Shell Aliases & Commands](../reference/aliases.md) for the complete list.

## Key files

| File | Purpose |
|------|---------|
| `modules/git/core.nix` | Core git configuration and options |
| `modules/git/aliases.nix` | All git and shell aliases |
| `modules/cli/delta.nix` | Delta diff pager configuration |
