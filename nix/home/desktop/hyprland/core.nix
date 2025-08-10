{ pkgs, lib, config, ... }:

let
  palette = {
    base   = "#303446"; mantle = "#292c3c"; crust  = "#232634";
    text   = "#c6d0f5"; mauve  = "#ca9ee6"; blue   = "#8caaee";
    green  = "#a6d189"; red    = "#e78284"; yellow = "#e5c890";
  };

  cfg = config.desktop.hyprland;
  mkBind = type: combo: action: "${type} = ${cfg.modKey}, ${combo}, ${action}";
in
{
  ## ───────────────────── Options ─────────────────────
  options.desktop.hyprland = {
    enable   = lib.mkEnableOption "Hyprland Wayland compositor";
    modKey   = lib.mkOption { type = lib.types.str; default = "SUPER"; };
    terminal = lib.mkOption { type = lib.types.str; default = "ghostty"; };
    appRunner = lib.mkOption { type = lib.types.str; default = "wofi --show drun"; };
    reloadCmd = lib.mkOption { type = lib.types.str; default = "hyprctl reload"; };

    bar.enable  = lib.mkEnableOption "Waybar status bar";
    idle.enable = lib.mkEnableOption "hypridle idle timer";
    lock.enable = lib.mkEnableOption "hyprlock screen locker";

    wallpaper = {
      enable  = lib.mkEnableOption "hyprpaper wallpaper";
      path    = lib.mkOption { type = lib.types.str; default = "${config.home.homeDirectory}/Pictures/wallpaper.png"; };
      monitor = lib.mkOption { type = lib.types.str; default = "eDP-1"; };
    };

    style = {
      gapsIn   = lib.mkOption { type = lib.types.int; default = 6; };
      gapsOut  = lib.mkOption { type = lib.types.int; default = 12; };
      border   = lib.mkOption { type = lib.types.int; default = 2; };
      rounding = lib.mkOption { type = lib.types.int; default = 5; };
    };

    # Fancy wallpaper-driven theme (swww + pywal)
    theme = {
      enable = lib.mkEnableOption "Wallpaper-driven theme with swww + pywal";
      rotate = {
        enable   = lib.mkEnableOption "Periodic wallpaper rotation";
        minutes  = lib.mkOption { type = lib.types.ints.positive; default = 30; };
        directory = lib.mkOption { type = lib.types.str; default = "${config.home.homeDirectory}/wallpapers"; };
      };
      perWorkspace = lib.mkOption {
        type = lib.types.attrsOf lib.types.str; # "1" = "/path/to/img.png"
        default = {};
      };
      transition = {
        duration = lib.mkOption { type = lib.types.number; default = 0.6; };
        type     = lib.mkOption { type = lib.types.str; default = "any"; };
      };
    };
  };

  ## ───────────────────── Config ─────────────────────
  config = lib.mkIf cfg.enable {
    # Runtime tools common to desktop
    home.packages = with pkgs; [ wl-clipboard wofi ghostty firefox ];

    # XDG portal helpers (system has portals too; harmless to enable here)
    xdg.portal = { enable = true; extraPortals = [ pkgs.xdg-desktop-portal-wlr ]; };

    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        exec-once = [
          "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd DISPLAY XAUTHORITY WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP"
        ];

        # Look/feel
        general = {
          gaps_in = cfg.style.gapsIn;
          gaps_out = cfg.style.gapsOut;
          border_size = cfg.style.border;
          "col.active_border"   = "rgba(${builtins.substring 1 6 palette.mauve}ff)";
          "col.inactive_border" = "rgba(${builtins.substring 1 6 palette.base}ff)";
          layout = "dwindle";
        };

        decoration = {
          rounding = cfg.style.rounding;
          blur = { enabled = true; size = 8; passes = 3; new_optimizations = true; };
        };

        animations = {
          enabled = true;
          bezier = "easeOutQuint, 0.23, 1, 0.32, 1";
          animation = [
            "windows, 1, 7, easeOutQuint"
            "border, 1, 10, easeOutQuint"
            "fade, 1, 7, default"
            "workspaces, 1, 5, easeOutQuint"
          ];
        };

        # Blur Waybar (layer surface) and let alpha show
        layerrule = [
          "blur, waybar"
          "ignorealpha 0.2, waybar"
        ];

        # Keybinds
        bind = [
          (mkBind "bind" "Return" "exec, ${cfg.terminal}")
          (mkBind "bind" "Q"      "killactive")
          (mkBind "bind" "R"      "exec, ${cfg.appRunner}")
          "bind = ${cfg.modKey} SHIFT, R, exec, ${cfg.reloadCmd}"

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

          # Move window → workspace 1..9
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

    # Ghostty terminfo convenience
    home.sessionVariables.TERMINFO_DIRS = "${pkgs.ghostty}/share/terminfo";
  };
}

