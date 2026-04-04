{ den, ... }:
{
  den.aspects.tree.homeManager = { pkgs, ... }: {
    home.packages = with pkgs; [ tree ];
  };
}
