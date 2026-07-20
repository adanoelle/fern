# modules/desktop/imv.nix — minimal Wayland image viewer
#
# Default handler for raster images so xdg-open resolves to a viewer
# (e.g. the garden screenshot card's "open" action), not whatever
# editor last registered itself (Aseprite).
_: {
  den.aspects.imv.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.imv ];

      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "image/png" = [ "imv.desktop" ];
          "image/jpeg" = [ "imv.desktop" ];
          "image/gif" = [ "imv.desktop" ];
          "image/webp" = [ "imv.desktop" ];
          "image/bmp" = [ "imv.desktop" ];
          "image/tiff" = [ "imv.desktop" ];
        };
      };
    };
}
