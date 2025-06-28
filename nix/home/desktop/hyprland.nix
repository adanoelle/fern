{ pkgs, inputs, lib, config, ... }:

let 
  hprCfg = ''
    # ---
    $mod = SUPER

    # Launch terminal
    bind = $mod, Return, exec, ghostty

    # Reload config
    bind = $mod, SHIFT, exec, hyprctl reload

    # Close focused window
    bind = $mod, Q, killactive

    # Move focus
    bind = $mod, J, movefocus, l
    bind = $mod, K, movefocus, d
    bind = $mod, K, movefocus, u
    bind = $mod, L, movefocus, r

    # Resize window
    bindm = $mod, mouse:273, resizeWindow

    # Launch app launcher
    bind = $mod, R, exec, wofi --show drun
  '';

in
{
  options.desktop.hyprland.enable = lib.mkEnableOption "Hyprland desktop";

  config = lib.mkIf config.desktop.hyprland.enable {
    home.packages = with pkgs; [
      firefox
      wofi
      wl-clipboard
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      extraConfig = hprCfg;
    };

    xdg.enable = true;

    home.sessionVariables.TERMINFO_DIRS = lib.mkForce "{ghostty/share/terminfo}";
  };
}
