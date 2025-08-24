# 🔧 Git Suite - Advanced Git Configuration

> **Purpose:** Comprehensive git configuration with AI safety features and
> advanced workflows  
> **Type:** Feature Suite  
> **Status:** Stable

## Overview

The Git Suite provides a powerful, modular git configuration system with
advanced features for modern development workflows. It includes worktree
management, multi-identity support, AI-assisted coding safety features, and
extensive productivity enhancements.

## Quick Start

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

# Advanced features
wtn feature     # Create new worktree
gid switch work # Switch identity
claude          # Start AI session safely
```

## What's Inside

| Module            | Purpose                     | Key Features                     |
| ----------------- | --------------------------- | -------------------------------- |
| `default.nix`     | Module orchestration        | Imports all submodules           |
| `core.nix`        | Essential git configuration | Performance, defaults, behavior  |
| `aliases.nix`     | Productivity aliases        | 100+ shortcuts and commands      |
| `worktree.nix`    | Worktree management         | Parallel development workflows   |
| `identities.nix`  | Multi-identity support      | Auto-switching, SSH signing      |
| `claude-code.nix` | AI coding safety            | Snapshots, isolation, monitoring |
| `github.nix`      | GitHub integration          | PR management, issue tracking    |
| `helix.nix`       | Editor integration          | Quick file access by status      |
| `tools.nix`       | Additional git tools        | LazyGit, Tig, git-absorb, delta  |
| `prompts.nix`     | Shell prompt integration    | Git status in prompt             |
| `help.nix`        | Interactive help system     | Context-aware documentation      |

## Core Features

### 🎯 Smart Defaults (`core.nix`)

Optimized git configuration:

- **Performance** - Parallel operations, aggressive caching
- **Safety** - Auto-correction with delay, safe force push
- **UI** - Delta for beautiful diffs, color output
- **SSH Signing** - Automatic commit verification

### 🚀 Productivity Aliases (`aliases.nix`)

Over 100 aliases organized by category:

```bash
# Status shortcuts
g, gs, gss          # Various status formats

# Commit helpers
gc, gcm, gca        # Commit variations
feat, fix, docs     # Conventional commits

# Branch operations
gb, gco, gcob       # Branch management
gm, gmm, gmt        # Merge operations

# History viewing
glog, gloga         # Graph logs
gshow, gdiff        # Inspection
```

### 🌳 Worktree Management (`worktree.nix`)

Advanced parallel development:

```bash
# Core worktree operations
wtn feature         # Create new worktree
wtl                 # List worktrees
wts main           # Switch to worktree
wtr feature        # Remove worktree

# Advanced features
wt pr 123          # Checkout PR in worktree
wt-dashboard       # Visual overview
wt-status-all      # Parallel status check

# Templates (customizable)
wt template experiment  # Create from template
```

### 👤 Identity Management (`identities.nix`)

Multi-identity with auto-switching:

```bash
# Identity operations
gid                # Show current identity
gid list           # List all identities
gid switch work    # Switch identity

# Auto-switching by directory
~/personal/        # → personal identity
~/work/           # → work identity
```

### 🤖 Claude Code Integration (`claude-code.nix`)

AI-assisted coding with safety:

```bash
# Basic usage
claude             # Start with safety checks
cc                 # Quick alias
claude --force     # Skip checks (careful!)

# Worktree workflow
ccn fix-bug        # New worktree + Claude
ccx                # Quick experiment
ccf                # Finish and review

# Monitoring
claude-monitor     # Live change tracking
cc-review         # Review all changes
claude-undo       # Revert to snapshot
```

**Safety Features:**

- Automatic snapshots before sessions
- Worktree isolation for experiments
- Uncommitted changes warnings
- Easy rollback options

### 🐙 GitHub Integration (`github.nix`)

Seamless GitHub workflow:

```bash
# Pull requests
gh pr create       # Create PR
pr-review 123      # Review PR locally
pr-mine           # List your PRs

# Issues
gh issue create    # Create issue
gh issue list     # List issues

# Releases
gh release create  # Create release
```

### 🛠️ Additional Tools (`tools.nix`)

Power tools for git:

- **LazyGit** (`lg`) - Visual git interface
- **Tig** (`tig`) - Text-mode interface
- **Delta** - Beautiful diffs (auto-configured)
- **Git-Absorb** (`absorb`) - Auto-fixup commits
- **Git-Extras** - Additional git commands

## Workflows

### Basic Development Flow

```bash
# 1. Start feature
wtn feature-name

# 2. Make changes
hx file.txt        # Edit with Helix
ga .              # Stage changes
gc -m "Add feature" # Commit

# 3. Push and create PR
gp -u origin HEAD
gh pr create

# 4. Clean up
wts main
wtr feature-name
```

### AI-Assisted Development

```bash
# 1. Start Claude session
ccn fix-memory-leak

# 2. Let Claude work...

# 3. Review changes
cc-review
git diff

# 4. If good, commit
ga .
gc -m "Fix memory leak"

# 5. Finish
ccf  # Choose: keep, merge, or discard
```

### Multi-Identity Workflow

```bash
# Check identity before starting
gid

# Switch if needed
gid switch work --local

# Or use directory-based auto-switching
cd ~/work/project
# Identity switches automatically
```

## Configuration

### Customizing Aliases

Edit `nix/home/git/aliases.nix`:

```nix
programs.git.aliases = {
  myalias = "status --short";
};
```

### Adding Identities

Edit your host configuration:

```nix
programs.git.identities = {
  work = {
    email = "you@company.com";
    name = "Your Name";
    sshKey = "~/.ssh/id_work";
  };
};
```

### Worktree Templates

Create custom templates in `~/.config/git/worktree-templates/`:

```bash
# ~/.config/git/worktree-templates/experiment
#!/bin/bash
echo "Setting up experiment worktree..."
npm install
npm test
```

## Troubleshooting

### Nushell Compatibility

Some aliases don't work in Nushell due to syntax differences:

- Use `;` instead of `&&`
- No command substitution in aliases
- Use git aliases directly: `git save` instead of `gsave`

### Worktree Issues

```bash
# Fix broken worktree
git worktree prune

# List and clean
git worktree list
git worktree remove --force path
```

### Identity Not Switching

```bash
# Check current config
git config user.email

# Force local switch
gid switch personal --local

# Verify
gid
```

### Claude Snapshots

```bash
# List snapshots
git tag -l 'claude-snapshot-*'

# Clean old snapshots
git tag -l 'claude-snapshot-*' | head -n -5 | xargs git tag -d
```

## Tips & Best Practices

1. **Use worktrees liberally** - They're cheap and prevent context switching
2. **Commit often** - Small, focused commits are easier to review
3. **Use conventional commits** - `feat`, `fix`, `docs` for clarity
4. **Review before pushing** - `gd` and `glog` are your friends
5. **Keep main clean** - Always work in feature branches/worktrees
6. **Use Claude in isolation** - Always in worktrees, never in main
7. **Clean up regularly** - Run `cleanup` weekly

## See Also

- **[Git Suite User Guide](../../../docs/guides/git-suite.md)** - Comprehensive
  usage guide
- **[Home Modules](../)** - Parent module directory
- **[Shell Configuration](../shells/)** - Shell integration
- **[Development Tools](../devtools/)** - Language-specific tools

---

_The Git Suite transforms git from a tool into a productivity multiplier._
