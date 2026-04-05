# Zig

> Latest Zig compiler via the zig-overlay flake input.

## Overview

Zig is provided through the `zig-overlay` flake input, which is applied as an
overlay in `modules/core.nix`. This makes `pkgs.zig` available system-wide with
the latest official release.

## Aspect

Zig is installed via the overlay applied in `modules/core.nix` and exposed
through the aspect (`modules/devtools/zig.nix`):


```nix
{ pkgs, ... }:
{
  home.packages = [ pkgs.zig ];
}
```

Zig includes a built-in language server (ZLS) and build system, so no additional
tooling is needed.

## Key files

| File                       | Purpose                     |
| -------------------------- | --------------------------- |
| `modules/devtools/zig.nix` | Zig package installation    |
| `flake.nix`                | `zig-overlay` input         |
| `modules/core.nix`         | Zig overlay applied to pkgs |
