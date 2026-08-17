# modules/cli/procs.nix — procs (modern ps replacement)
_: {
  den.aspects.procs.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.procs ];
    };
}
