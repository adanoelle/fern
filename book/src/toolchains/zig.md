# Zig

> Zig compiler from nixpkgs.

## Aspect

The aspect (`modules/devtools/zig.nix`) installs `pkgs.zig` from the shared
nixpkgs pin into the user profile:

```nix
{ pkgs, ... }:
{
  home.packages = [ pkgs.zig ];
}
```

The language server (`zls`) is a separate package and is not installed.

## Key files

| File                       | Purpose                  |
| -------------------------- | ------------------------ |
| `modules/devtools/zig.nix` | Zig package installation |
