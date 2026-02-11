# NixOS & Flakes

> NixOS is a Linux distribution where the entire operating system is built from
> a declarative configuration, and flakes are the mechanism that makes that
> configuration reproducible.

Most Linux distributions manage software through imperative commands: you run
`apt install` or `pacman -S`, and the system's state diverges from any written
record over time. NixOS inverts this. You write a configuration file that
describes every package, service, and setting, then the system is _built_ from
that description. If something breaks, you can roll back to a previous
generation instantly because every build is stored in the Nix store
(`/nix/store/`).

Nix (the package manager underlying NixOS) uses a purely functional approach:
packages are built from inputs (source code, dependencies) through build
instructions, and the output is stored at a content-addressed path. Two builds
with the same inputs always produce the same output. This eliminates "works on
my machine" problems at the system level.

## What is a flake?

A flake is a directory containing a `flake.nix` file that declares its
**inputs** (dependencies) and **outputs** (what it provides). Flakes replace the
older channel-based approach to pinning nixpkgs versions.

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { nixpkgs, home-manager, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      modules = [ ./configuration.nix ];
    };
  };
}
```

**Inputs** are other flakes or repositories your configuration depends on. When
you run `nix flake update`, Nix resolves every input to a specific Git revision
and writes the result to `flake.lock`. This lock file ensures that anyone
building from the same lock file gets the exact same package set.

**Outputs** are what your flake produces. In a NixOS configuration, the primary
output is `nixosConfigurations.<hostname>` -- a complete system definition that
`nixos-rebuild` uses to build your machine.

## The lock file

`flake.lock` is a JSON file that pins every input to a specific revision:

```json
{
  "nodes": {
    "nixpkgs": {
      "locked": {
        "rev": "abc123...",
        "type": "github",
        "owner": "NixOS",
        "repo": "nixpkgs"
      }
    }
  }
}
```

You should commit `flake.lock` to version control. It guarantees reproducible
builds: even months later, `nixos-rebuild` will produce the same system because
every dependency is pinned.

Update inputs selectively with `nix flake update` (all inputs) or
`nix flake update nixpkgs` (just one).

## Why reproducibility matters

With a committed `flake.nix` and `flake.lock`:

- A fresh install from the same config produces an identical system
- Rolling back to a previous commit in Git rolls back the system
- Two machines using the same config and lock file are identical
- You can audit every dependency, all the way down to the compiler that built
  your compiler
