# Provides a .desktop file in share/wayland-sessions
{ pkgs, ... }:

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
  # Make the entry visible to every greeter/DM
  environment.systemPackages = with pkgs; [
    caelestiaDesktop          # the file we just built
    hyprland                  # brings hyprland.desktop
    quickshell caelestiaShell beatDetector  # runtime deps
  ];
}

