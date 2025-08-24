# 🏠 Home Modules - User Environment Configuration

> **Purpose:** User-level Home Manager modules for personal environment configuration  
> **Type:** User Configuration  
> **Status:** Stable

## Overview

This directory contains Home Manager modules that configure your personal user
environment. These modules manage everything from your shell and CLI tools to
your desktop environment and development setup, all without requiring root
privileges.

## Quick Start

```nix
# In your host configuration (hosts/fern/configuration.nix)
home-manager.users.ada = {
  imports = [
    self.homeModules.cli
    self.homeModules.git
    self.homeModules.desktop
  ];

  # Enable and configure
  programs.bat.enable = true;
  programs.git.enable = true;
};
```

## What's Inside

| Module/Directory | Purpose                            | Impact                       |
| ---------------- | ---------------------------------- | ---------------------------- |
| `cli.nix`        | Command-line tools collection      | Terminal productivity        |
| `git/`           | Advanced git configuration suite   | Git workflow enhancement     |
| `desktop/`       | Hyprland and desktop environment   | GUI and window management    |
| `devtools/`      | Development language toolchains    | Programming environments     |
| `shells/`        | Shell configurations (Nu/Bash/Zsh) | Interactive shell experience |
| `starship.nix`   | Cross-shell prompt                 | Terminal prompt              |
| `helix.nix`      | Helix editor configuration         | Primary text editor          |
| `ghostty.nix`    | Ghostty terminal emulator          | Terminal application         |

## Module Categories

### CLI Tools (`cli.nix`)

Essential command-line utilities:

- **File Management** - eza, fd, ripgrep, bat, broot
- **System Monitoring** - btop, procs, dust, duf
- **Development** - jq, yq, fzf, delta
- **Network** - httpie, curlie, dogdns
- **Productivity** - zoxide, atuin, tealdeer

### Git Suite (`git/`)

Comprehensive git configuration with advanced features:

- **`default.nix`** - Core git configuration and module orchestration
- **`core.nix`** - Essential git settings and performance tweaks
- **`aliases.nix`** - Extensive alias collection for productivity
- **`worktree.nix`** - Advanced worktree management system
- **`identities.nix`** - Multi-identity support with auto-switching
- **`claude-code.nix`** - AI-assisted coding safety features
- **`github.nix`** - GitHub CLI integration and PR management
- **`helix.nix`** - Helix editor integration for git workflows
- **`tools.nix`** - Additional git tools (lazygit, tig, git-absorb)
- **`prompts.nix`** - Git-aware shell prompts
- **`help.nix`** - Interactive help system

### Desktop Environment (`desktop/`)

Wayland-based desktop configuration:

- **`hyprland/`** - Tiling compositor configuration
  - Window management rules
  - Keybindings and gestures
  - Per-workspace wallpapers
  - Screenshot utilities
- **`waybar/`** - Status bar configuration
  - System monitoring widgets
  - Workspace indicators
  - Custom scripts
- **`hypridle.nix`** - Idle management
- **`hyprlock.nix`** - Screen locking
- **`hyprpaper.nix`** - Wallpaper management
- **`mako.nix`** - Notification daemon
- **`rofi.nix`** - Application launcher
- **`wlogout.nix`** - Session management

### Development Tools (`devtools/`)

Language-specific development environments:

- **`rust.nix`** - Rust toolchain with cargo extensions
- **`zig.nix`** - Zig compiler and language server
- **`python.nix`** - Python with poetry and tools
- **`node.nix`** - Node.js with pnpm and TypeScript
- **`go.nix`** - Go toolchain with tools
- **`c.nix`** - C/C++ development tools

### Shell Configuration (`shells/`)

Multi-shell support with shared configuration:

- **`nushell/`** - Modern structured shell
  - Custom commands and completions
  - Structured data pipelines
  - Modern scripting
- **`bash.nix`** - POSIX compatibility shell
- **`zsh.nix`** - Feature-rich interactive shell
- **`common.nix`** - Shared environment variables

## Configuration

### Module Pattern

Standard Home Manager module structure:

```nix
{ config, lib, pkgs, ... }:

let
  cfg = config.programs.moduleName;
in
{
  options.programs.moduleName = {
    enable = lib.mkEnableOption "module description";
    
    # Additional options
    setting = lib.mkOption {
      type = lib.types.str;
      default = "value";
      description = "Setting description";
    };
  };

  config = lib.mkIf cfg.enable {
    # Module implementation
    home.packages = with pkgs; [ package ];
    
    # Configuration files
    home.file.".config/app/config".text = ''
      setting = ${cfg.setting}
    '';
  };
}
```

### Enabling Modules

1. Import in your Home Manager configuration:

   ```nix
   imports = [ self.homeModules.moduleName ];
   ```

2. Enable and configure:

   ```nix
   programs.moduleName.enable = true;
   programs.moduleName.setting = "custom-value";
   ```

3. Rebuild your system:

   ```bash
   sudo nixos-rebuild switch --flake .#fern
   ```

## Usage

### Adding a New Module

1. Create file in appropriate directory
2. Register in `flake.parts/30-home-mods.nix`
3. Follow the module pattern
4. Add to host configuration
5. Document the module

### Module Dependencies

Some modules depend on others:

- Desktop modules require Hyprland
- Git helix integration needs helix enabled
- Shell modules may share common configuration

### Per-User Configuration

Home Manager allows per-user customization:

```nix
home-manager.users.ada = {
  # Ada's configuration
};

home-manager.users.guest = {
  # Guest configuration
};
```

## Examples

### Minimal CLI Setup

```nix
imports = [
  self.homeModules.cli
  self.homeModules.shells-bash
];

programs.bat.enable = true;
programs.eza.enable = true;
```

### Full Development Environment

```nix
imports = [
  self.homeModules.cli
  self.homeModules.git
  self.homeModules.helix
  self.homeModules.rust
  self.homeModules.typescript
];

programs.git.enable = true;
programs.helix.enable = true;
```

### Complete Desktop Experience

```nix
imports = [
  self.homeModules.cli
  self.homeModules.git
  self.homeModules.desktop
  self.homeModules.ghostty
];

wayland.windowManager.hyprland.enable = true;
```

## Troubleshooting

### Module Not Loading

```bash
# Check if module is registered
grep "moduleName" flake.parts/30-home-mods.nix

# Verify import in configuration
grep "homeModules" hosts/fern/configuration.nix
```

### Configuration Not Applied

```bash
# Check Home Manager status
home-manager generations

# Switch to configuration
home-manager switch --flake .#ada@fern

# View activation script
home-manager build --flake .#ada@fern
```

### File Conflicts

```bash
# Backup existing file
mv ~/.config/app/config ~/.config/app/config.bak

# Rebuild
sudo nixos-rebuild switch --flake .#fern
```

### Environment Variables

```bash
# Check if variables are set
env | grep MY_VAR

# Source shell configuration
source ~/.bashrc  # or appropriate shell
```

## See Also

- **[System Modules](../modules/)** - System-level configuration
- **[Git Suite Guide](../../docs/guides/git-suite.md)** - Detailed git documentation
- **[Architecture](../../docs/ARCHITECTURE.md)** - System design overview
- **[Home Manager Manual](https://nix-community.github.io/home-manager/)** - Official documentation

---

_Home modules shape your personal environment - configure them to match your workflow._
