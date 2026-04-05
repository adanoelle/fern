# Worktrees

> Git worktrees let you work on multiple branches simultaneously without
> stashing or switching. The `wt` helper script and enhanced features provide
> worktree lifecycle management.

## Basic worktree management

The `git-worktree` aspect (`modules/git/worktree.nix`) provides the `wt` helper
script with colorized output and interactive selection:

| Command | Description |
|---------|-------------|
| `wt new <name>` | Create a new worktree with a new branch |
| `wt list` | List all worktrees with status |
| `wt switch` | Interactive worktree switch (fzf) |
| `wt remove <name>` | Remove a worktree |
| `wt clean` | Remove worktrees with merged branches |
| `wt pr <number>` | Create a worktree for a GitHub PR |
| `wt status` | Detailed status of all worktrees |

### Shell aliases

| Alias | Command |
|-------|---------|
| `wtn` | `wt new` |
| `wts` | `wt switch` |
| `wtr` | `wt remove` |
| `wtl` | `wt list` |

### Example workflow

```bash
# Start a feature
wtn add-dark-mode

# Work in the new worktree (automatically cd'd)
# ... edit files, test, commit ...

# Switch to another worktree
wts    # interactive fzf picker

# Clean up when done
wtr add-dark-mode
```

## Enhanced features

The `git-worktree-enhanced` aspect (`modules/git/worktree-enhanced.nix`) adds
three capabilities:

### Dashboard

`wt-dashboard` shows a visual overview of all worktrees with their branch,
status (clean/dirty), last commit, and upstream status.

### Templates

Templates create worktrees with branch naming conventions:

| Command | Branch format |
|---------|--------------|
| `wt-feature <name>` | `feature/<name>` |
| `wt-fix <name>` | `fix/<name>` |
| `wt-hotfix <name>` | `hotfix/<name>` |
| `wt-release <name>` | `release/<name>` |
| `wt-experiment <name>` | `experiment/<name>` |
| `wt-claude <name>` | `claude/<name>` |

### Parallel operations

`wt-parallel <command>` runs a Git command across all worktrees simultaneously:

```bash
# Pull latest in all worktrees
wt-parallel pull

# Fetch in all worktrees
wt-parallel fetch
```

## Key files

| File | Purpose |
|------|---------|
| `modules/git/worktree.nix` | `wt` helper script and basic aliases |
| `modules/git/worktree-enhanced.nix` | Dashboard, templates, parallel ops |
