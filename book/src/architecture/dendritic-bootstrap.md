# Dendritic Bootstrap

> `modules/dendritic.nix` is the bridge between flake-parts and den. It imports
> the den flake module, configures the Home Manager integration, and sets the
> default user class.

## The file

```nix
# modules/dendritic.nix
{ den, inputs, lib, ... }:
{
  imports = [
    (inputs.den.flakeModule or inputs.den.flakeModules.den)
  ];

  den = {
    ctx.user.includes = [ den._.mutual-provider ];

    ctx.hm-host.nixos.home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
      extraSpecialArgs = { inherit inputs; };
    };

    schema.user.classes = [ "homeManager" ];
  };
}
```

## Line by line

### Importing den

```nix
imports = [
  (inputs.den.flakeModule or inputs.den.flakeModules.den)
];
```

This pulls the den framework into flake-parts. The `or` fallback handles both
the old and new den API for the flake module attribute name. Once imported, all
files in the `modules/` tree can use `den.aspects`, `den.hosts`, `den.default`,
and the `den._` helper namespace.

### Mutual provider

```nix
ctx.user.includes = [ den._.mutual-provider ];
```

The mutual provider enables **aspect forwarding** from hosts to users. When a
host aspect includes `den.aspects.rust`, the Rust aspect's `nixos` side applies
to the host, and its `homeManager` side (if any) automatically forwards to the
host's users. Without this, you would need to include every aspect in both the
host and user configurations.

### Home Manager bridge

```nix
ctx.hm-host.nixos.home-manager = {
  useGlobalPkgs = true;
  useUserPackages = true;
  backupFileExtension = "backup";
  extraSpecialArgs = { inherit inputs; };
};
```

This configures how den integrates Home Manager into each host:

- **`useGlobalPkgs = true`** -- Home Manager uses the host's nixpkgs instance
  (with overlays), avoiding duplicate package builds.
- **`useUserPackages = true`** -- User packages are installed to the system
  profile, visible to system-level tools.
- **`backupFileExtension = "backup"`** -- When Home Manager finds an existing
  file it would overwrite, it renames the old file with a `.backup` extension
  instead of failing.
- **`extraSpecialArgs`** -- Makes `inputs` available to all Home Manager modules,
  so aspects can reference flake inputs directly (e.g., `inputs.fern` for the
  QuickShell bar package).

### Default user class

```nix
schema.user.classes = [ "homeManager" ];
```

Every user declared in `den.hosts` is automatically a Home Manager user. This
means `den.hosts.x86_64-linux.fern.users.ada = {}` creates both a NixOS user
account and a Home Manager configuration for `ada` without additional
boilerplate.

## What dendritic.nix replaces

In the old architecture, this wiring was spread across multiple files:

- `flake.parts/40-hosts.nix` called `nixpkgs.lib.nixosSystem` with manual
  `specialArgs` and Home Manager module imports
- Each host's `configuration.nix` configured `home-manager.useGlobalPkgs`,
  `home-manager.users.ada`, etc.
- Module forwarding between system and user was handled by importing modules in
  both places

Now all of this is three stanzas in one file.

## Key files

| File | Purpose |
|------|---------|
| `modules/dendritic.nix` | Den bootstrap (this page) |
| `modules/hosts.nix` | Topology that den wires via this bootstrap |
| `modules/defaults.nix` | Global defaults applied after bootstrap |
