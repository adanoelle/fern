# 🧩 Flake Parts - Modular Flake Organization

> **Purpose:** Organize and modularize the Nix flake configuration  
> **Type:** Build Configuration  
> **Status:** Stable

## Overview

This directory uses the `flake-parts` framework to organize the Nix flake into
manageable, modular components. Each file handles a specific aspect of the
configuration, making the flake maintainable and scalable.

## Quick Start

```nix
# The main flake.nix imports these parts
{
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./flake.parts/00-overlay.nix
        ./flake.parts/10-core.nix
        ./flake.parts/20-nixos-mods.nix
        ./flake.parts/30-home-mods.nix
        ./flake.parts/40-hosts.nix
        ./flake.parts/50-dev.nix
        ./flake.parts/60-docs.nix
      ];
    };
}
```

## What's Inside

| File                | Purpose                            | Load Order |
| ------------------- | ---------------------------------- | ---------- |
| `00-overlay.nix`    | Package overlays and modifications | First      |
| `10-core.nix`       | Shared flake outputs (systems)     | Second     |
| `20-nixos-mods.nix` | NixOS system modules registry      | Third      |
| `30-home-mods.nix`  | Home Manager modules registry      | Fourth     |
| `40-hosts.nix`      | Per-host NixOS configurations      | Fifth      |
| `50-dev.nix`        | Development shell                  | Sixth      |
| `60-docs.nix`       | Documentation outputs              | Seventh    |

## File Numbering Convention

Files are numbered to control load order:

- **00-09:** Early initialization, overlays
- **10-19:** Core flake outputs
- **20-39:** Module definitions
- **40-49:** Host configurations
- **50-59:** Development tooling
- **60-69:** Documentation

## Component Details

### 📦 10-overlays.nix

Package overlays and customizations:

```nix
{ inputs, ... }: {
  perSystem = { system, ... }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [
        inputs.rust-overlay.overlays.default
        inputs.zig-overlay.overlays.default
        # Custom overlays
        (final: prev: {
          mypackage = prev.mypackage.override {
            # Customizations
          };
        })
      ];
    };
  };
}
```

**Purpose:**

- Apply external overlays (rust, zig)
- Define custom package overrides
- Set up package pinning
- Configure unfree packages

### 🔧 20-nixos-mods.nix

System module registry:

```nix
{ self, ... }: {
  flake.nixosModules = {
    # Core system
    core = ../nix/modules/core.nix;
    boot = ../nix/modules/boot.nix;
    users = ../nix/modules/users.nix;

    # Hardware
    audio = ../nix/modules/audio.nix;
    graphics = ../nix/modules/graphics.nix;

    # Services
    docker = ../nix/modules/devtools/docker.nix;
    greetd = ../nix/modules/desktop/greetd.nix;

    # All modules available as:
    # self.nixosModules.moduleName
  };
}
```

**Purpose:**

- Register all NixOS modules
- Create module namespace
- Enable module imports in hosts
- Maintain module index

### 🏠 30-home-mods.nix

Home Manager module registry:

```nix
{ self, ... }: {
  flake.homeModules = {
    # CLI and tools
    cli = ../nix/home/cli.nix;
    git = ../nix/home/git;

    # Desktop
    desktop = ../nix/home/desktop;
    hyprland = ../nix/home/desktop/hyprland;

    # Development
    rust = ../nix/home/devtools/rust.nix;
    python = ../nix/home/devtools/python.nix;

    # All modules available as:
    # self.homeModules.moduleName
  };
}
```

**Purpose:**

- Register Home Manager modules
- Create user module namespace
- Enable module imports in home configs
- Maintain module index

### 🎯 99-outputs.nix

Final flake outputs:

```nix
{ self, inputs, ... }: {
  perSystem = { system, pkgs, ... }: {
    # Development shells
    devShells.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        nixpkgs-fmt
        statix
        nil
      ];
    };

    # Packages
    packages = {
      inherit (pkgs) myCustomPackage;
    };
  };

  flake = {
    # NixOS configurations
    nixosConfigurations.fern = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit self inputs; };
      modules = [
        ../hosts/fern/configuration.nix
        inputs.home-manager.nixosModules.home-manager
      ];
    };
  };
}
```

**Purpose:**

- Define NixOS configurations
- Create development shells
- Export packages
- Set up deployment targets

## Adding New Components

### Adding a Module Part

Create a new numbered file:

```nix
# flake.parts/40-new-feature.nix
{ self, ... }: {
  flake.myFeature = {
    something = ../path/to/implementation.nix;
  };
}
```

### Registering in Flake

Add to imports in `flake.nix`:

```nix
imports = [
  ./flake.parts/10-overlays.nix
  ./flake.parts/20-nixos-mods.nix
  ./flake.parts/30-home-mods.nix
  ./flake.parts/40-new-feature.nix  # New
  ./flake.parts/99-outputs.nix
];
```

## Module Organization

### Naming Conventions

```nix
# System modules: descriptive names
nixosModules.audio        # Audio subsystem
nixosModules.rust-dev     # Rust development

# Home modules: match program names
homeModules.git          # Git configuration
homeModules.helix        # Helix editor

# Nested modules: use dash separator
nixosModules.desktop-greetd  # Desktop: greetd
homeModules.shells-nushell    # Shells: nushell
```

### Module Grouping

Group related modules:

```nix
# Desktop-related
desktop-greetd
desktop-hyprland
desktop-waybar

# Development-related
dev-rust
dev-python
dev-docker

# Cloud-related
cloud-aws
cloud-azure
```

## Advanced Usage

### Conditional Imports

```nix
{ lib, ... }: {
  imports = lib.optionals (builtins.pathExists ./local.nix) [
    ./local.nix
  ];
}
```

### System-Specific Configuration

```nix
{ inputs, ... }: {
  perSystem = { system, ... }: {
    # Only for Linux
    packages = lib.optionalAttrs (system == "x86_64-linux") {
      linux-only-package = pkgs.something;
    };
  };
}
```

### Module Composition

```nix
# Combine multiple modules
flake.nixosModules.full-desktop = { ... }: {
  imports = [
    self.nixosModules.audio
    self.nixosModules.graphics
    self.nixosModules.desktop-hyprland
  ];
};
```

## Troubleshooting

### Import Errors

```bash
# Check module paths
ls -la flake.parts/
find nix/ -name "*.nix" | grep modulename

# Validate nix files
nix flake check
```

### Module Not Found

```bash
# List available modules
nix eval .#nixosModules --apply builtins.attrNames
nix eval .#homeModules --apply builtins.attrNames
```

### Circular Dependencies

```nix
# Avoid circular imports
# Bad: A imports B, B imports A
# Good: Extract common code to C, both import C
```

### Overlay Issues

```bash
# Test overlay application
nix eval .#pkgs.mypackage
nix build .#pkgs.mypackage
```

## Best Practices

1. **Maintain number spacing** - Leave gaps for future additions
2. **Document modules** - Add comments explaining purpose
3. **Group related items** - Use consistent naming prefixes
4. **Test incrementally** - Add one module at a time
5. **Use type checking** - Leverage module system types
6. **Keep it flat** - Avoid deep nesting
7. **Version control** - Commit working configurations

## Benefits of Flake Parts

1. **Modularity** - Split configuration into logical pieces
2. **Reusability** - Share modules across projects
3. **Maintainability** - Easier to understand and modify
4. **Type Safety** - Built-in type checking
5. **Composition** - Combine modules flexibly
6. **Documentation** - Self-documenting structure

## See Also

- **[Flake Parts Documentation](https://flake.parts/)** - Official framework
  docs
- **[System Modules](../nix/modules/)** - NixOS module implementations
- **[Home Modules](../nix/home/)** - Home Manager module implementations
- **[Main Flake](../flake.nix)** - Root flake configuration

---

_Flake parts: turning monolithic configurations into composable, maintainable
modules._
