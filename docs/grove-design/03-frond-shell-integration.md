# Grove Design: Frond Shell Integration

## Overview

[Frond](https://github.com/adanoelle/frond) is a custom desktop shell built on
quickshell, the niri compositor, and custom Rust crates (including a control
plane for IPC). It is a separate repository that uses den internally for its own
aspect composition and exports den aspects for grove to consume.

This document covers how frond is structured, what it exports, and how grove
integrates it.

## Frond's Identity

- **Name origin:** A fern frond is a fractal structure — pinnae (channels)
  divide into pinnules (blocks), mirroring frond's UI architecture
- **Aesthetic:** PC-98 / vintage computing inspired, are.na influenced
- **UI model:** Channels (workspace-level, like are.na channels) containing
  blocks (window-level subdivisions, like are.na blocks)
- **Repository:** `github:adanoelle/frond` (separate from grove)
- **Previously:** Called `fern-shell`

## Frond Repository Structure

```
frond/
├── flake.nix
├── flake.lock
├── crates/
│   ├── control-plane/       # Rust: IPC daemon, system management
│   └── ...                  # Future Rust crates
├── quickshell/              # Quickshell configuration + QML
├── niri/                    # Niri compositor configuration
└── modules/                 # Den aspects + package definitions (auto-imported)
    ├── packages.nix         # perSystem packages + devShell
    ├── frond.nix            # den.aspects.frond (full desktop)
    └── headless.nix         # den.aspects.frond.provides.headless
```

## Frond Uses Den Internally

Frond uses den for its own aspect composition. This means frond **owns its
integration logic** — it knows how to set up niri, how to run the control plane
daemon, what dbus policies it needs — and exports that knowledge as den aspects
rather than requiring the consumer to figure it out.

### Why den in frond (not packages-only)?

The earlier design had frond exporting packages and grove writing wrapper
aspects. This was to avoid `mkIf`/enable patterns. But since both repos use den,
there are no `mkIf` patterns to avoid. Moving the integration into frond is
strictly better:

| Concern | Packages-only (old) | Den aspects (new) |
|---------|--------------------|--------------------|
| Who knows how to run the control plane? | Grove (bad — not its job) | Frond (good — owns the code) |
| When control plane flags change | Update frond AND grove | Update frond only |
| Grove boilerplate per host | ~30 lines wrapping packages | ~1 line including aspect |
| `mkIf` anywhere | No | No |
| Integration tested with code | No — tested in grove | Yes — in frond's own flake |

## What Frond Exports

```nix
# frond/flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    den.url = "github:vic/den";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    imports = [ (inputs.import-tree ./modules) ];
  };
}
```

### Exported outputs

| Export | Purpose |
|--------|---------|
| `packages.${system}.frond` | Quickshell config bundle (built artifact) |
| `packages.${system}.control-plane` | Compiled Rust daemon (built artifact) |
| `den.aspects.frond` | Full desktop integration (niri + quickshell + control plane) |
| `den.aspects.frond.provides.headless` | Control plane only (no compositor/UI) |
| `overlays.default` | Convenience overlay for `pkgs.frond`, `pkgs.frond-control-plane` |
| `devShells.${system}.default` | Dev environment for working on frond |

Packages are still exported for standalone use (`nix run github:adanoelle/frond`)
and for the dev workflow. The den aspects reference these packages internally.

## Frond's Den Aspects

### Full desktop (den.aspects.frond)

```nix
# frond/modules/frond.nix
{ den, self, ... }: {
  den.aspects.frond = {
    # System-level: compositor, services, dbus
    nixos = { pkgs, ... }:
    let
      frondPkgs = self.packages.${pkgs.system};
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
      frondPkgs = self.packages.${pkgs.system};
    in {
      # Quickshell configuration files
      xdg.configFile."quickshell".source =
        "${frondPkgs.frond}/share/frond/quickshell";

      # Niri user config
      xdg.configFile."niri/config.kdl".source =
        "${frondPkgs.frond}/share/frond/niri/config.kdl";

      # Shell integration for control plane CLI
      # (adjust based on actual frond CLI interface)
    };

    # Headless — just the control plane, no compositor/UI
    provides.headless = {
      nixos = { pkgs, ... }:
      let
        frondPkgs = self.packages.${pkgs.system};
      in {
        systemd.user.services.frond-control-plane = {
          description = "Frond Control Plane (headless)";
          wantedBy = [ "default.target" ];
          serviceConfig = {
            ExecStart =
              "${frondPkgs.control-plane}/bin/control-plane --headless";
            Restart = "on-failure";
          };
        };
      };
      # No homeManager block — no UI on headless
    };
  };
}
```

### Packages (still exported alongside aspects)

```nix
# frond/modules/packages.nix
{ ... }: {
  perSystem = { pkgs, self', ... }: {
    packages = {
      frond = /* quickshell config bundle */;
      control-plane = /* compiled Rust daemon */;
      default = self'.packages.frond;
    };

    overlays.default = final: prev: {
      frond = self'.packages.frond;
      frond-control-plane = self'.packages.control-plane;
    };

    devShells.default = /* rust toolchain, quickshell, niri, etc. */;
  };
}
```

## Grove Consumption

### Flake input with follows

```nix
# grove/flake.nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  den.url = "github:vic/den";
  rust-overlay.url = "github:oxalica/rust-overlay";

  frond = {
    url = "github:adanoelle/frond";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.rust-overlay.follows = "rust-overlay";
    inputs.den.follows = "den";                # same den instance
    inputs.flake-parts.follows = "flake-parts";
  };
};
```

All shared inputs use `follows` — single nixpkgs evaluation, single den
instance, single Rust toolchain. No dependency drift.

### How hosts include frond

Grove host aspects just include frond's aspects directly. No wrapper aspect
needed in grove:

```nix
# grove/modules/hosts/fern.nix
{ den, inputs, ... }: {
  den.aspects.fern = {
    includes = [
      den.aspects.desktop
      den.aspects.desktop.provides.igpu
      inputs.frond.den.aspects.frond            # full desktop shell
      den.aspects.devtools
      den.aspects.docker
    ];
  };
}

# grove/modules/hosts/oak.nix
{ den, inputs, ... }: {
  den.aspects.oak = {
    includes = [
      den.aspects.server
      inputs.frond.den.aspects.frond.provides.headless  # just the daemon
    ];
  };
}

# grove/modules/hosts/moss.nix
{ den, inputs, ... }: {
  den.aspects.moss = {
    includes = [
      den.aspects.desktop
      den.aspects.desktop.provides.asahi
      inputs.frond.den.aspects.frond            # full desktop shell
      den.aspects.laptop
      den.aspects.devtools
      den.aspects.docker
    ];
  };
}
```

Note: **no `modules/desktop/frond.nix` in grove.** The integration aspect lives
in frond. Grove just includes it. This is the key difference from the
packages-only approach.

## Cross-Flake Aspect Access — To Verify

> **IMPORTANT:** The exact syntax for accessing den aspects across flake
> boundaries (`inputs.frond.den.aspects.frond`) needs to be verified against
> den's documentation and tested. Den's examples are primarily within a single
> flake.
>
> Possible alternatives if direct access doesn't work:
>
> 1. Frond exports a `flakeModule` that grove imports, making frond's aspects
>    available in grove's `den.aspects` namespace
> 2. Frond exports aspects via a custom flake output (e.g.,
>    `frond.flake.den.aspects.frond`)
> 3. Grove imports frond's modules directory via `import-tree`
>
> **Test this early in Phase 1.** If cross-flake aspect sharing needs a
> different pattern, adjust accordingly. The overall design (frond owns
> integration, grove just includes) remains the same regardless of syntax.

## Development Workflow

### Working on frond

```bash
cd ~/frond
nix develop              # enters devShell with Rust, quickshell, niri
cargo build              # iterate on Rust crates
nix build .#frond        # build the shell bundle
nix run .#control-plane  # test the daemon
nix flake check          # verify aspects + packages build
```

### Testing frond changes in grove (before pushing)

```bash
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

1. **Per-host theming:** If different machines want different frond themes, add
   `provides.theme-name` sub-aspects or a parametric aspect that takes a theme
   argument.

2. **Architecture support:** frond currently targets x86_64-linux. For moss
   (aarch64), ensure Rust crates cross-compile or build natively on aarch64.
   The aspect itself is architecture-agnostic — it references
   `self.packages.${pkgs.system}` which resolves per-host.

3. **NixOS modules for non-den consumers:** If others want to use frond without
   den, add `nixosModules` and `homeModules` exports alongside the den aspects.
   These would use standard `mkIf`/`mkEnableOption` patterns. The den aspects
   and NixOS modules can coexist — they're just different interfaces to the same
   packages.

4. **Frond aspects depending on grove aspects:** If frond ever needs to declare
   that it depends on another grove aspect (e.g., `den.aspects.audio`), this
   creates a circular dependency. Instead, use den's `includes` with parametric
   dispatch — frond can include functions that only fire when audio context
   exists, without hard-depending on grove's audio aspect.
