# modules/cli/fd.nix — fd find replacement
{ den, ... }:
{
  den.aspects.fd.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.fd ];
    };
}
