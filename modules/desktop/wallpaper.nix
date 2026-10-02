# modules/desktop/wallpaper.nix — painted wallpaper for the niri session
#
# John Singer Sargent, "Madame X (Virginie Amélie Avegno Gautreau)"
# (1883–84), oil on canvas. The Metropolitan Museum of Art, 16.53
# (Arthur Hoppock Hearn Fund, 1916); public domain, Met Open Access.
#
# A full-length portrait is tall (the scan is 2336x4000) and the docked
# ultrawide is 3440x1440, so `fill` would crop through the figure.
# Instead `fit` scales it to the screen height and centres it, and the
# sides are pure black: the Met's scan already carries a black border
# around the canvas, so it reads as one painting hung in a dark room.
#
# The image is fetched from the Met's Open Access server and pinned by
# hash, so it lives in the store, not in ~/media. swaybg draws with
# wl_shm (no GL), so it needs no nixGL wrapping on Ubuntu. It runs as a
# user service bound to graphical-session.target, which niri.service
# activates on both NixOS and the standalone-home laptop.
#
# Hyprland on fern keeps its own awww wallpaper (desktop/_hyprland);
# this aspect is for niri sessions.
_: {
  den.aspects.wallpaper.homeManager =
    { pkgs, lib, ... }:
    let
      painting = pkgs.fetchurl {
        name = "sargent-madame-x.jpg";
        url = "https://images.metmuseum.org/CRDImages/ad/original/DP-29006-001.jpg";
        hash = "sha256-7KtaLsKGJm8ZAUmCO1TLv7WR+PrXBmwauG7yH5T7mus=";
      };
    in
    {
      systemd.user.services.wallpaper = {
        Unit = {
          Description = "Desktop wallpaper (swaybg): Sargent, Madame X";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
          # Restart when the image changes on a switch.
          X-Restart-Triggers = [ "${painting}" ];
        };
        Service = {
          ExecStart = "${lib.getExe pkgs.swaybg} --mode fit --color 000000 --image ${painting}";
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
