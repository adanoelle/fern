# Why Den

> The old architecture worked, but it required manual registration, dual file
> trees, and enable-flag boilerplate. Den eliminates all three.

## Problems with the garden.* architecture

### Dual file trees

System configuration lived in `nix/modules/` and user configuration lived in
`nix/home/`. A tool that needed both (like a language toolchain with system
packages and editor LSP config) required two files in two directories. The
mental model was: "system stuff goes here, user stuff goes there."

This split had consequences:
- Adding a new tool meant editing two directories
- Related configuration was physically separated
- You had to mentally reconstruct the full picture from scattered files

### Manual import registries

Every NixOS module had to be registered in `flake.parts/20-nixos-mods.nix`:

```nix
flake.nixosModules = {
  boot       = import ../nix/modules/boot.nix;
  core       = import ../nix/modules/core.nix;
  audio      = import ../nix/modules/audio.nix;
  # ... 28 entries
};
```

And every Home Manager module group in `flake.parts/30-home-mods.nix`. Forget
to register a module? It does not exist. Rename a file? Update the registry.
This was pure boilerplate that added a step to every module change.

### Enable-flag boilerplate

Host configurations imported modules and then set enable flags:

```nix
# hosts/fern/configuration.nix
imports = [
  self.nixosModules.core
  self.nixosModules.audio
  self.nixosModules.docker
  # ... 20+ imports
];

# Then in home-manager:
home-manager.users.ada = {
  imports = [
    self.homeModules.cli
    self.homeModules.git
    # ... 6 imports
  ];
  home.stateVersion = "25.11";
};
```

Every host repeated this pattern. Adding a module meant editing both the
registry and the host configuration.

### Numbered parts files

The `flake.parts/` directory used numbered files to control evaluation order:

```
flake.parts/
├── 00-overlay.nix
├── 10-core.nix
├── 20-nixos-mods.nix
├── 30-home-mods.nix
├── 40-hosts.nix
├── 50-dev.nix
└── 60-docs.nix
```

This worked but was brittle -- the numbering implied an ordering dependency that
did not actually exist (Nix evaluation is lazy), and adding new concerns meant
choosing a number that "fit" in the sequence.

## What den solves

### Automatic discovery

`import-tree ./modules` walks the directory and imports every `.nix` file. Drop
a file in `modules/`, and it exists. No registration step. No numbering.

### Unified file tree

Aspects can have both `nixos` and `homeManager` sides in one file. The Rust
toolchain, for example, could provide system packages (`nixos`) and Helix LSP
config (`homeManager`) in a single `modules/devtools/rust.nix`.

### Includes replace imports + enable flags

Instead of importing a module and then enabling it, you include the aspect:

```nix
den.aspects.fern = {
  includes = [
    den.aspects.core
    den.aspects.audio
    den.aspects.docker
  ];
};
```

An aspect that is not included is not evaluated. No wasted computation, no
leftover options.

### Topology replaces withSystem + specialArgs

Three lines declare the entire host/user structure:

```nix
den.hosts.x86_64-linux.fern.users.ada = {};
den.hosts.aarch64-linux.moss.users.ada = {};
```

Den handles architecture resolution, Home Manager wiring, and flake output
generation. No `withSystem`, no `specialArgs`, no `nixpkgs.lib.nixosSystem`
boilerplate.

## What was gained

| Before | After |
|--------|-------|
| 7 numbered flake.parts files | 0 (import-tree discovers modules) |
| 2 module registries (28 + 6 entries) | 0 (no registration needed) |
| 2 directory trees (nix/modules + nix/home) | 1 unified modules/ tree |
| 2 host configuration.nix files with import lists | 2 host aspect files with includes |
| ~50 lines of withSystem/nixosSystem boilerplate | 3 lines of topology |
