# modules/cli/jq.nix — jq JSON processor
{ den, ... }:
{
  den.aspects.jq.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.jq ];
    };
}
