# What Changed

> A summary of the structural changes from the garden.* / flake-parts
> architecture to the den aspect framework.

## New flake inputs

| Input | Purpose |
|-------|---------|
| `den` | Aspect framework (topology, includes, dual-side modules) |
| `import-tree` | Recursive module discovery (replaces manual import lists) |

Both follow nixpkgs. No inputs were removed.

## Directory changes

### Deleted

```
flake.parts/               # Entire directory (7 files)
  00-overlay.nix
  10-core.nix
  20-nixos-mods.nix        # Module registry (replaced by import-tree)
  30-home-mods.nix         # Module registry (replaced by import-tree)
  40-hosts.nix             # Host definitions (replaced by topology)
  50-dev.nix               # Dev shell (moved to modules/dev.nix)
  60-docs.nix              # Docs build (moved to modules/docs.nix)

nix/                       # Entire directory
  modules/                 # System modules (merged into modules/)
  home/                    # Home Manager modules (merged into modules/)

hosts/fern/configuration.nix   # Host imports (replaced by host aspect)
hosts/moss/configuration.nix   # Host imports (replaced by host aspect)
```

### Created

```
modules/                   # Unified aspect tree
  dendritic.nix            # Den bootstrap
  hosts.nix                # Topology
  defaults.nix             # Global defaults
  overlays.nix             # Nixpkgs config (from 10-core.nix)
  host-fern.nix            # Fern host aspect (from configuration.nix + 40-hosts.nix)
  host-moss.nix            # Moss host aspect (from configuration.nix + 40-hosts.nix)
  user-ada.nix             # User aspect (from home-manager.users.ada blocks)
  dev.nix                  # Dev shell (from 50-dev.nix)
  docs.nix                 # Docs build (from 60-docs.nix)
```

### Moved and restructured

| Old path | New path | Notes |
|----------|----------|-------|
| `nix/modules/audio.nix` | `modules/audio.nix` | Wrapped in `den.aspects.audio` |
| `nix/modules/core.nix` | `modules/core.nix` | Wrapped in `den.aspects.core` |
| `nix/modules/devtools/rust.nix` | `modules/devtools/rust.nix` | Wrapped in `den.aspects.rust` |
| `nix/modules/devtools/docker.nix` | `modules/devtools/docker.nix` | Wrapped in `den.aspects.docker` |
| `nix/home/cli.nix` (aggregator) | `modules/cli/bundle.nix` | Aggregator → bundle |
| `nix/home/git/default.nix` | `modules/git/bundle.nix` | Aggregator → orchestrator bundle |
| `nix/home/desktop.nix` | `modules/desktop/bundle.nix` | Aggregator → bundle |
| `nix/home/devtools.nix` | `modules/devtools/bundle.nix` | Aggregator → bundle |
| `nix/home/shells.nix` | `modules/shells/bundle.nix` | Aggregator → bundle |
| `nix/home/cli/bat.nix` | `modules/cli/bat.nix` | Wrapped in `den.aspects.bat` |
| `nix/home/git/core.nix` | `modules/git/core.nix` | Wrapped in `den.aspects.git-core` |
| `nix/home/desktop/hyprland/` | `modules/desktop/_hyprland/` | Underscore convention for sub-modules |
| `nix/modules/devtools/c-toolchain.nix` | `modules/devtools/c-cpp.nix` | Renamed for clarity |
| `nix/modules/devtools/ada-toolchain.nix` | `modules/devtools/ada.nix` | Renamed for clarity |

## flake.nix changes

**Before:**
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

**After:**
```nix
outputs = inputs@{ flake-parts, import-tree, ... }:
  flake-parts.lib.mkFlake { inherit inputs; }
    (import-tree ./modules);
```

Seven explicit imports collapsed to one `import-tree` call.

## Conceptual changes

| Concept | Old term | New term |
|---------|----------|----------|
| Unit of configuration | Module | Aspect |
| Module grouping | Aggregator (`cli.nix` with imports list) | Bundle (`cli/bundle.nix` with includes) |
| Module activation | `enable = true` flag | `includes` in host/user aspect |
| Module registration | `flake.nixosModules.*` entry | None (auto-discovered) |
| Host definition | `nixpkgs.lib.nixosSystem` call | `den.hosts` topology line |
| Host configuration | `configuration.nix` with imports | Host aspect with includes |
| User wiring | `home-manager.users.ada` block | User aspect + mutual provider |
