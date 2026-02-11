# Git Suite

> The Git configuration spans 12+ modules covering core settings, 100+ aliases,
> multi-identity management, worktree workflows, safety guards, and Claude Code
> integration.

Git is the most extensively configured tool in this repository. The suite lives
in `nix/home/git/` and is organized as a set of modules that can be individually
toggled. The main entry point is `nix/home/git/default.nix`, which defines the
`programs.gitSuite` option set.

## Module overview

| Module                  | What it does                                                           |
| ----------------------- | ---------------------------------------------------------------------- |
| `core.nix`              | SSH signing, delta pager, performance tuning, pull/push/merge defaults |
| `aliases.nix`           | 100+ Git aliases and shell aliases                                     |
| `identities.nix`        | Multi-identity support with `includeIf`                                |
| `safety.nix`            | Protected branch guards, pre-push hooks, safe operations               |
| `tools.nix`             | Lazygit, tig, git-absorb, git-lfs                                      |
| `help.nix`              | tldr integration, quick-reference sheet                                |
| `worktree.nix`          | `wt` helper script for worktree management                             |
| `worktree-enhanced.nix` | Dashboard, parallel ops, templates                                     |
| `prompts.nix`           | Shell prompt git status indicators                                     |
| `claude-code.nix`       | `claude` wrapper with safety checks                                    |
| `claude-enhanced.nix`   | `claude-wt` session manager                                            |

## Enabling the suite

In the host configuration:

```nix
programs.gitSuite = {
  enable = true;
  userName = "ada";
  userEmail = "ada@snailmail.com";
  editor = "hx";
  enableGithub = true;
  enableTools = true;
  enableSafety = true;
  enableHelp = true;
};
```

## Core configuration

The core module sets up:

- **SSH commit signing** by default
- **Delta** as the diff pager (side-by-side, Catppuccin theme)
- **Performance**: `preloadIndex`, `multiPackIndex`, `commitGraph`,
  `untrackedCache`
- **Pull**: rebase strategy
- **Push**: auto-setup remote tracking
- **Fetch**: prune stale branches, 3 parallel connections
- **Merge**: diff3 conflict style, rerere enabled
- **Rebase**: autoSquash, autoStash
- **Diff**: histogram algorithm

## Multi-identity

The identities module supports multiple Git identities switched by directory:

```nix
programs.gitIdentities.identities = {
  personal = {
    name = "adanoelle";
    email = "adanoelleyoung@gmail.com";
    directory = "/home/ada/personal/";
    signingKey = "/home/ada/.ssh/github";
  };
  work = {
    name = "youngt0dd";
    email = "todd.young@pinnaclereliability.com";
    directory = "/home/ada/work/";
    signingKey = "/home/ada/.ssh/github-work";
    sshCommand = "ssh -i /home/ada/.ssh/github-work -o IdentitiesOnly=yes";
  };
};
```

Git automatically uses the correct name, email, and SSH key based on the
repository's path. Check the current identity with `git id` or `gid`.

## Safety guards

The safety module protects against common mistakes:

- **Protected branches** (main, master, prod, production) require confirmation
  before pushing
- **Pre-push hook** warns when pushing to protected branches
- **Safe aliases**: `pushf` uses `--force-with-lease` (not `--force`), `undo`
  resets one commit keeping changes, `uncommit` resets HEAD keeping staged files

## Worktree management

The `wt` helper script provides:

| Command            | Description                      |
| ------------------ | -------------------------------- |
| `wt new <name>`    | Create worktree with new branch  |
| `wt list`          | List all worktrees with status   |
| `wt switch`        | Interactive switch (fzf)         |
| `wt remove <name>` | Remove worktree                  |
| `wt pr <number>`   | Create worktree for a GitHub PR  |
| `wt status`        | Detailed status of all worktrees |

Enhanced features add templates (`wt-feature`, `wt-fix`, `wt-hotfix`), parallel
operations (`wt-parallel pull`), and a visual dashboard (`wt-dashboard`).

## Key aliases

A selection of the most-used aliases:

| Alias  | Command                   |
| ------ | ------------------------- |
| `g`    | `git status`              |
| `ga`   | `git add`                 |
| `gc`   | `git commit`              |
| `gp`   | `git push`                |
| `gl`   | `git pull`                |
| `gd`   | `git diff`                |
| `gco`  | `git checkout`            |
| `gcob` | `git checkout -b`         |
| `gid`  | Show current git identity |
| `lg`   | `lazygit`                 |
| `wtn`  | New worktree              |
| `wts`  | Switch worktree           |
| `cc`   | `claude`                  |
| `ccn`  | Claude in new worktree    |

See [Shell Aliases & Commands](../reference/aliases.md) for the complete list.

## Key files

| File                                 | Purpose                            |
| ------------------------------------ | ---------------------------------- |
| `nix/home/git/default.nix`           | Main module, option definitions    |
| `nix/home/git/core.nix`              | Core git settings                  |
| `nix/home/git/aliases.nix`           | All git and shell aliases          |
| `nix/home/git/identities.nix`        | Multi-identity configuration       |
| `nix/home/git/safety.nix`            | Protected branches, hooks          |
| `nix/home/git/tools.nix`             | Lazygit, tig, git-absorb           |
| `nix/home/git/worktree.nix`          | Worktree helper script             |
| `nix/home/git/worktree-enhanced.nix` | Dashboard, templates, parallel ops |
| `nix/home/git/claude-code.nix`       | Claude wrapper script              |
| `nix/home/git/claude-enhanced.nix`   | Claude session manager             |
| `nix/home/git/prompts.nix`           | Shell prompt git indicators        |
| `nix/home/git/help.nix`              | Help system and quick reference    |
