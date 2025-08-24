# Fern NixOS Architecture

## Overview

Fern is a modular NixOS configuration designed for developer productivity,
featuring advanced git tooling, multi-language development support, and a
customized Hyprland desktop environment.

## Design Principles

1. **Modularity** - Each feature is a separate module that can be
   enabled/disabled
2. **Composability** - Modules can be combined to create different
   configurations
3. **Reproducibility** - Same inputs always produce the same system
4. **Documentation** - Every module should be self-documenting
5. **Safety** - Changes should be testable before applying

## System Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     Flake (flake.nix)                   │
│  Entry point - defines inputs, outputs, and structure   │
└────────────────┬────────────────────────────────────────┘
                 │
                 ├── flake.parts/
                 │   ├── 00-overlay.nix     # Package overlays
                 │   ├── 10-core.nix        # Core configuration
                 │   ├── 20-nixos-mods.nix  # NixOS modules
                 │   ├── 30-home-mods.nix   # Home modules
                 │   └── 40-hosts.nix       # Host definitions
                 │
    ┌────────────┴────────────┬──────────────────────┐
    │                         │                      │
┌───▼──────┐          ┌───────▼──────┐      ┌───────▼──────┐
│  hosts/  │          │ nix/modules/ │      │  nix/home/   │
│          │          │              │      │              │
│ Machine  │          │   System     │      │    User      │
│ configs  │          │   modules    │      │   modules    │
└──────────┘          └──────────────┘      └──────────────┘
```

## Module Organization

### System Modules (`nix/modules/`)

System-level configuration that affects the entire NixOS installation:

```
modules/
├── core.nix           # Nix daemon settings
├── boot.nix           # Bootloader and kernel
├── audio.nix          # PipeWire configuration
├── graphics.nix       # GPU and display
├── fonts.nix          # System fonts
├── secrets.nix        # SOPS-nix integration
├── users.nix          # User accounts
├── desktop/           # Desktop services
│   ├── greetd.nix     # Display manager
│   ├── claude.nix     # Claude Desktop
│   └── ...
├── devtools/          # Development tools
│   ├── docker.nix     # Container runtime
│   ├── rust.nix       # Rust toolchain
│   └── ...
└── cloud/             # Cloud tools
    └── aws-cli.nix    # AWS CLI
```

### User Modules (`nix/home/`)

User-specific configuration managed by Home Manager:

```
home/
├── cli.nix            # CLI tools orchestrator
├── cli/               # Individual CLI tools
│   ├── bat.nix        # Better cat
│   ├── helix.nix      # Text editor
│   └── ...
├── desktop.nix        # Desktop orchestrator
├── desktop/           # Desktop components
│   ├── hyprland/      # Wayland compositor
│   ├── chromium.nix   # Web browser
│   └── ...
├── devtools.nix       # Dev tools orchestrator
├── devtools/          # Language support
│   ├── python.nix     # Python environment
│   ├── rust.nix       # Rust environment
│   └── ...
├── git.nix            # Git orchestrator
├── git/               # Git modules
│   ├── core.nix       # Core git config
│   ├── worktree.nix   # Worktree management
│   ├── identities.nix # Multi-identity
│   └── ...
├── shells.nix         # Shell orchestrator
└── shells/            # Shell configs
    ├── nushell.nix    # Nushell config
    ├── starship.nix   # Prompt
    └── zoxide.nix     # Directory jumper
```

## Module Types

### 1. Orchestrator Modules

Files like `cli.nix`, `desktop.nix`, `git.nix` that:

- Import related modules
- Provide high-level configuration interface
- Coordinate between modules

Example: `nix/home/git.nix`

```nix
{
  imports = [
    ./git/core.nix
    ./git/aliases.nix
    ./git/worktree.nix
    # ...
  ];
}
```

### 2. Feature Modules

Individual features with their own options and configuration:

Example structure:

```nix
{ config, lib, pkgs, ... }:
let
  cfg = config.programs.myFeature;
in
{
  options.programs.myFeature = {
    enable = mkEnableOption "My feature";
    # ... other options
  };

  config = mkIf cfg.enable {
    # ... implementation
  };
}
```

### 3. Configuration Modules

Host-specific configurations that tie everything together:

Example: `hosts/fern/configuration.nix`

- Imports system modules
- Imports Home Manager
- Sets host-specific options

## Data Flow

```
1. User runs: sudo nixos-rebuild switch --flake .#fern
                │
2. Nix evaluates flake.nix
                │
3. Flake imports flake.parts/*
                │
4. Host configuration loaded (hosts/fern/)
                │
5. System modules evaluated (nix/modules/)
                │
6. Home Manager modules evaluated (nix/home/)
                │
7. Configuration built and activated
```

## Key Design Decisions

### 1. Flake-parts for Organization

Using `flake-parts` to split the flake into manageable pieces:

- Overlays in separate file
- Module definitions organized
- Host definitions isolated

### 2. Module Enablement Pattern

Modules follow consistent patterns:

```nix
programs.thing.enable = true;  # User modules
services.thing.enable = true;  # System services
```

### 3. Configuration Hierarchy

```
gitSuite (top-level)
  ├── gitCore (essential)
  ├── gitWorktree (features)
  ├── gitIdentities (features)
  └── gitClaudeCode (optional)
```

### 4. Shell Compatibility

Different implementations for different shells:

- `programs.bash.shellAliases`
- `programs.zsh.shellAliases`
- `programs.nushell.shellAliases`

## Extension Points

### Adding a New System Module

1. Create `nix/modules/myfeature.nix`
2. Add to `flake.parts/20-nixos-mods.nix`
3. Import in host configuration

### Adding a New User Module

1. Create `nix/home/myfeature.nix`
2. Add to `flake.parts/30-home-mods.nix`
3. Import in Home Manager configuration

### Adding a New Host

1. Create `hosts/newhost/configuration.nix`
2. Add to `flake.parts/40-hosts.nix`
3. Build with `--flake .#newhost`

## Dependencies

### External Flakes

- **nixpkgs** - Package repository
- **home-manager** - User configuration
- **flake-parts** - Flake organization
- **rust-overlay** - Rust toolchain
- **zig-overlay** - Zig toolchain
- **sops-nix** - Secret management
- **devenv** - Development environments
- **claude-desktop** - Claude Desktop app

### Package Overlays

Applied in `flake.parts/00-overlay.nix`:

- Custom packages
- Package modifications
- Version overrides

## Security Model

### Secret Management

Using SOPS-nix with age encryption:

- Secrets stored encrypted in repo
- Decrypted at activation time
- Per-host key management

### SSH Key Management

- SSH keys for git signing
- Managed through SOPS
- Automatic configuration

## Performance Considerations

### Build Time Optimization

- Local binary cache
- Substituters configured
- Parallel builds enabled

### Runtime Optimization

- Garbage collection automated
- Store optimization scheduled
- Unused packages removed

## Testing Strategy

### Levels of Testing

1. **Syntax Check** - `nix flake check`
2. **Dry Build** - `nixos-rebuild dry-build`
3. **Test Build** - `nixos-rebuild test`
4. **Full Switch** - `nixos-rebuild switch`

### Rollback Strategy

- Generations preserved
- Easy rollback command
- Automatic rollback on failure (planned)

## Future Considerations

### Planned Improvements

1. **CI/CD Pipeline** - Automated testing
2. **Binary Cache** - Shared build cache
3. **Multi-host** - Support for multiple machines
4. **Secrets Rotation** - Automated key rotation
5. **Monitoring** - System observability

### Potential Refactors

1. **Module Extraction** - Move complex modules to separate flakes
2. **Profile System** - Predefined configuration profiles
3. **Plugin System** - Dynamic module loading
4. **Template System** - Quick start templates

## Conventions

### Naming

- **Modules**: `camelCase` for options, `kebab-case` for files
- **Variables**: `camelCase` in Nix expressions
- **Scripts**: `kebab-case` for executables

### Documentation

- Every module should have a description
- Complex logic should be commented
- Examples provided where helpful

### Code Style

- Use `nixpkgs-fmt` for formatting
- Follow NixOS conventions
- Prefer explicit over implicit

---

_This architecture document is a living document and should be updated as the
system evolves._
