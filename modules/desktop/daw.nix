# modules/desktop/daw.nix — DAW applications
_: {
  den.aspects.daw.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        ardour
        reaper
      ];
    };
}
