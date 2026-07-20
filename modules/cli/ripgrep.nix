# modules/cli/ripgrep.nix — ripgrep grep replacement
_: {
  den.aspects.ripgrep.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.ripgrep ];
    };
}
