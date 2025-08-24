# 🔧 System Modules - NixOS Configuration

> **Purpose:** System-level NixOS modules for core functionality and services  
> **Type:** System Configuration  
> **Status:** Stable

## Overview

This directory contains NixOS system modules that configure core system
functionality, hardware support, and system services. These modules require root
privileges and affect the entire system, forming the foundation of your NixOS
installation.

## Quick Start

```nix
# In your host configuration (hosts/fern/configuration.nix)
imports = [
  self.nixosModules.boot
  self.nixosModules.audio
  self.nixosModules.graphics
];

# Enable and configure
boot.kernelPackages = pkgs.linuxPackages_zen;
services.pipewire.enable = true;
```

## What's Inside

| Module/Directory    | Purpose                      | Impact                    |
| ------------------- | ---------------------------- | ------------------------- |
| `core.nix`          | Nix daemon settings, flakes  | System-wide Nix behavior  |
| `boot.nix`          | Bootloader, kernel, initrd   | System startup            |
| `audio.nix`         | PipeWire audio configuration | Audio subsystem           |
| `graphics.nix`      | GPU drivers, OpenGL/Vulkan   | Graphics rendering        |
| `fonts.nix`         | System fonts                 | Available fonts           |
| `users.nix`         | User accounts and groups     | System access             |
| `secrets.nix`       | SOPS-nix secret management   | Encrypted secrets         |
| `secrets-guard.nix` | Secret protection            | Security hardening        |
| `azure-cli.nix`     | Azure CLI tools              | Cloud tooling             |
| `desktop/`          | Desktop services             | Display manager, GUI apps |
| `devtools/`         | Development toolchains       | System-level dev tools    |
| `cloud/`            | Cloud provider tools         | AWS, Azure integration    |

## Module Categories

### Core Infrastructure

Essential system configuration:

- **`core.nix`** - Nix settings, garbage collection, experimental features
- **`boot.nix`** - Bootloader (systemd-boot), kernel selection, boot parameters
- **`users.nix`** - User account definitions, groups, sudo configuration

### Hardware Support

Device and hardware configuration:

- **`graphics.nix`** - GPU drivers (Nvidia/AMD/Intel), Vulkan, OpenGL
- **`audio.nix`** - PipeWire setup, ALSA, PulseAudio compatibility
- **`fonts.nix`** - System font packages and fontconfig

### Security

Security and secret management:

- **`secrets.nix`** - SOPS-nix integration for encrypted secrets
- **`secrets-guard.nix`** - Additional secret protection measures

### Desktop Services (`desktop/`)

GUI and desktop-related services:

- **`greetd.nix`** - Minimal display manager
- **`claude.nix`** - Claude Desktop application
- **`cursor.nix`** - Cursor IDE
- **`vscode.nix`** - Visual Studio Code
- **`teams.nix`** - Microsoft Teams
- **`lmstudio.nix`** - LM Studio for LLMs
- **`sqlserver.nix`** - SQL Server tools

### Development Tools (`devtools/`)

System-level development toolchains:

- **`rust.nix`** - Rust toolchain with overlay
- **`python-toolchain.nix`** - Python environment
- **`node-ts.nix`** - Node.js and TypeScript
- **`docker.nix`** - Container runtime
- **`localstack.nix`** - Local AWS emulation
- **`c-toolchain.nix`** - C/C++ development
- **`ada-toolchain.nix`** - Ada language support
- **`csharp-toolchain.nix`** - .NET/C# development

### Cloud Tools (`cloud/`)

Cloud provider integrations:

- **`aws-cli.nix`** - AWS CLI and tools

## Configuration

### Module Structure

Standard NixOS module pattern:

```nix
{ config, lib, pkgs, ... }:

{
  options = {
    services.myService = {
      enable = lib.mkEnableOption "my service";
      # Additional options
    };
  };

  config = lib.mkIf config.services.myService.enable {
    # Implementation
  };
}
```

### Common Patterns

```nix
# Hardware configuration
hardware.nvidia.enable = true;
hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;

# Service configuration
services.pipewire = {
  enable = true;
  alsa.enable = true;
  pulse.enable = true;
};

# System packages
environment.systemPackages = with pkgs; [
  vim
  git
  htop
];
```

## Usage

### Enabling a Module

1. Import in your host configuration:

   ```nix
   imports = [ self.nixosModules.moduleName ];
   ```

2. Enable and configure:

   ```nix
   services.moduleName.enable = true;
   services.moduleName.option = value;
   ```

3. Rebuild system:
   ```bash
   sudo nixos-rebuild switch --flake .#fern
   ```

### Creating a New Module

1. Create file in appropriate location
2. Add to `flake.parts/20-nixos-mods.nix`
3. Follow module pattern with options and config
4. Document the module's purpose and options

## Dependencies

### Boot Order Dependencies

- `boot.nix` must configure kernel before hardware modules
- `users.nix` needed before user services
- `graphics.nix` before desktop environment

### Service Dependencies

- Audio may require specific kernel modules
- Desktop services need graphics configured
- Development tools may need kernel features

## Examples

### Minimal System

```nix
imports = [
  self.nixosModules.core
  self.nixosModules.boot
  self.nixosModules.users
];
```

### Desktop System

```nix
imports = [
  self.nixosModules.core
  self.nixosModules.boot
  self.nixosModules.users
  self.nixosModules.audio
  self.nixosModules.graphics
  self.nixosModules.greet
];
```

### Development Workstation

```nix
imports = [
  # ... base imports
  self.nixosModules.docker
  self.nixosModules.rust-dev
  self.nixosModules.typescript
];
```

## Troubleshooting

### Module Not Available

```bash
# Check if module is registered
grep "moduleName" flake.parts/20-nixos-mods.nix

# Verify file exists
ls nix/modules/moduleName.nix
```

### Hardware Not Working

```bash
# Check kernel modules
lsmod | grep module_name

# View system logs
journalctl -b | grep -i error

# Check hardware detection
lspci  # For PCI devices
lsusb  # For USB devices
```

### Service Failures

```bash
# Check service status
systemctl status service-name

# View service logs
journalctl -u service-name

# Test configuration
nixos-rebuild test --flake .#fern
```

## See Also

- **[Home Modules](../home/)** - User-level configuration
- **[Architecture](../../docs/ARCHITECTURE.md)** - System design
- **[Host Configuration](../../hosts/)** - How modules are composed
- **[NixOS Options](https://search.nixos.org/options)** - Available NixOS
  options

---

_System modules are the foundation - they configure the core OS that everything
else builds upon._
