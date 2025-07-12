# nix/home/desktop/quickshell.nix
{ pkgs, ... }:

let
  # Upstream asset directory shipped by the overlay
  shellAssets = "${pkgs.caelestiaShell}/share/caelestia-shell";

  # Full path to beat‑detector binary
  beatBin = "${pkgs.beatDetector}/lib/caelestia/beat_detector";
in
{
  home.packages = with pkgs; [
    quickshell
    caelestiaShell
    beatDetector
  ];

  # --- Ship Caelestia assets verbatim (QML, icons, CSS, …)               
  xdg.configFile."quickshell/caelestia" = {
    source    = shellAssets;
    recursive = true;
  };

  # --- Hyprland overlay config (picked by greetd session)                
  xdg.configFile."hypr/caelestia.conf".text = ''
    # Start from your normal config
    source = ~/.config/hypr/hyprland.conf

    # Run QuickShell once on compositor start
    exec-once = quickshell --config-dir ${shellAssets}

    # Optional visual tweaks specific to Caelestia theme
    # e.g.  animations { enabled = no }
    #       windowrule = opacity 0.9 fullscreen 0.95
  '';

  # ---  Beat detector user service                                       
  systemd.user.services.beatDetector = {
    Unit.Description = "PipeWire beat detector for Caelestia Shell";
    Service.ExecStart = beatBin;
    Service.Restart   = "on-failure";
    Install.WantedBy  = [ "graphical-session.target" ];
  };
}

