# modules/cli/fd.nix — fd find replacement
_: {
  den.aspects.fd.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.fd ];
    };
}
