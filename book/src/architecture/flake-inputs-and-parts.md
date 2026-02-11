# Flake Inputs & Parts

> The flake definition is split between `flake.nix` (inputs) and seven numbered
> files in `flake.parts/` (outputs). This page walks through both.

## Inputs

`flake.nix` declares all external dependencies. Each input follows nixpkgs where
possible (`inputs.nixpkgs.follows = "nixpkgs"`) to avoid building duplicate
package sets.

| Input                 | Source               | Purpose                                             |
| --------------------- | -------------------- | --------------------------------------------------- |
| `nixpkgs`             | `nixos-unstable`     | Base package set and NixOS modules                  |
| `flake-parts`         | hercules-ci          | Modular flake framework                             |
| `flake-utils`         | numtide              | Flake utility functions                             |
| `home-manager`        | nix-community        | User-space configuration management                 |
| `fern`                | adanoelle/fern-shell | Custom QuickShell bar and fonts                     |
| `devenv`              | cachix               | Development environment framework                   |
| `claude-desktop`      | k3d3                 | Claude desktop application for Linux                |
| `rust-overlay`        | oxalica              | Rust toolchain management (stable/nightly/specific) |
| `zig-overlay`         | mitchellh            | Zig toolchain management                            |
| `sops-nix`            | Mic92                | Encrypted secrets with age/GPG                      |
| `nixos-apple-silicon` | tpwrules             | Apple Silicon hardware support                      |

The `outputs` function imports all files from `flake.parts/` through
`flake-parts.lib.mkFlake`:

```nix
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
```

## Parts breakdown

### 00-overlay.nix -- Overlays

Reserved for package overlay definitions. Currently empty -- the Rust and Zig
overlays are applied in `10-core.nix` directly.

### 10-core.nix -- System foundations

```nix
systems = [ "x86_64-linux" ];

perSystem = { system, ... }: {
  _module.args.pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
    overlays = [
      inputs.rust-overlay.overlays.default
      inputs.zig-overlay.overlays.default
    ];
  };
};
```

Defines the supported system architecture, allows unfree packages (needed for
NVIDIA drivers, Steam, VS Code, etc.), and applies the Rust and Zig overlays so
`pkgs.rust-bin` and `pkgs.zig` are available everywhere.

### 20-nixos-mods.nix -- NixOS module registry

Registers all system modules as `flake.nixosModules.<name>`. Each entry maps a
short name to a file path:

```nix
flake.nixosModules = {
  boot       = import ../nix/modules/boot.nix;
  core       = import ../nix/modules/core.nix;
  audio      = import ../nix/modules/audio.nix;
  graphics   = import ../nix/modules/graphics.nix;
  rust-dev   = import ../nix/modules/devtools/rust.nix;
  # ... 28 modules total
};
```

Host configurations reference these as `self.nixosModules.boot`, etc.

### 30-home-mods.nix -- Home Manager module registry

Registers the six top-level Home Manager module groups:

```nix
flake.homeModules = {
  desktop   = import ../nix/home/desktop.nix;
  devtools  = import ../nix/home/devtools.nix;
  shells    = import ../nix/home/shells.nix;
  cli       = import ../nix/home/cli.nix;
  git       = import ../nix/home/git;
  workspace = import ../nix/home/workspace.nix;
};
```

Each module group is an aggregator that imports its sub-modules. For example,
`cli` imports bat, helix, ghostty, delta, and others.

### 40-hosts.nix -- Host configurations

Defines the two NixOS system configurations:

- **fern** -- `x86_64-linux` with NVIDIA GPU. Imports hardware config,
  host-specific `configuration.nix`, Home Manager, and the fern-shell/fonts
  packages.

- **moss** -- `aarch64-linux` (Apple Silicon M1 Pro). Same structure but uses
  `nixos-apple-silicon` support module instead of NVIDIA.

Both pass `self` and `inputs` as `specialArgs` so modules can reference other
flake outputs.

### 50-dev.nix -- Development shell

Provides `nix develop` with `just`, `mdbook`, and `nixpkgs-fmt`. This is the
shell you get when running `direnv allow` or `nix develop` in the repo root.

### 60-docs.nix -- Documentation

Builds the mdBook documentation as a Nix package and provides two app commands:

- `nix run .#book-serve` -- live-reload preview
- `nix run .#book-build` -- static build to `book/build/`

## Key files

| File                            | Purpose                                   |
| ------------------------------- | ----------------------------------------- |
| `flake.nix`                     | Input declarations and flake-parts import |
| `flake.lock`                    | Pinned input revisions                    |
| `flake.parts/10-core.nix`       | System arch, nixpkgs config, overlays     |
| `flake.parts/20-nixos-mods.nix` | NixOS module name registry                |
| `flake.parts/30-home-mods.nix`  | Home Manager module name registry         |
| `flake.parts/40-hosts.nix`      | Host definitions (fern + moss)            |
