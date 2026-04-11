# modules/desktop/daw.nix — DAW applications
{ den, ... }:
{
  den.aspects.daw.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        ardour
        reaper
      ];
    };
}
