{ lib, pkgs, config, ... }:
let cfg = config.desktop.hyprland;
in
lib.mkIf cfg.enable {
  # hypridle
  xdg.configFile."hypr/hypridle.conf".text = lib.mkIf cfg.idle.enable ''
    listener { timeout = 300  on-timeout = brightnessctl -s set 10%  on-resume = brightnessctl -r }
    listener { timeout = 600  on-timeout = hyprlock }
    listener { timeout = 1200 on-timeout = systemctl suspend }
  '';
  systemd.user.services.hypridle = lib.mkIf cfg.idle.enable {
    Unit = { Description = "Hyprland idle"; After = [ "graphical-session.target" ]; PartOf = [ "hyprland-session.target" ]; };
    Service = { ExecStart = "${pkgs.hypridle}/bin/hypridle"; Restart = "on-failure"; };
    Install.WantedBy = [ "hyprland-session.target" ];
  };

  # hyprlock (Frappé)
  xdg.configFile."hypr/hyprlock.conf".text = lib.mkIf cfg.lock.enable ''
    general { no_fade_in = false; hide_cursor = true; }
    background {
      monitor = ${cfg.wallpaper.monitor}
      path = ${cfg.wallpaper.path}
      blur_passes = 3
      blur_size = 5
    }
    colors {
      text = rgb(198,208,245)
      input_field = rgb(48,52,70)
      input_field_border = rgb(202,158,230)
    }
    font { name = "FiraCode Nerd Font"; size = 18 }
  '';
}

