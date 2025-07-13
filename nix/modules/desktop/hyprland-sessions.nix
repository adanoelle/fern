# --- Hyprland Sessions
{ config, pkgs, lib, ... }:

let 
  # --- Desktop entry for the standard Hyprland session
  hyprlandSession = pkgs.writeTextFile {
    name = "hyprland-session";
    destination = "/share/wayland-sessions/hyprland.desktop";  # installed in share/wayland-sessions
    text = ''
      [Desktop Entry]
      Name=Hyprland
      Comment=Tiling Wayland compositor (Hyprland)
      Exec=${pkgs.hyprland}/bin/Hyprland
      Type=Application
      # Hyprland class name as DesktopNames (for consistency)
      DesktopNames=Hyprland
    '';
  };

  # --- Desktop entry for the Caelestia-themed Hyprland session
  caelestiaSession = pkgs.writeTextFile {
    name = "hyprland-caelestia-session";
    destination = "/share/wayland-sessions/hyprland-caelestia.desktop";
    text = ''
      [Desktop Entry]
      Name=Caelestia
      Comment=Hyprland with Caelestia theme
      Exec=${pkgs.hyprland}/bin/Hyprland --config /home/ada/.config/hypr/caelestia.conf
      Type=Application
      DesktopNames=Caelestia
    '';
  };
in {
  # Add the session files to the system profile so they're visible to ReGreet
  environment.systemPackages = [ hyprlandSession caelestiaSession ];
}

