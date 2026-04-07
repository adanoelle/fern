# modules/garden.nix — import garden den namespace from garden-shell
{ inputs, ... }:
{
  imports = [
    (inputs.den.namespace "garden" [ inputs.garden-shell ])
  ];
}
