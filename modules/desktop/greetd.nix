# modules/desktop/greetd.nix — greetd + tuigreet session launcher
#
# tuigreet is a TTY greeter, so it can't hit GPU-specific rendering bugs
# (regreet corrupted on fern's Granite Ridge iGPU). The Niri session
# entry is offered only when the host enables Niri.
_: {
  den.aspects.greetd.nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      niriSession = pkgs.writeTextDir "share/wayland-sessions/niri.desktop" ''
        [Desktop Entry]
        Name=Niri
        Exec=niri-session
        Type=Application
      '';
      sessionDirs = lib.optionalString config.programs.niri.enable "${niriSession}/share/wayland-sessions";
    in
    {
      services.greetd = {
        enable = true;
        settings.default_session = {
          command = lib.concatStringsSep " " (
            [
              "${pkgs.tuigreet}/bin/tuigreet"
              "--time"
              "--remember"
            ]
            ++ lib.optionals (sessionDirs != "") [
              "--sessions"
              sessionDirs
            ]
          );
          user = "greeter";
        };
      };

      services.seatd.enable = true;

      # Compositors are NOT enabled here: hosts opt in themselves (see
      # host-fern.nix) and the session list above follows what they chose.
      xdg.portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      };

      security.polkit.enable = true;

      # "video"/"input"/"seat" group membership is granted centrally in
      # modules/users.nix, conditional on services.greetd.enable.
    };
}
