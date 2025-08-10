{ lib, pkgs, config, ... }:
let cfg = config.desktop.hyprland;
in
lib.mkIf (cfg.enable && cfg.wallpaper.enable && !cfg.theme.enable) {
  xdg.configFile."hypr/hyprpaper.conf".text = ''
    preload = ${cfg.wallpaper.path}
    wallpaper = ${cfg.wallpaper.monitor},${cfg.wallpaper.path}
    ipc = off
  '';

  systemd.user.services.hyprpaper = {
    Unit = { Description = "Hyprland wallpaper"; After = [ "graphical-session.target" ]; PartOf = [ "hyprland-session.target" ]; };
    Service = { ExecStart = "${pkgs.hyprpaper}/bin/hyprpaper"; Restart = "on-failure"; };
    Install.WantedBy = [ "hyprland-session.target" ];
  };
}

