# modules/desktop/greetd.nix — greetd + tuigreet session launcher
#
# tuigreet is a TTY greeter, so it can't hit GPU-specific rendering bugs
# (regreet corrupted on fern's Granite Ridge iGPU). Session entries are
# offered only for compositors the host actually enables; Niri is listed
# first so it is the default choice.
{ den, ... }:
{
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
      hyprlandSession = pkgs.writeTextDir "share/wayland-sessions/hyprland.desktop" ''
        [Desktop Entry]
        Name=Hyprland
        Exec=Hyprland
        Type=Application
      '';
      sessionDirs = lib.concatStringsSep ":" (
        lib.optional config.programs.niri.enable "${niriSession}/share/wayland-sessions"
        ++ lib.optional config.programs.hyprland.enable "${hyprlandSession}/share/wayland-sessions"
      );
    in
    {
      services.greetd = {
        enable = true;
        settings.default_session = {
          command = lib.concatStringsSep " " (
            [
              "${pkgs.greetd.tuigreet}/bin/tuigreet"
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
      programs.hyprland.enable = true;

      xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-hyprland
          xdg-desktop-portal-gtk
        ];
      };

      security.polkit.enable = true;

      environment.systemPackages = with pkgs; [
        hyprland
        sway
        wl-clipboard
        quickshell
      ];

      users.users.ada.extraGroups = [
        "video"
        "input"
        "seat"
      ];
    };
}
