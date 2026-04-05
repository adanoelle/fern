# GitHub & Tools

> The GitHub aspect integrates the GitHub CLI with Git aliases for PR and issue
> workflows. The tools aspect adds Lazygit, tig, git-absorb, and git-lfs.

## GitHub CLI integration

The `git-github` aspect (`modules/git/github.nix`) installs the GitHub CLI
(`gh`) and adds Git aliases for common PR/issue operations:

### PR workflow aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `prc` | `gh pr create` | Create a pull request |
| `prco` | `gh pr checkout` | Checkout a PR branch |
| `prv` | `gh pr view` | View PR details |
| `prm` | `gh pr merge` | Merge a pull request |
| `prs` | `gh pr status` | Show PR status |
| `prl` | `gh pr list` | List open PRs |

### Issue workflow aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `isc` | `gh issue create` | Create an issue |
| `isv` | `gh issue view` | View issue details |
| `isl` | `gh issue list` | List open issues |

The aspect also configures the GitHub CLI's default editor to match the git
suite's editor setting (typically `hx` for Helix).

## Additional Git tools

The `git-tools` aspect (`modules/git/tools.nix`) installs and configures:

### Lazygit

A terminal UI for Git that provides a visual interface for staging, committing,
branching, and resolving conflicts. Available via the `lg` alias.

### tig

A text-mode interface for Git with an ncurses-based log viewer and diff browser.

### git-absorb

Automatically identifies which commits in your branch should absorb staged
changes, then creates fixup commits. Useful for cleaning up a branch before
review:

```bash
# Stage your fixes
ga .

# Automatically create fixup commits
git absorb --and-rebase
```

### git-filter-repo

A tool for rewriting Git history -- faster and safer than `git filter-branch`.
Used for removing large files from history, splitting repositories, or
extracting subdirectories.

### git-lfs

Git Large File Storage for tracking binary assets (images, models, etc.) outside
the main repository.

## Key files

| File | Purpose |
|------|---------|
| `modules/git/github.nix` | GitHub CLI integration and PR/issue aliases |
| `modules/git/tools.nix` | Lazygit, tig, git-absorb, git-filter-repo, git-lfs |
