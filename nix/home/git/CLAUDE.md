# 🔧 Git Suite Module - Claude Context

## Module Purpose

Advanced git configuration with worktree management, multi-identity support, and
AI-assisted coding safety features.

## Key Files

- `default.nix` - Main module entry point and imports
- `core.nix` - Git configuration and settings
- `aliases.nix` - Shell-specific git aliases
- `worktree.nix` - Worktree management commands
- `identities.nix` - Multi-identity configuration
- `claude-code.nix` - Claude Code integration and safety
- `claude-enhanced.nix` - Additional Claude features
- `github.nix` - GitHub CLI integration
- `tools.nix` - Additional git tools (lazygit, tig, etc.)
- `help.nix` - Interactive help system

## Common Tasks

### Adding New Git Aliases

```nix
# In aliases.nix, add to programs.git.aliases
newAlias = "status --short";

# For shell-specific (Nushell compatibility)
programs.bash.shellAliases = mkIf config.programs.bash.enable {
  gwip = "git add -u && git commit -m 'WIP'";
};
programs.nushell.shellAliases = mkIf config.programs.nushell.enable {
  gwip = "git add -u; git commit -m 'WIP'";  # Note: semicolon not &&
};
```

### Adding Worktree Features

```nix
# In worktree.nix, add to worktreeCommands
wt-new-feature = pkgs.writeShellScriptBin "wt-new-feature" ''
  # Implementation
'';
```

### Configuring New Identity

```nix
# In host configuration, not in module
programs.git.identities.work = {
  name = "Your Name";
  email = "you@company.com";
  signingKey = "~/.ssh/id_work";
};
```

## Testing Changes

```bash
# After modifying git configuration
./scripts/validate.sh
./scripts/rebuild.sh test

# Test specific features
g  # Should show git status
wtn test-branch  # Should create worktree
gid  # Should show current identity
```

## Module Patterns

### Shell Compatibility

- Nushell doesn't support `&&` - use `;` instead
- Nushell doesn't support `$()` - use custom commands
- Complex aliases should be git aliases, not shell aliases

### Safety Checks

Claude wrapper includes:

1. Git repository check
2. Worktree detection
3. Uncommitted changes warning
4. Automatic snapshots
5. Force flag support

## Common Issues

### Alias Not Working in Nushell

```bash
# Check if it's a shell alias with && or $()
# Convert to git alias or Nushell custom command
```

### Worktree Commands Missing

```bash
# Ensure worktree.nix is enabled
programs.gitWorktree.enable = true;
```

### Identity Not Switching

```bash
# Check includeIf paths match
git config --list | grep includeif
```

## Key Commands Available

- `wtn` - New worktree
- `wtl` - List worktrees
- `wts` - Switch worktree
- `wtr` - Remove worktree
- `gid` - Show/switch identity
- `claude` / `cc` - Claude Code wrapper
- `ccn` - Claude in new worktree
- `git-help` - Interactive help

## Safety Notes

- Never modify this module while Claude is running
- Test identity switching in a test repo first
- Worktree operations are non-destructive
- Claude snapshots can be cleaned with tag cleanup

---

_This module is the heart of the development workflow - handle with care._
