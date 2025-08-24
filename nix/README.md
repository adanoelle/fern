# 📦 Nix Configuration Modules

> **Purpose:** Centralized location for all NixOS and Home Manager modules  
> **Type:** Module Collection  
> **Status:** Stable

## Overview

This directory contains all Nix configuration modules for the Fern system,
organized into two main categories: system-level NixOS modules and user-level
Home Manager modules. This separation ensures clear boundaries between system
administration and user preferences.

## Quick Start

```nix
# Import a system module in your host configuration
imports = [
  self.nixosModules.audio
  self.nixosModules.graphics
];

# Import user modules via Home Manager
home-manager.users.ada = {
  imports = [
    self.homeModules.cli
    self.homeModules.desktop
  ];
};
```

## What's Inside

| Directory  | Purpose                         | Scope                                    |
| ---------- | ------------------------------- | ---------------------------------------- |
| `modules/` | System-level NixOS modules      | Root configuration, hardware, services   |
| `home/`    | User-level Home Manager modules | User environment, applications, dotfiles |

## Module Categories

### System Modules (`modules/`)

Configuration that requires root privileges or affects the entire system:

- **Core Infrastructure** - Boot, kernel, Nix daemon
- **Hardware** - Graphics drivers, audio system, peripherals
- **System Services** - Docker, display manager, databases
- **Security** - Secrets management, firewall, users

### Home Modules (`home/`)

User-specific configuration managed by Home Manager:

- **CLI Tools** - Terminal utilities and command-line programs
- **Desktop Environment** - Hyprland, status bar, wallpapers
- **Development Tools** - Language toolchains and IDEs
- **Git Suite** - Advanced git configuration and tools
- **Shell Configuration** - Nushell, Bash, Zsh settings

## Configuration

### Module Pattern

All modules follow a consistent structure:

```nix
{ config, lib, pkgs, ... }:

let
  cfg = config.programs.moduleName;
in
{
  options.programs.moduleName = {
    enable = lib.mkEnableOption "Description of module";

    # Additional options...
  };

  config = lib.mkIf cfg.enable {
    # Module implementation...
  };
}
```

### Enabling Modules

Modules are typically enabled in the host configuration:

```nix
# System module
services.docker.enable = true;

# Home module
programs.git.enable = true;
```

## Usage

### Adding a New System Module

1. Create file in `modules/` or appropriate subdirectory
2. Register in `flake.parts/20-nixos-mods.nix`
3. Import in host configuration
4. Enable and configure as needed

### Adding a New Home Module

1. Create file in `home/` or appropriate subdirectory
2. Register in `flake.parts/30-home-mods.nix`
3. Import in Home Manager configuration
4. Enable and configure as needed

## Dependencies

### Module Loading Order

1. Flake evaluates and loads module definitions
2. Host configuration imports required modules
3. Modules are evaluated based on dependencies
4. Configuration is built and activated

### Inter-module Dependencies

Some modules depend on others:

- Desktop modules may require graphics module
- Development tools may need specific system packages
- Git suite requires core git configuration

## Examples

### System Module Usage

```nix
# In hosts/fern/configuration.nix
{
  imports = [
    self.nixosModules.audio
    self.nixosModules.graphics
    self.nixosModules.docker
  ];

  # Configure the modules
  services.pipewire.enable = true;
  hardware.nvidia.enable = true;
  virtualisation.docker.enable = true;
}
```

### Home Module Usage

```nix
# In hosts/fern/configuration.nix
home-manager.users.ada = {
  imports = [
    self.homeModules.git
    self.homeModules.cli
  ];

  programs.git.enable = true;
  programs.bat.enable = true;
};
```

## Troubleshooting

### Module Not Found

```bash
# Ensure module is registered in flake.parts
grep "moduleName" flake.parts/*.nix

# Check module file exists
ls -la nix/modules/moduleName.nix
```

### Option Conflicts

```bash
# Find conflicting definitions
nixos-rebuild test --show-trace

# Check for duplicate options
grep -r "options.programs.thing" nix/
```

### Module Not Loading

- Verify import statement in host configuration
- Check for syntax errors in module file
- Ensure dependencies are met

## See Also

- **[System Modules](modules/)** - Detailed system module documentation
- **[Home Modules](home/)** - Detailed home module documentation
- **[Architecture](../docs/ARCHITECTURE.md)** - Overall system design
- **[Host Configuration](../hosts/)** - How modules are used

---

_Modules are the building blocks of the Fern system - compose them to create
your perfect environment._
