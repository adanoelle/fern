# modules/cli/duf.nix — duf (modern df replacement)
_: {
  den.aspects.duf.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.duf ];
    };
}
