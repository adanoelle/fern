# modules/desktop/art.nix — art and image creation tools
#
# Painting, pixel art, vectors and photo work. Opt-in per host. Aseprite
# is also listed by den.aspects.gamedev (as the sprite tool); both
# resolve to the same store path.
#
# Image mime defaults stay with modules/desktop/imv.nix: these tools all
# register image/* handlers, and the pins there keep xdg-open on the
# viewer. App configs are left unmanaged (mutable application state).
_: {
  den.aspects.art.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        krita
        aseprite
        inkscape
        gimp
      ];
    };
}
