# nix/home/desktop/hyprland.nix
{ pkgs, lib, config, ... }:

let
  # --- Site‑wide variables
  cfg = {
    modKey     = "SUPER";
    terminal   = "ghostty";
    appRunner  = "wofi --show drun";
    reloadCmd  = "hyprctl reload";
  };

  # Handy helper to build "bind" entries
  bind = type: combo: action:
    "${type} = ${cfg.modKey}, ${combo}, ${action}";
in
{
  # --- Enable Hyprland + portal helpers                              
  options.desktop.hyprland.enable =
    lib.mkEnableOption "Hyprland Wayland compositor";

  config = lib.mkIf config.desktop.hyprland.enable {
    # 2.1 Packages we need at runtime
    home.packages = with pkgs; [
      wl-clipboard         # copy‑paste bridge
      wofi
      ghostty
      firefox
    ];

    # 2.2 XDG portal: let GTK / Electron apps open file pickers etc.
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
    };

    # --- Hyprland settings (strict schema, no duplicates allowed)
    wayland.windowManager.hyprland = {
      enable = true;

      settings = {
        # 3.1 Exec sequences
        exec-once = [
          "dbus-update-activation-environment --systemd DISPLAY XAUTHORITY WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE"
        ];

        # 3.2 Key‑bindings
        bind = [
          (bind "bind"  "Return" "exec, ${cfg.terminal}")
          (bind "bind"  "Q"      "killactive")
          (bind "bind"  "R"      "exec, ${cfg.appRunner}")
          # reload config (Shift modifier)
          "bind = ${cfg.modKey} SHIFT, R, exec, ${cfg.reloadCmd}"
          # Move focus
          (bind "bind" "H" "movefocus, l")
          (bind "bind" "J" "movefocus, d")
          (bind "bind" "K" "movefocus, u")
          (bind "bind" "L" "movefocus, r")
        ];

        # 3.3 Mouse bindings
        bindm = [
          "${cfg.modKey}, mouse:273, resizewindow"
        ];
      };

      # 3.4 Extra lines that are not yet covered by a structured option
      extraConfig = ''
        # custom extras can go here
      '';
    };

    # --- Session variables
    home.sessionVariables = {
      TERMINFO_DIRS = "${pkgs.ghostty}/share/terminfo";
    };
  };
}

