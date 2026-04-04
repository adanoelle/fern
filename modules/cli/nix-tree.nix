{ den, ... }:
{
  den.aspects.nix-tree.homeManager = { pkgs, ... }: {
    home.packages = [ pkgs.nix-tree ];
  };
}
