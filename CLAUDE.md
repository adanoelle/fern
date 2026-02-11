# 🤖 Claude Code Context - Fern NixOS Configuration

## Project Overview

This is a comprehensive NixOS configuration using flakes, Home Manager, and a
modular architecture. The system is designed for a development workstation with
Hyprland, advanced git workflows, and multiple language toolchains.

## Quick Commands

### Essential Operations

```bash
# All common operations are available via just (inside devShell)
just              # list all recipes
just switch       # rebuild and switch
just test         # test without switching
just test-trace   # test with --show-trace
just dry          # dry-build only
just rollback     # rollback to previous generation
just update       # update flake inputs
just fmt          # format Nix files
just check        # nix flake check
just lint         # format then check
just gc           # garbage-collect old generations
```

### Documentation

```bash
# Serve with live reload + open browser
just book-serve

# Build to book/build/
just book-build

# Pure Nix build
just book-nix

# Dev shell with repo tools (just, mdbook, nixpkgs-fmt)
direnv allow       # one-time; auto-activates via .envrc
# or: nix develop
```

### Development Workflow

```bash
# Start a Claude session in worktree
ccn feature-name

# Check what changed
git status
git diff

# Commit changes
ga .
gc -m "feat: Add new feature"

# View system logs
journalctl -b -u service-name

# Check rebuild output
sudo nixos-rebuild test --flake .#fern --show-trace
```

## Code Conventions

### Nix Style Guide

1. **Module Structure**

   ```nix
   { config, lib, pkgs, ... }:
   let
     cfg = config.programs.moduleName;
   in
   {
     options.programs.moduleName = { ... };
     config = lib.mkIf cfg.enable { ... };
   }
   ```

2. **Best Practices**

   - Use `mkIf` for conditional configuration
   - Prefer `mkDefault` over direct assignment for overrideable values
   - Use `mkForce` only when absolutely necessary
   - Reference modules via `self.nixosModules.name` or `self.homeModules.name`
   - Group related configuration together

3. **Naming Conventions**
   - System modules: `nix/modules/category/name.nix`
   - Home modules: `nix/home/category/name.nix`
   - Use descriptive names: `audio.nix` not `aud.nix`
   - Dash-separate compound names: `claude-code.nix`

## Safety Rules

### ⚠️ CRITICAL - Always Follow

1. **NEVER** modify hardware-configuration.nix directly
2. **NEVER** work directly in the main branch - use worktrees
3. **ALWAYS** run `nix flake check` before rebuilding
4. **ALWAYS** test with `nixos-rebuild test` before switching
5. **ALWAYS** format code with `nixpkgs-fmt` before committing
6. **ALWAYS** check for uncommitted changes before major operations
7. **NEVER** use `sudo` with git commands
8. **ALWAYS** create snapshots before AI-assisted sessions

### Pre-Rebuild Checklist

- [ ] Run `nix flake check`
- [ ] Format with `nixpkgs-fmt .`
- [ ] Test with `sudo nixos-rebuild test --flake .#fern`
- [ ] Check logs if test fails: `journalctl -xe`
- [ ] Commit working configuration before switching

## Directory Structure

```
fern/
├── CLAUDE.md           # This file
├── README.md           # Main documentation
├── justfile           # Command recipes (primary interface)
├── flake.nix          # Flake definition
├── flake.lock         # Pinned dependencies
├── flake.parts/       # Modular flake organization
│   ├── 00-overlay.nix
│   ├── 10-core.nix
│   ├── 20-nixos-mods.nix
│   ├── 30-home-mods.nix
│   ├── 40-hosts.nix
│   ├── 50-dev.nix
│   └── 60-docs.nix
├── hosts/             # Machine configurations
│   └── fern/          # Primary workstation
├── nix/               # All modules
│   ├── home/          # Home Manager modules
│   │   ├── cli.nix
│   │   ├── git/       # Git suite
│   │   ├── desktop/   # Hyprland environment
│   │   ├── devtools/  # Language toolchains
│   │   └── shells/    # Shell configs
│   └── modules/       # System modules
│       ├── core.nix
│       ├── boot.nix
│       └── ...
├── book/              # mdBook documentation
├── docs/              # Documentation
└── secrets/           # SOPS-encrypted secrets
```

## Common Patterns

### Adding a New System Module

1. Create module file: `nix/modules/category/name.nix`
2. Register in `flake.parts/20-nixos-mods.nix`
3. Import in `hosts/fern/configuration.nix`
4. Enable and configure
5. Test and commit

### Adding a New Home Module

1. Create module file: `nix/home/category/name.nix`
2. Register in `flake.parts/30-home-mods.nix`
3. Import in home-manager configuration
4. Enable and configure
5. Test and commit

### Creating a Package Override

```nix
# In flake.parts/10-overlays.nix
(final: prev: {
  packageName = prev.packageName.override {
    someOption = true;
  };
})
```

## Language-Specific Notes

### Working with Nix

- The system uses Nix flakes (experimental feature)
- Home Manager is integrated via NixOS module
- Overlays are applied for Rust and Zig
- Binary cache can be configured for faster builds

### Primary Technologies

- **Shell**: Nushell (with Bash/Zsh compatibility)
- **Editor**: Helix (with LSP configuration)
- **Desktop**: Hyprland (Wayland compositor)
- **Terminal**: Ghostty
- **Git**: Enhanced with worktrees and AI safety

## Troubleshooting Patterns

### Build Failures

```bash
# Get detailed error
sudo nixos-rebuild test --flake .#fern --show-trace

# Check specific module evaluation
nix eval .#nixosConfigurations.fern.config.programs.git

# Clean and retry
nix-collect-garbage -d
nix flake update
```

### Module Not Found

```bash
# List available modules
nix eval .#nixosModules --apply builtins.attrNames
nix eval .#homeModules --apply builtins.attrNames

# Check module registration
grep "moduleName" flake.parts/*.nix
```

### Configuration Conflicts

```bash
# Find duplicate definitions
grep -r "programs.thing" nix/

# Check for infinite recursion
nix eval .#nixosConfigurations.fern --show-trace
```

## Testing Commands

### System Testing

```bash
# Dry run
sudo nixos-rebuild dry-build --flake .#fern

# Build VM for testing
nixos-rebuild build-vm --flake .#fern
./result/bin/run-fern-vm

# Check service status
systemctl status service-name
journalctl -u service-name -f
```

### Validation

```bash
# Nix syntax check
nix flake check

# Format check
nixpkgs-fmt --check .

# Linting (if statix installed)
statix check

# Dead code detection (if deadnix installed)
deadnix .
```

## Git Workflow Integration

### Worktree Operations

```bash
# Create worktree for feature
wtn feature-name

# Start Claude in worktree
claude  # Or: cc

# Review changes
git diff
git status

# Finish worktree
wts main
wtr feature-name
```

### Identity Management

```bash
# Check current identity
gid

# Switch for this repo
gid switch personal --local
```

## Performance Tips

1. Use `--show-trace` only when debugging
2. Enable binary cache for faster rebuilds
3. Use `nixos-rebuild test` for quick iteration
4. Keep generations clean with regular garbage collection
5. Use worktrees to parallelize development

## Important Files to Never Modify

- `hardware-configuration.nix` - Auto-generated hardware config
- `flake.lock` - Only update via `nix flake update`
- Files in `secrets/` - Use SOPS for editing

## Useful Aliases Available

- `g` - git status
- `ga` - git add
- `gc` - git commit
- `gp` - git push
- `wtn` - new worktree
- `ccn` - Claude in new worktree
- `hx` - Helix editor

## When Working on This Project

1. Understand the modular structure
2. Follow existing patterns
3. Test changes incrementally
4. Document new modules
5. Keep commits atomic and descriptive
6. Use conventional commits (feat, fix, docs, etc.)

---

_This file helps Claude understand your project. Keep it updated as conventions
evolve._
