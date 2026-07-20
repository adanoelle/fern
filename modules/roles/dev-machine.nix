# modules/roles/dev-machine.nix — development machine role
#
# Host-level services for a machine used for software development.
# Language toolchains live in the devtools bundle
# (modules/devtools/bundle.nix), included via the ada-dev user layer.
# Keep the two disjoint: an aspect included from both paths has its
# nixos module applied twice, and list options merge twice (this broke
# localstack's oci-container port mapping).
{ den, ... }:
{
  den.aspects.dev-machine.includes = [
    den.aspects.localstack
    den.aspects.aws-cli
  ];
}
