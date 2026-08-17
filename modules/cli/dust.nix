# modules/cli/dust.nix — dust (modern du replacement)
_: {
  den.aspects.dust.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.dust ];
    };
}
