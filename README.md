# 🌱 Fern — NixOS

> **Purpose:** Complete NixOS system configuration for development workstation  
> **Architecture:** Flake-based modular NixOS + Home Manager  
> **Status:** Active Development

## Overview

Fern is a comprehensive NixOS configuration designed for software development
with an emphasis on modularity, reproducibility, and developer experience. Built
with Flakes and Home Manager, it provides a complete system from bootloader to
Wayland compositor, featuring advanced git tooling, multi-language support, and
a carefully crafted Hyprland desktop environment.

## Quick Start

### First-Time Installation

```bash
# Clone the repository
git clone git@github.com:adanoelle/fern.git ~/src/nix/fern
cd ~/src/nix/fern

# Build and switch to the configuration
sudo nixos-rebuild switch --flake .#fern
```

### Daily Usage

```bash
# Rebuild after changes
sudo nixos-rebuild switch --flake .#fern

# Test changes without switching
sudo nixos-rebuild test --flake .#fern

# Update all dependencies
nix flake update

# Clean old generations
nix-collect-garbage -d
```

## 🗂 Project Structure

```
.
├── flake.nix                  # Main flake definition
├── flake.lock                 # Lock file for pinned inputs
├── flake.parts/               # Flake-parts modular definitions
│   ├── 00-overlay.nix         # Custom overlays
│   ├── 10-core.nix            # Shared flake outputs (systems, packages)
│   ├── 20-nixos-mods.nix      # All NixOS module imports
│   ├── 30-home-mods.nix       # All Home-Manager module imports
│   └── 40-hosts.nix           # Per-host NixOS configurations
├── hosts/
│   └── fern/
│       ├── configuration.nix  # System + HM imports + host toggles
│       └── hardware.nix       # Generated hardware profile
├── nix/
│   ├── modules/               # NixOS modules (system level)
│   │   ├── audio.nix
│   │   ├── boot.nix
│   │   ├── graphics.nix
│   │   ├── desktop/           # Desktop-specific modules (e.g. greetd)
│   │   ├── users.nix
│   │   └── …other feature modules…
│   ├── home/                  # Home-Manager modules (user level)
│   │   ├── cli/               # CLI tool modules (bat, git, ghostty, etc.)
│   │   ├── desktop/           # Hyprland + Waybar + idle/lock/wallpaper
│   │   ├── devtools/          # Language/stack toolchains
│   │   ├── shells/            # Nushell, Starship, Zoxide
│   │   ├── workspace.nix      # XDG user dirs layout
│   │   └── …other user modules…
│   └── README.md              # (This file)
├── secrets/                   # SOPS-managed secrets
│   └── main.yaml
└── README.md                  # You are here
```

## Key Features

### 🎯 Core System

- **Zen Kernel** - Optimized for desktop performance
- **Nvidia Graphics** - Full CUDA support with Hyprland
- **PipeWire Audio** - Low-latency audio with quality tweaks
- **SOPS Secrets** - Encrypted secret management

### 💻 Development Environment

- **Languages:** Rust, Zig, Python, TypeScript, C/C++, Ada, C#
- **Tools:** Docker, LocalStack, AWS CLI, Azure CLI
- **Editor:** Helix (primary), VS Code, Cursor available
- **Shell:** Nushell with Starship prompt

### 🚀 Git Configuration

- **Advanced Worktrees** - Parallel development workflows
- **Multi-Identity** - Automatic identity switching by directory
- **Claude Integration** - AI-assisted coding with safety features
- **Rich Aliases** - Extensive git shortcuts and workflows

### 🖼️ Desktop Environment

- **Hyprland** - Wayland compositor with animations
- **Per-Workspace Wallpapers** - Different backgrounds per workspace
- **Waybar** - Customized status bar with Catppuccin Frappé theme
- **Ghostty** - GPU-accelerated terminal
- **Hypridle/Hyprlock** - Idle management and lock screen

## Configuration

### Basic Customization

Edit `hosts/fern/configuration.nix` to enable/disable modules and configure the
system.

### Desktop Configuration

Configure Hyprland and related features in `hosts/fern/configuration.nix`:

```nix
desktop.hyprland = {
  enable     = true;
  bar.enable = true;
  idle.enable = true;
  lock.enable = true;
  wallpaper = {
    enable  = true;
    path    = "/home/ada/wallpapers/shrine.png";
    monitor = "HDMI-A-1";
  };
  style = { gapsIn = 6; gapsOut = 12; border = 2; };
};
```

## Common Workflows

### Making Changes

```bash
# 1. Edit configuration files
hx hosts/fern/configuration.nix

# 2. Test your changes
sudo nixos-rebuild test --flake .#fern

# 3. If successful, apply
sudo nixos-rebuild switch --flake .#fern

# 4. If issues, rollback
sudo nixos-rebuild switch --rollback
```

### Updating System

```bash
# Update all flake inputs
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs

# Rebuild with updates
sudo nixos-rebuild switch --flake .#fern
```

## Documentation

### 📚 Comprehensive Guides

- **[Architecture Overview](docs/ARCHITECTURE.md)** - System design and
  structure
- **[Quick Wins](docs/QUICK_WINS.md)** - Immediate improvements you can make
- **[Improvement Plan](docs/IMPROVEMENT_PLAN.md)** - Roadmap for enhancements
- **[Git Suite Guide](docs/guides/git-suite.md)** - Advanced git features

### 📁 Module Documentation

- **[System Modules](nix/modules/)** - NixOS system configuration
- **[Home Modules](nix/home/)** - User environment configuration
- **[Host Configuration](hosts/)** - Machine-specific settings
- **[Flake Structure](flake.parts/)** - Flake organization

## Troubleshooting

### Build Fails

```bash
# Check flake
nix flake check

# See detailed errors
sudo nixos-rebuild test --flake .#fern --show-trace
```

### Out of Disk Space

```bash
# Clean old generations
nix-collect-garbage -d
sudo nix-collect-garbage -d
```

### Configuration Broken

```bash
# Rollback to previous generation
sudo nixos-rebuild switch --rollback
```

## Contributing

1. Check [existing issues](https://github.com/adanoelle/fern/issues)
2. Follow the module patterns in existing code
3. Test changes with `nixos-rebuild test`
4. Format code with `nixpkgs-fmt`
5. Document new features

## See Also

- **[NixOS Manual](https://nixos.org/manual/nixos/stable/)** - Official
  documentation
- **[Home Manager Manual](https://nix-community.github.io/home-manager/)** -
  User configuration
- **[GitHub Repository](https://github.com/adanoelle/fern)** - Source and issues

---

_Built with ❄️ Nix | Managed with 🏡 Home Manager | Powered by 🌊 Wayland_
