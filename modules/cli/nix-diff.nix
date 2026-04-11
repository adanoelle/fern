# modules/cli/nix-diff.nix — nix-diff: compare Nix derivations
{ den, ... }:
{
  den.aspects.nix-diff.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.nix-diff ];
    };
}
