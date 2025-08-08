{ pkgs, lib, config, ... }:

let
  # ── Catppuccin Frappé palette (tweak once, reuse everywhere)
  palette = {
    base   = "#303446"; mantle = "#292c3c"; crust  = "#232634";
    text   = "#c6d0f5"; mauve  = "#ca9ee6"; blue   = "#8caaee";
    green  = "#a6d189"; red    = "#e78284"; yellow = "#e5c890";
  };

  cfg = config.desktop.hyprland;

  mkBind = type: combo: action: "${type} = ${cfg.modKey}, ${combo}, ${action}";
in
{
  ## ───────────────────────── Options ─────────────────────────
  options.desktop.hyprland = {
    enable  = lib.mkEnableOption "Hyprland Wayland compositor";
    modKey  = lib.mkOption { type = lib.types.str; default = "SUPER"; };
    terminal = lib.mkOption { type = lib.types.str; default = "ghostty"; };
    appRunner = lib.mkOption { type = lib.types.str; default = "wofi --show drun"; };
    reloadCmd = lib.mkOption { type = lib.types.str; default = "hyprctl reload"; };

    bar.enable   = lib.mkEnableOption "Waybar status bar";
    idle.enable  = lib.mkEnableOption "hypridle idle timer";
    lock.enable  = lib.mkEnableOption "hyprlock screen locker";
    wallpaper = {
      enable = lib.mkEnableOption "hyprpaper wallpaper";
      path   = lib.mkOption { type = lib.types.str; default = "${config.home.homeDirectory}/Pictures/wallpaper.png"; };
      monitor = lib.mkOption { type = lib.types.str; default = "eDP-1"; }; # change for your setup
    };

    style = {
      gapsIn   = lib.mkOption { type = lib.types.int; default = 6; };
      gapsOut  = lib.mkOption { type = lib.types.int; default = 12; };
      border   = lib.mkOption { type = lib.types.int; default = 2; };
    };
  };

  ## ───────────────────────── Config ─────────────────────────
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ wl-clipboard wofi ghostty firefox ]
      ++ lib.optionals cfg.idle.enable [ hypridle ]
      ++ lib.optionals cfg.lock.enable [ hyprlock ]
      ++ lib.optionals cfg.wallpaper.enable [ hyprpaper ]
      ++ lib.optionals cfg.bar.enable [ waybar ];

    xdg.portal = { enable = true; extraPortals = [ pkgs.xdg-desktop-portal-wlr ]; };

    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        exec-once = [
          "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd DISPLAY XAUTHORITY WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP"
        ];

        general = {
          gaps_in = cfg.style.gapsIn;
          gaps_out = cfg.style.gapsOut;
          border_size = cfg.style.border;
          "col.active_border"   = "rgba(${builtins.substring 1 6 palette.mauve}ff)";
          "col.inactive_border" = "rgba(${builtins.substring 1 6 palette.base}ff)";
          layout = "dwindle";
        };

        # Keys
        bind = [
          (mkBind "bind" "Return" "exec, ${cfg.terminal}")
          (mkBind "bind" "Q"      "killactive")
          (mkBind "bind" "R"      "exec, ${cfg.appRunner}")
          "bind = ${cfg.modKey} SHIFT, R, exec, ${cfg.reloadCmd}"

          # Focus
          (mkBind "bind" "H" "movefocus, l")
          (mkBind "bind" "J" "movefocus, d")
          (mkBind "bind" "K" "movefocus, u")
          (mkBind "bind" "L" "movefocus, r")

          # Workspaces 1..9
          (mkBind "bind" "1" "workspace, 1")
          (mkBind "bind" "2" "workspace, 2")
          (mkBind "bind" "3" "workspace, 3")
          (mkBind "bind" "4" "workspace, 4")
          (mkBind "bind" "5" "workspace, 5")
          (mkBind "bind" "6" "workspace, 6")
          (mkBind "bind" "7" "workspace, 7")
          (mkBind "bind" "8" "workspace, 8")
          (mkBind "bind" "9" "workspace, 9")

          # Move window to workspace 1..9
          "bind = ${cfg.modKey} SHIFT, 1, movetoworkspace, 1"
          "bind = ${cfg.modKey} SHIFT, 2, movetoworkspace, 2"
          "bind = ${cfg.modKey} SHIFT, 3, movetoworkspace, 3"
          "bind = ${cfg.modKey} SHIFT, 4, movetoworkspace, 4"
          "bind = ${cfg.modKey} SHIFT, 5, movetoworkspace, 5"
          "bind = ${cfg.modKey} SHIFT, 6, movetoworkspace, 6"
          "bind = ${cfg.modKey} SHIFT, 7, movetoworkspace, 7"
          "bind = ${cfg.modKey} SHIFT, 8, movetoworkspace, 8"
          "bind = ${cfg.modKey} SHIFT, 9, movetoworkspace, 9"
        ];

        bindm = [ "${cfg.modKey}, mouse:273, resizewindow" ];
      };
    };

    # Session vars for Ghostty terminfo
    home.sessionVariables.TERMINFO_DIRS = "${pkgs.ghostty}/share/terminfo";

    ## Waybar (bar)
    programs.waybar = lib.mkIf cfg.bar.enable {
      enable = true;
      settings.mainBar = {
        layer = "top"; position = "top"; height = 30;
        modules-left = [ "hyprland/workspaces" "hyprland/window" ];
        modules-right = [ "cpu" "memory" "pulseaudio" "clock" ];
        "hyprland/workspaces" = { disable-scroll = true; all-outputs = true; format = "{name}"; };
        "hyprland/window".max-length = 60;
        pulseaudio = { format = "{volume}%  {icon}"; format-muted = "muted "; };
        clock = { format = "{:%a %b %d  %H:%M}"; tooltip = true; };
      };
      style = ''
        @define-color base   ${palette.base};
        @define-color mantle ${palette.mantle};
        @define-color crust  ${palette.crust};
        @define-color text   ${palette.text};
        @define-color mauve  ${palette.mauve};

        * { font-family: "FiraCode Nerd Font","JetBrainsMono Nerd Font",monospace; font-size: 12pt; }
        window#waybar { background: @mantle; color: @text; border-bottom: 1px solid @crust; }
        #workspaces button { padding: 0 10px; color: @text; background: transparent; border: none; }
        #workspaces button.active { color: @mantle; background: @mauve; border-radius: 8px; }
        #clock, #cpu, #memory, #pulseaudio { padding: 0 10px; margin: 0 4px; background: @base; border-radius: 8px; }
      '';
    };

    systemd.user.services.waybar = lib.mkIf cfg.bar.enable {
      Unit = { Description = "Waybar"; After = [ "graphical-session.target" ]; PartOf = [ "hyprland-session.target" ]; };
      Service = { ExecStart = "${pkgs.waybar}/bin/waybar"; Restart = "on-failure"; };
      Install.WantedBy = [ "hyprland-session.target" ];
    };

    ## hypridle
    xdg.configFile."hypr/hypridle.conf".text = lib.mkIf cfg.idle.enable ''
      listener {
        timeout = 300
        on-timeout = brightnessctl -s set 10%
        on-resume = brightnessctl -r
      }
      listener {
        timeout = 600
        on-timeout = hyprlock
      }
      listener {
        timeout = 1200
        on-timeout = systemctl suspend
      }
    '';
    systemd.user.services.hypridle = lib.mkIf cfg.idle.enable {
      Unit = { Description = "Hyprland idle"; After = [ "graphical-session.target" ]; PartOf = [ "hyprland-session.target" ]; };
      Service = { ExecStart = "${pkgs.hypridle}/bin/hypridle"; Restart = "on-failure"; };
      Install.WantedBy = [ "hyprland-session.target" ];
    };

    ## hyprlock (Frappé)
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

    ## hyprpaper
    xdg.configFile."hypr/hyprpaper.conf".text = lib.mkIf cfg.wallpaper.enable ''
      preload = ${cfg.wallpaper.path}
      wallpaper = ${cfg.wallpaper.monitor},${cfg.wallpaper.path}
      ipc = off
    '';
    systemd.user.services.hyprpaper = lib.mkIf cfg.wallpaper.enable {
      Unit = { Description = "Hyprland wallpaper"; After = [ "graphical-session.target" ]; PartOf = [ "hyprland-session.target" ]; };
      Service = { ExecStart = "${pkgs.hyprpaper}/bin/hyprpaper"; Restart = "on-failure"; };
      Install.WantedBy = [ "hyprland-session.target" ];
    };
  };
}

