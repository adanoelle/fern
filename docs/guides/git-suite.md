# Git Suite User Guide

This guide covers the comprehensive git configuration available in your Fern
NixOS setup.

## Table of Contents

1. [Overview](#overview)
2. [Core Features](#core-features)
3. [Worktree Management](#worktree-management)
4. [Identity Management](#identity-management)
5. [Claude Code Integration](#claude-code-integration)
6. [Aliases and Shortcuts](#aliases-and-shortcuts)
7. [Advanced Tools](#advanced-tools)
8. [Troubleshooting](#troubleshooting)

## Overview

The git suite provides a powerful, modular git configuration with advanced
features for modern development workflows. It includes worktree management,
multi-identity support, AI-assisted coding safety features, and extensive
customization.

### Quick Start

```bash
# Get help
git-help        # Interactive help menu
?               # Quick help
g?              # Git-specific help

# Basic workflow
g               # git status
ga .            # git add all
gc -m "msg"     # git commit
gp              # git push
```

## Core Features

### Configuration Location

All git configuration is modular and located in:

- `nix/home/git/` - Individual feature modules
- `~/.config/git/` - Generated configuration files

### Key Features

- **Smart Defaults:** Optimized for performance and safety
- **Delta Integration:** Beautiful diffs with syntax highlighting
- **SSH Signing:** Automatic commit signing with SSH keys
- **Auto-correction:** Typo correction with 1-second delay

## Worktree Management

Worktrees allow you to work on multiple branches simultaneously without stashing
or switching.

### Basic Worktree Commands

```bash
# Create new worktree
wt new feature-xyz       # Create worktree for new branch
wtn experiment          # Quick alias

# List worktrees
wt list                 # Show all worktrees
wtl                     # Quick alias

# Switch between worktrees
wt switch main          # Switch to main worktree
wts feature-xyz         # Quick alias

# Remove worktree
wt remove feature-xyz   # Remove worktree
wtr feature-xyz         # Quick alias

# Status across all worktrees
wt status               # Show status of all worktrees
wtst                    # Quick alias
```

### Advanced Worktree Features

```bash
# Create worktree from GitHub PR
wt pr 123               # Checkout PR #123 in new worktree

# Worktree dashboard (visual overview)
wt-dashboard            # Show all worktrees with stats

# Parallel operations
wt-status-all           # Status of all worktrees in parallel
```

### Worktree Best Practices

1. **One worktree per feature** - Keep work isolated
2. **Clean up regularly** - Remove merged worktrees
3. **Use descriptive names** - `fix-auth-bug` not `fix1`
4. **Keep main clean** - Never work directly in main worktree

## Identity Management

Manage multiple git identities for different projects/organizations.

### Setup Identities

Your identities are configured in the Nix configuration. Currently configured:

- **personal** - Your default identity

### Identity Commands

```bash
# Show current identity
gid                     # Display current git identity
git-identity current    # Full command

# List all identities
gid list               # Show all configured identities

# Switch identity
gid switch personal          # Switch globally
gid switch work --local      # Switch for current repo only

# Quick switches (if configured)
gid-personal           # Switch to personal identity
gid-work              # Switch to work identity
```

### Auto-switching

Identities automatically switch based on directory:

- `~/personal/` - Uses personal identity
- `~/src/work/` - Would use work identity (if configured)

## Claude Code Integration

Safe AI-assisted coding with automatic snapshots and worktree isolation.

### Basic Claude Commands

```bash
# Start Claude Code
claude                  # Run with safety checks
cc                      # Quick alias
claude --force          # Skip safety checks

# Claude in worktree
claude-wt new feature   # Create worktree and start Claude
ccn                     # Quick new session
ccx                     # Quick experiment

# Finish Claude session
claude-wt finish        # Complete session with options
ccf                     # Quick finish
```

### Claude Safety Features

1. **Automatic Snapshots** - Before each session
2. **Worktree Isolation** - Keep experiments separate
3. **Uncommitted Changes Warning** - Reminds you to commit
4. **Review Tools** - Easy change review

### Claude Workflow Example

```bash
# 1. Start a Claude session for a bug fix
ccn fix-memory-leak

# 2. Claude makes changes...

# 3. Review what changed
cc-review              # See changes
git diff               # Detailed diff

# 4. If good, commit
cc-commit              # Quick commit

# 5. If bad, undo
claude-undo            # Revert to snapshot

# 6. Finish session
claude-wt finish       # Choose: keep, merge, or archive
```

### Claude Monitoring

```bash
# Watch Claude's changes in real-time
claude-monitor         # Live update of changes

# List all Claude sessions
claude-wt list         # Show all Claude worktrees
ccl                    # Quick list

# Clean up old sessions
claude-wt clean        # Remove all Claude worktrees
ccc                    # Quick clean
```

## Aliases and Shortcuts

### Essential Git Aliases

```bash
# Status and info
g                      # git status
gs                     # git status
gss                    # git status -s (short)

# Adding files
ga                     # git add
gaa                    # git add --all
gap                    # git add --patch (interactive)

# Committing
gc                     # git commit
gcm                    # git commit -m
gca                    # git commit --amend
gcan                   # git commit --amend --no-edit

# Pushing/Pulling
gp                     # git push
gpf                    # git push --force-with-lease
gpl                    # git pull
gplr                   # git pull --rebase

# Branches
gb                     # git branch
gba                    # git branch -a (all)
gbd                    # git branch -d (delete)
gco                    # git checkout
gcob                   # git checkout -b (new branch)

# Logs
glog                   # git log --oneline --graph
gloga                  # git log --oneline --graph --all
```

### Conventional Commits

```bash
feat "Add user authentication"     # Feature commit
fix "Resolve memory leak"          # Bug fix
docs "Update README"                # Documentation
style "Format code"                 # Code style
refactor "Extract utils"           # Refactoring
test "Add unit tests"               # Tests
chore "Update dependencies"        # Maintenance
```

### Quick Actions

```bash
# Save work quickly
gwip                   # Stage and commit as WIP
gsave                  # Stage all and save
save                   # Quick save everything

# Undo operations
undo                   # Undo last commit (keep changes)
uncommit               # Soft reset last commit
unadd                  # Unstage files

# Maintenance
cleanup                # Remove merged branches
optimize               # Run git gc and prune
```

## Advanced Tools

### LazyGit

```bash
lg                     # Launch lazygit
lazy                   # Alternative alias
git lazy               # Git alias
```

**Features:**

- Visual git interface
- Interactive staging
- Easy rebasing
- Conflict resolution

### Tig

```bash
tig                    # Launch tig
tig status             # Status view
tig blame file.txt     # Blame view
tig log                # Log view
```

### Git Extras

Includes many additional git commands:

```bash
git ignore python      # Add Python gitignore
git info               # Repository information
git authors            # List contributors
git changelog          # Generate changelog
```

### Git Absorb

Automatically create fixup commits:

```bash
git absorb             # Auto-create fixup commits
absorb                 # Quick alias
```

## Helix Integration

Quick commands to open files in Helix based on git status:

```bash
hxm                    # Edit modified files
hxc                    # Edit conflicted files
hxs                    # Edit staged files
hxu                    # Edit untracked files
```

**Note:** These commands don't work in Nushell due to command substitution
limitations.

## GitHub Integration

### Pull Requests

```bash
# Create PR
gh pr create           # Interactive PR creation
pr-new                 # Create with template

# Review PR
pr-review 123          # Review PR #123 locally
gh pr checkout 123     # Checkout PR

# List PRs
gh pr list             # List all PRs
pr-mine                # List your PRs
```

### Issues

```bash
gh issue create        # Create issue
gh issue list          # List issues
gh issue view 456      # View issue #456
```

## Troubleshooting

### Common Issues

**Issue:** Worktree commands not working

```bash
# Ensure you're in a git repository
git rev-parse --git-dir

# Check worktree list
git worktree list
```

**Issue:** Identity not switching

```bash
# Check current identity
git config user.email

# Force identity switch
gid switch personal --local
```

**Issue:** Claude snapshots filling up space

```bash
# List snapshots
git tag -l 'claude-snapshot-*'

# Clean old snapshots
git tag -l 'claude-snapshot-*' | head -n -5 | xargs git tag -d
```

**Issue:** Aliases not working in Nushell

- Many aliases with `&&` or `$()` don't work in Nushell
- Use the git aliases instead: `git save` instead of `gsave`
- Or switch to bash/zsh temporarily

### Getting Help

```bash
# Interactive help
git-help menu          # Full help system
?                      # Quick menu

# Section-specific help
?wt                    # Worktree help
?id                    # Identity help
?gh                    # GitHub help
?claude                # Claude help
```

## Configuration Files

Key configuration files generated:

- `~/.config/git/config` - Main git config
- `~/.config/git/identity-*` - Per-identity configs
- `~/.config/git/allowed_signers` - SSH signing keys
- `~/.config/claude-code/` - Claude configuration

## Tips and Tricks

1. **Use worktrees liberally** - They're cheap and keep work isolated
2. **Set up identity early** - Avoid committing with wrong email
3. **Use Claude in worktrees** - Never in main branch
4. **Regular cleanup** - Run `cleanup` weekly
5. **Learn the shortcuts** - `g`, `ga`, `gc`, `gp` save time
6. **Use conventional commits** - `feat`, `fix`, `docs` for clarity
7. **Review before pushing** - `gd` and `glog` are your friends

---

_For more help, run `git-help` or check the [documentation](../README.md)._
