# Zig

> Latest Zig compiler via the zig-overlay flake input.

## Overview

Zig is provided through the `zig-overlay` flake input, which is applied as an
overlay in `flake.parts/10-core.nix`. This makes `pkgs.zig` available
system-wide with the latest official release.

## System module

Zig is installed via the overlay applied in `10-core.nix` rather than through a
dedicated system module. The overlay makes `pkgs.zig` available with the latest
version from the zig-overlay.

## Home module

The home module (`nix/home/devtools/zig.nix`) installs the Zig package:

```nix
{ pkgs, ... }:
{
  home.packages = [ pkgs.zig ];
}
```

Zig includes a built-in language server (ZLS) and build system, so no additional
tooling is needed.

## Key files

| File                        | Purpose                     |
| --------------------------- | --------------------------- |
| `nix/home/devtools/zig.nix` | Zig package installation    |
| `flake.nix`                 | `zig-overlay` input         |
| `flake.parts/10-core.nix`   | Zig overlay applied to pkgs |
