{ pkgs, ... }:

let
  qsCfg = "${pkgs.caelestiaShell}/share/caelestia-shell";
in
{
  home.packages = with pkgs; [
    quickshell
    caelestiaShell
    beatDetector
  ];

  xdg.configFile."quickshell/caelestia" = {
    source    = qsCfg;
    recursive = true;
  };

  systemd.user.services.beatDetector = {
    Unit.Description = "PipeWire beat detector for Caelestia Shell";
    Service.ExecStart = "${pkgs.beatDetector}/lib/caelestia/beat_detector";
    Service.Restart   = "on-failure";
    Install.WantedBy  = [ "graphical-session.target" ];
  };
}
