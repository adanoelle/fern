{ den, ... }:
{
  den.aspects.caelestia-session.nixos = { pkgs, ... }:
    let
      caelestiaDesktop = pkgs.writeTextDir
        "share/wayland-sessions/hyprland-caelestia.desktop"
        ''
          [Desktop Entry]
          Name=Caelestia
          Comment=Hyprland with Caelestia QuickShell
          Type=Application
          Exec=Hyprland --config $HOME/.config/hypr/caelestia.conf
          DesktopNames=Hyprland
          X-Greeter-Session=true
        '';
    in
    {
      environment.systemPackages = with pkgs; [
        caelestiaDesktop
        hyprland
        quickshell caelestiaShell beatDetector
      ];
    };
}
