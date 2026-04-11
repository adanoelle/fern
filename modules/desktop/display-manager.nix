{ den, ... }:
{
  den.aspects.display-manager.nixos =
    { pkgs, ... }:
    let
      caelestiaCfg = "/etc/nixos/caelestia-hyprland.conf";
      fernCfg = "/etc/nixos/fern-hyprland.conf";
    in
    {
      services.xserver.displayManager.sessionPackages = [
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
    };
}
