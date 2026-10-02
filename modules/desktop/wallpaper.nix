# modules/desktop/wallpaper.nix — painted wallpaper for the niri session
#
# John Singer Sargent, "Nonchaloir (Repose)" (1911), oil on canvas.
# National Gallery of Art, Washington, object 35080; open access (public
# domain). A horizontal portrait, so it fills the screen instead of
# being letterboxed.
#
# Two renditions come straight from the NGA's IIIF server (master is
# 18332x15338), each pinned by hash:
#   - ultrawide: a 2.4:1 band from ~18% to ~68% of the canvas height,
#     delivered at exactly 3440x1440. A plain centre crop would put her
#     head under the bar; this band keeps the head clear of it plus the
#     clasped hands, shawl and gilt table.
#   - panel: the whole painting at 2400 px wide, filled (lightly cropped)
#     onto the 16:10 laptop panel and any other output.
# swaybg picks per output. It can only match the ultrawide by connector
# name ("DP-2"): its make/model matching parses a "(name)" suffix niri's
# wl_output description doesn't have. On another dock/port the monitor
# just gets the full painting centre-cropped.
#
# swaybg draws with wl_shm (no GL), so no nixGL wrapping on Ubuntu. It
# runs as a user service bound to graphical-session.target, which
# niri.service activates on NixOS and on the standalone-home laptop.
# Hyprland on fern keeps its own awww wallpaper (desktop/_hyprland).
_: {
  den.aspects.wallpaper.homeManager =
    { pkgs, lib, ... }:
    let
      iiif = "https://api.nga.gov/iiif/718e014f-fb5f-4702-a95a-db496abefeb7";
      ultrawide = pkgs.fetchurl {
        name = "sargent-nonchaloir-ultrawide.jpg";
        url = "${iiif}/0,2760,18332,7673/3440,1440/0/default.jpg";
        hash = "sha256-KkYKXQip0BPY4Lej3MS6u1jNZbnihJRNCbd6d6B1iyQ=";
      };
      panel = pkgs.fetchurl {
        name = "sargent-nonchaloir-panel.jpg";
        url = "${iiif}/full/2400,/0/default.jpg";
        hash = "sha256-Ib87L3l9H1H/dttAcSuk7MCFlOpc7+d5XYnWu2B0HeU=";
      };
    in
    {
      systemd.user.services.wallpaper = {
        Unit = {
          Description = "Desktop wallpaper (swaybg): Sargent, Nonchaloir";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
          # Restart when either image changes on a switch.
          X-Restart-Triggers = [
            "${ultrawide}"
            "${panel}"
          ];
        };
        Service = {
          ExecStart = lib.concatStringsSep " " [
            (lib.getExe pkgs.swaybg)
            "--output '*' --mode fill --image ${panel}"
            "--output DP-2 --mode fill --image ${ultrawide}"
          ];
          Restart = "on-failure";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };

      # Draw the wallpaper behind the overview too, instead of niri's
      # flat backdrop colour. swaybg's layer namespace is "wallpaper".
      programs.niri.settings.layer-rules = [
        {
          matches = [ { namespace = "^wallpaper$"; } ];
          place-within-backdrop = true;
        }
      ];
    };
}
