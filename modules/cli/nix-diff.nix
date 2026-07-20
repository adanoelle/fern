# modules/cli/nix-diff.nix — nix-diff: compare Nix derivations
_: {
  den.aspects.nix-diff.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.nix-diff ];
    };
}
