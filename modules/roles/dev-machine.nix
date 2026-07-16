# modules/roles/dev-machine.nix — development machine role
#
# System-level services and toolchains for a machine used for software
# development. User-level dev tooling lives in the ada-dev user layer
# (modules/user-ada-dev.nix); this role covers the nixos side.
{ den, ... }:
{
  den.aspects.dev-machine.includes = [
    den.aspects.c-cpp
    den.aspects.localstack
    den.aspects.rust
    den.aspects.node-ts
    den.aspects.aws-cli
  ];
}
