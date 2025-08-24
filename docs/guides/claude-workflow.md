# 🤖 Claude Code Workflow Guide

This guide explains how to effectively use Claude Code with the Fern NixOS
configuration, leveraging the CLAUDE.md files and integration features.

## Table of Contents

1. [Overview](#overview)
2. [Getting Started](#getting-started)
3. [Development Workflows](#development-workflows)
4. [Safety Features](#safety-features)
5. [Using CLAUDE.md Files](#using-claudemd-files)
6. [Templates and Automation](#templates-and-automation)
7. [Best Practices](#best-practices)
8. [Troubleshooting](#troubleshooting)

## Overview

The Fern configuration includes comprehensive Claude integration:

- **CLAUDE.md files** - Context files throughout the repository
- **Safety wrappers** - Git worktree isolation and snapshots
- **Automation scripts** - Validation and rebuild tools
- **Templates** - Reusable code patterns
- **Prompts** - Structured task guides

## Getting Started

### Initial Setup

1. **Review context files:**

   ```bash
   # Main context
   cat CLAUDE.md

   # Module-specific context
   find . -name "CLAUDE.md" -type f
   ```

2. **Check available commands:**

   ```bash
   # Claude wrapper commands
   which claude    # Main wrapper
   which cc        # Quick alias
   which ccn       # New worktree session
   ```

3. **Verify git configuration:**
   ```bash
   gid            # Check identity
   git status     # Check repository state
   ```

## Development Workflows

### Standard Development Flow

1. **Start Claude in a worktree:**

   ```bash
   ccn feature-name
   # This creates a new worktree and starts Claude
   ```

2. **Work with Claude:**

   - Claude has access to all CLAUDE.md files
   - Automatic snapshots are created
   - Changes are isolated in the worktree

3. **Review changes:**

   ```bash
   git diff       # See what changed
   cc-review      # Comprehensive review
   ```

4. **Complete the session:**
   ```bash
   ccf            # Finish and choose action
   ```

### Quick Fix Workflow

For small changes:

```bash
# Create worktree
wtn quick-fix

# Start Claude
claude

# Make changes...

# Review and commit
git diff
ga .
gc -m "fix: Resolve issue"

# Merge or create PR
wts main
gm quick-fix
```

### Module Development Workflow

When adding new modules:

1. **Use templates:**

   ```bash
   cp .claude/templates/nix-module.nix nix/modules/new-feature.nix
   ```

2. **Register module:**

   - Add to `flake.parts/20-nixos-mods.nix` or `30-home-mods.nix`

3. **Test incrementally:**
   ```bash
   ./scripts/validate.sh
   ./scripts/rebuild.sh test
   ```

## Safety Features

### Automatic Snapshots

Before each Claude session:

```bash
# Snapshot created automatically
git tag -l 'claude-snapshot-*'

# Manual snapshot
git tag -a "manual-snapshot-$(date +%Y%m%d)" -m "Manual snapshot"
```

### Worktree Isolation

Changes are isolated:

```bash
# Check worktree status
wt-status-all

# List all worktrees
wtl
```

### Validation Scripts

Always validate before rebuilding:

```bash
# Full validation
./scripts/validate.sh

# Quick validation
nix flake check
```

### Rollback Options

If something goes wrong:

```bash
# Git rollback
claude-undo           # Revert to snapshot
git reset --hard HEAD # Discard changes

# System rollback
sudo nixos-rebuild --rollback switch
```

## Using CLAUDE.md Files

### Root CLAUDE.md

The main context file provides:

- Project overview
- Quick commands reference
- Code conventions
- Safety rules
- Directory structure
- Common patterns

### Module-Specific CLAUDE.md

Each major module has context:

- `/nix/home/git/CLAUDE.md` - Git suite specifics
- `/nix/modules/CLAUDE.md` - System module patterns
- `/scripts/CLAUDE.md` - Script documentation

### How Claude Uses These Files

1. **Automatic context** - Claude reads relevant CLAUDE.md files
2. **Pattern following** - Uses established conventions
3. **Command awareness** - Knows available commands
4. **Safety compliance** - Follows documented rules

## Templates and Automation

### Using Templates

```bash
# List available templates
ls .claude/templates/

# Use template for new module
cp .claude/templates/nix-module.nix nix/home/new-feature.nix
# Replace MODULE_NAME placeholders
```

### Using Prompts

```bash
# Code review
cat .claude/prompts/review-changes.md

# Debug assistance
cat .claude/prompts/debug-nix-error.md
```

### Using Hooks

```bash
# Run pre-rebuild checks
.claude/hooks/pre-rebuild.sh

# Integrate into workflow
alias rebuild='.claude/hooks/pre-rebuild.sh && ./scripts/rebuild.sh'
```

## Best Practices

### 1. Always Work in Worktrees

```bash
# Good
ccn feature    # Claude in new worktree
wtn experiment # Manual worktree

# Bad
claude         # In main branch (avoid!)
```

### 2. Validate Before Building

```bash
# Good workflow
./scripts/validate.sh && ./scripts/rebuild.sh test

# Bad workflow
sudo nixos-rebuild switch  # No validation!
```

### 3. Keep CLAUDE.md Updated

When adding new patterns:

1. Update relevant CLAUDE.md
2. Document new commands
3. Add safety notes

### 4. Use Conventional Commits

```bash
feat: Add new feature
fix: Resolve bug
docs: Update documentation
chore: Maintenance task
refactor: Code improvement
```

### 5. Regular Cleanup

```bash
# Clean old worktrees
wt-clean

# Clean old snapshots
git tag -l 'claude-snapshot-*' | head -n -10 | xargs git tag -d

# Garbage collection
nix-collect-garbage -d
```

## Common Claude Tasks

### Adding a Package

```markdown
Please add package [name] to the system. It should be:

- Added to the appropriate module
- Configured with sensible defaults
- Tested with rebuild test
```

### Fixing an Error

```markdown
I'm getting this error: [paste error] Please help debug and fix it following the
patterns in CLAUDE.md
```

### Creating a Module

```markdown
Create a new [home/system] module for [feature] that:

- Follows the module pattern in templates
- Is properly registered in flake.parts
- Includes enable option
- Has sensible defaults
```

### Reviewing Changes

```markdown
Please review my recent changes using the checklist in
.claude/prompts/review-changes.md
```

## Troubleshooting

### Claude Can't Find Commands

```bash
# Check PATH
echo $PATH

# Source configuration
source ~/.bashrc  # or appropriate shell

# Check alias
alias | grep command-name
```

### Worktree Issues

```bash
# Fix locked worktree
git worktree prune

# Remove broken worktree
git worktree remove --force path
```

### Module Not Loading

```bash
# Check registration
grep "module-name" flake.parts/*.nix

# Check import
grep "module-name" hosts/fern/configuration.nix
```

### Validation Failures

```bash
# Detailed error
sudo nixos-rebuild test --flake .#fern --show-trace

# Check specific module
nix eval .#nixosConfigurations.fern.config.programs.module
```

## Advanced Integration

### Custom Claude Commands

Add to git configuration:

```nix
# In git/claude-code.nix
claude-custom = pkgs.writeShellScriptBin "claude-custom" ''
  # Your custom Claude integration
'';
```

### Project-Specific Context

Add to CLAUDE.md:

```markdown
## Project-Specific Patterns

- Always use [pattern]
- Never do [anti-pattern]
- Prefer [approach]
```

### Automated Workflows

Create in scripts:

```bash
#!/usr/bin/env bash
# scripts/claude-task.sh
ccn task-name
# Automated setup...
```

## Tips for Effective Claude Use

1. **Be specific** - Reference file paths and module names
2. **Provide context** - Mention relevant CLAUDE.md sections
3. **Use examples** - Show what you want
4. **Check safety** - Run validation scripts
5. **Test incrementally** - Use `test` before `switch`
6. **Document changes** - Update CLAUDE.md when needed

## Conclusion

The Claude integration in Fern makes AI-assisted development:

- **Safe** - Through worktrees and snapshots
- **Efficient** - With templates and automation
- **Consistent** - Using documented patterns
- **Reliable** - With validation and testing

Remember: Claude is a tool to enhance your workflow, not replace careful
thinking. Always review changes and test thoroughly.

---

_For more information, see the [main documentation](../README.md) and
[git suite guide](./git-suite.md)._
