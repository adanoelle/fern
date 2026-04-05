# The Flake Entry Point

> The entire configuration starts in `flake.nix` -- 50 lines that declare
> inputs, invoke flake-parts, and hand the `modules/` tree to den via
> `import-tree`.

## The full flake.nix

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    den.url = "github:vic/den";
    import-tree.url = "github:vic/import-tree";
    fern.url = "github:adanoelle/fern-shell";
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-desktop = {
      url = "github:k3d3/claude-desktop-linux-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-apple-silicon = {
      url = "github:tpwrules/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code = {
      url = "github:ryoppippi/claude-code-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ flake-parts, import-tree, ... }:
    flake-parts.lib.mkFlake { inherit inputs; }
      (import-tree ./modules);
}
```

## Inputs

Every external dependency follows nixpkgs where possible
(`inputs.nixpkgs.follows = "nixpkgs"`) to avoid building duplicate package sets.

| Input | Purpose |
|-------|---------|
| `nixpkgs` | Base package set (nixos-unstable) |
| `flake-parts` | Modular flake framework |
| `home-manager` | User-space configuration |
| `den` | Aspect framework (topology, includes, dual-side modules) |
| `import-tree` | Automatic recursive import of `modules/` |
| `fern` | Custom QuickShell bar and fonts |
| `devenv` | Development environment framework |
| `claude-desktop` | Claude desktop application for Linux |
| `rust-overlay` | Rust toolchain management |
| `zig-overlay` | Zig toolchain management |
| `sops-nix` | Encrypted secrets with age |
| `nixos-apple-silicon` | Apple Silicon hardware support |
| `claude-code` | Claude Code CLI overlay |

## The outputs line

The outputs section is two lines:

```nix
outputs = inputs@{ flake-parts, import-tree, ... }:
  flake-parts.lib.mkFlake { inherit inputs; }
    (import-tree ./modules);
```

This is where the old and new architectures meet:

1. **`flake-parts.lib.mkFlake`** -- the flake-parts framework still generates
   the final flake outputs. Den integrates as a flake-parts module, so the two
   coexist.

2. **`import-tree ./modules`** -- instead of manually listing imports from
   numbered `flake.parts/` files, `import-tree` recursively walks the `modules/`
   directory and imports every `.nix` file it finds. This is why adding a new
   aspect requires no registration -- just create the file.

## How import-tree works

`import-tree` from [vic/import-tree](https://github.com/vic/import-tree)
recursively discovers all `.nix` files in the given directory. The result is an
attribute set that flake-parts treats as a module with `imports`.

The convention is:
- Files directly in `modules/` are top-level concerns (hosts, defaults, core)
- Subdirectories group related aspects (`modules/git/`, `modules/cli/`,
  `modules/desktop/`)
- A `bundle.nix` in a subdirectory typically composes that directory's aspects

There is no ordering requirement -- den and the NixOS module system handle
dependency resolution through lazy evaluation.

## How den and flake-parts coexist

Den is imported as a flake-parts module in `modules/dendritic.nix`:

```nix
imports = [
  (inputs.den.flakeModule or inputs.den.flakeModules.den)
];
```

This gives the entire `modules/` tree access to `den.aspects`, `den.hosts`,
`den.default`, and other den primitives. Flake-parts handles the outer flake
structure (devShells, packages, apps), while den handles the NixOS/Home Manager
configuration wiring.

## Key files

| File | Purpose |
|------|---------|
| `flake.nix` | Input declarations and import-tree invocation |
| `flake.lock` | Pinned input revisions (commit via `nix flake update`) |
| `modules/dendritic.nix` | Den bootstrap (imported automatically by import-tree) |
