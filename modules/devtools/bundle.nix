# modules/devtools/bundle.nix — development toolchain bundle
{ den, ... }:
{
  den.aspects.devtools = {
    includes = [
      den.aspects.docker
      den.aspects.rust
      den.aspects.node-ts
      den.aspects.c-cpp
      den.aspects.python
      den.aspects.csharp
      den.aspects.ada-lang
      # localstack is a system container service owned by the dev-machine
      # role (modules/roles/dev-machine.nix). Including it here too applies
      # its nixos module twice, duplicating the oci-container port list
      # (docker then fails binding 4566 against itself).
      den.aspects.zig
      den.aspects.gamedev
    ];
  };
}
