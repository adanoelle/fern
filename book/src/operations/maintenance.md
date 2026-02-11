# Garbage Collection & Maintenance

> Regular garbage collection removes old generations and reclaims disk space in
> the Nix store.

## Automatic garbage collection

The core module (`nix/modules/core.nix`) configures automatic weekly garbage
collection:

```nix
nix.gc = {
  automatic = true;
  dates     = "weekly";
  options   = "--delete-older-than 10d";
};
```

This runs `nix-collect-garbage` every week and removes store paths not
referenced by any generation newer than 10 days.

## Manual garbage collection

```bash
# Remove old generations and collect garbage
just gc

# Or directly:
sudo nix-collect-garbage -d

# Remove generations older than 30 days
sudo nix-collect-garbage --delete-older-than 30d
```

The `-d` flag first deletes all old system and user profile generations, then
collects unreferenced store paths.

## Generation management

List current system generations:

```bash
sudo nix-env --list-generations -p /nix/var/nix/profiles/system
```

Roll back to the previous generation:

```bash
just rollback
# or: sudo nixos-rebuild switch --rollback
```

Each `nixos-rebuild switch` creates a new generation. Generations are cheap
(they are just symlinks into the Nix store), but the store paths they reference
consume disk space.

## Flake updates

Update all flake inputs to their latest revisions:

```bash
just update
# or: nix flake update
```

Update a single input:

```bash
nix flake update nixpkgs
```

After updating, rebuild and test before switching:

```bash
just update && just test
```

## Nix store optimization

Deduplicate identical files in the Nix store:

```bash
nix store optimise
```

This creates hard links between identical files, saving disk space without
affecting functionality.

## Checking disk usage

```bash
# Size of the Nix store
du -sh /nix/store

# Find large store paths
nix path-info --all --size --sort-by size | tail -20

# Visualize dependency tree
nix-tree
```

`nix-tree` (installed via the CLI home module) provides an interactive TUI for
exploring the dependency graph of any store path.
