# Grove Design: Frond Shell Integration

## Overview

[Frond](https://github.com/adanoelle/frond) is a custom desktop shell built on
quickshell, the niri compositor, and custom Rust crates (including a control
plane for IPC). It is a separate repository consumed by grove as a flake input.

This document covers how frond is structured, what it exports, and how grove
integrates it via den aspects.

## Frond's Identity

- **Name origin:** A fern frond is a fractal structure — pinnae (channels)
  divide into pinnules (blocks), mirroring frond's UI architecture
- **Aesthetic:** PC-98 / vintage computing inspired, are.na influenced
- **UI model:** Channels (workspace-level, like are.na channels) containing
  blocks (window-level subdivisions, like are.na blocks)
- **Repository:** `github:adanoelle/frond` (separate from grove)
- **Previously:** Called `fern-shell`

## Frond Repository Structure (Recommended)

```
frond/
├── flake.nix
├── flake.lock
├── crates/
│   ├── control-plane/       # Rust: IPC daemon, system management
│   └── ...                  # Future Rust crates
├── quickshell/              # Quickshell configuration + QML
├── niri/                    # Niri compositor configuration
└── nix/
    └── packages.nix         # Package definitions
```

## What Frond Exports

Frond exports **packages only** — not NixOS modules. Integration logic lives in
grove's den aspects. This avoids `mkIf`/enable patterns and keeps frond
decoupled from any specific NixOS config pattern.

```nix
# frond/flake.nix — recommended exports
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, rust-overlay, ... }: {
    # Built artifacts
    packages.x86_64-linux = {
      frond = /* quickshell config bundle */;
      control-plane = /* compiled Rust daemon */;
      default = self.packages.x86_64-linux.frond;
    };

    # Convenience overlay for consumers
    overlays.default = final: prev: {
      frond = self.packages.${final.system}.frond;
      frond-control-plane = self.packages.${final.system}.control-plane;
    };

    # Dev shell for working on frond itself
    devShells.x86_64-linux.default = /* rust toolchain, quickshell, niri, etc. */;
  };
}
```

### Why packages-only (no NixOS modules)?

1. **Grove is the only consumer** — no need for a generic module API yet
2. **Den aspects handle composition** — no `mkIf` or enable flags needed
3. **Simpler frond repo** — focuses on building software, not system integration
4. **Can add modules later** — if frond needs to be consumed by non-den configs,
   add `nixosModules` then without breaking anything

## Grove Consumption via `follows`

```nix
# grove/flake.nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  rust-overlay.url = "github:oxalica/rust-overlay";

  frond = {
    url = "github:adanoelle/frond";
    inputs.nixpkgs.follows = "nixpkgs";          # single nixpkgs evaluation
    inputs.rust-overlay.follows = "rust-overlay";  # single rust toolchain
  };
};
```

This ensures frond's packages are built against the exact same nixpkgs and Rust
toolchain as the NixOS system. No dependency drift.

## Den Aspect: frond Integration

```nix
# grove/modules/desktop/frond.nix
{ den, inputs, ... }: {
  den.aspects.frond = {
    # System-level: compositor, services, dbus
    nixos = { pkgs, ... }:
    let
      frondPkgs = inputs.frond.packages.${pkgs.system};
    in {
      # Niri compositor
      programs.niri.enable = true;

      # Control plane daemon
      systemd.user.services.frond-control-plane = {
        description = "Frond Control Plane";
        wantedBy = [ "graphical-session.target" ];
        serviceConfig = {
          ExecStart = "${frondPkgs.control-plane}/bin/control-plane";
          Restart = "on-failure";
        };
      };

      # DBus policy for control plane IPC
      services.dbus.packages = [ frondPkgs.control-plane ];

      # Packages available system-wide
      environment.systemPackages = [ frondPkgs.frond ];
    };

    # User-level: quickshell config, theming, shell integration
    homeManager = { pkgs, ... }:
    let
      frondPkgs = inputs.frond.packages.${pkgs.system};
    in {
      # Quickshell configuration files
      xdg.configFile."quickshell".source = "${frondPkgs.frond}/share/frond/quickshell";

      # Niri user config
      xdg.configFile."niri/config.kdl".source = "${frondPkgs.frond}/share/frond/niri/config.kdl";

      # Shell integration for control plane CLI
      # (adjust based on actual frond CLI interface)
    };
  };
}
```

## Headless Control Plane (servers)

For machines that need the control plane but not the UI (e.g., oak/services):

```nix
# This can be a provides sub-aspect or a separate aspect

# Option A: sub-aspect of frond
den.aspects.frond.provides.headless = {
  nixos = { pkgs, ... }:
  let
    frondPkgs = inputs.frond.packages.${pkgs.system};
  in {
    systemd.user.services.frond-control-plane = {
      description = "Frond Control Plane (headless)";
      wantedBy = [ "default.target" ];
      serviceConfig = {
        ExecStart = "${frondPkgs.control-plane}/bin/control-plane --headless";
        Restart = "on-failure";
      };
    };
  };
  # No homeManager block — no UI on headless
};

# Option B: separate aspect
den.aspects.frond-headless = {
  nixos = { pkgs, ... }: { /* control plane only */ };
};
```

## How Hosts Include Frond

```nix
# Desktop machines get the full shell
den.aspects.fern.includes = [ den.aspects.frond ];
den.aspects.moss.includes = [ den.aspects.frond ];

# Server gets headless control plane only (if needed)
den.aspects.oak.includes = [ den.aspects.frond.provides.headless ];

# NAS gets nothing from frond — simply omit it
```

## Development Workflow

### Working on frond

```bash
cd ~/frond
nix develop              # enters devShell with Rust, quickshell, niri
cargo build              # iterate on Rust crates
nix build .#frond        # build the shell bundle
nix run .#control-plane  # test the daemon
```

### Testing frond changes in grove (before pushing)

```bash
# Override frond input to point at local checkout
cd ~/grove
nixos-rebuild test --flake .#fern \
  --override-input frond path:/home/ada/frond
```

### Updating frond in grove (after pushing)

```bash
cd ~/grove
nix flake update frond
nixos-rebuild test --flake .#fern
```

## Frond's Internal Architecture (for context)

```
frond (the shell)
│
├── niri (compositor)
│   └── manages windows, workspaces, output
│
├── quickshell (UI layer)
│   ├── channels ← workspace-level views (pinnae)
│   │   ├── block ← window container (pinnule)
│   │   ├── block
│   │   └── block
│   └── channels
│       └── ...
│
└── control-plane (Rust daemon)
    ├── IPC between quickshell and niri
    ├── system state management
    └── CLI interface for scripting
```

## Future Considerations

1. **Per-host theming:** If different machines want different frond themes, add a
   `theme` parameter to the frond aspect or use `provides.theme-name`
   sub-aspects.

2. **Architecture support:** frond currently targets x86_64-linux. For moss
   (aarch64), ensure Rust crates cross-compile or build natively on aarch64.

3. **NixOS modules in frond:** If other people want to use frond, or if the
   integration logic becomes complex (10+ services, complex dependencies), move
   it into frond as a proper NixOS module. The grove aspect would then just
   `imports = [ inputs.frond.nixosModules.default ]` inside its nixos block.
