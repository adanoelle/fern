# modules/devtools/bundle.nix — development toolchain bundle
#
# Language toolchains only. Docker is a host service and comes from the
# workstation role (modules/roles/workstation.nix): this bundle reaches
# hosts through the ada-dev user layer, and an aspect included from both
# paths has its nixos side applied twice.
{ den, ... }:
{
  den.aspects.devtools = {
    includes = [
      den.aspects.rust
      den.aspects.node-ts
      den.aspects.c-cpp
      den.aspects.python
      den.aspects.ada-lang
      den.aspects.zig
      den.aspects.vm-host
    ];
  };
}
