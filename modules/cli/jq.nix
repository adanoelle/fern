# modules/cli/jq.nix — jq JSON processor
_: {
  den.aspects.jq.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.jq ];
    };
}
