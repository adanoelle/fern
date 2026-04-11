# modules/cli/ripgrep.nix — ripgrep grep replacement
{ den, ... }:
{
  den.aspects.ripgrep.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.ripgrep ];
    };
}
