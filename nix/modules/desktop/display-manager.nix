{ config, pkgs, lib, ... }:

let
  # Convenience for the two extra Wayland sessions
  caelestiaCfg = "/etc/nixos/caelestia-hyprland.conf";
  fernCfg   = "/etc/nixos/fern-hyprland.conf";    # you’ll create later
in
{
  # --- Extra Wayland session files
  services.xserver.displayManager.sessionPackages = [
    # Plain Hyprland already ships its own .desktop file.
    (pkgs.writeTextFile {
      name = "caelestia-shell";
      destination = "/share/wayland-sessions/caelestia-shell.desktop";
      text = ''
        [Desktop Entry]
        Name=Hyprland (Caelestia Shell)
        Exec=Hyprland --config ${caelestiaCfg}
        Type=Application
      '';
    })
    (pkgs.writeTextFile {
      name = "fern-shell";
      destination = "/share/wayland-sessions/fern-shell.desktop";
      text = ''
        [Desktop Entry]
        Name=Hyprland (Fern Shell)
        Exec=Hyprland --config ${fernCfg}
        Type=Application
      '';
    })
  ];
}

