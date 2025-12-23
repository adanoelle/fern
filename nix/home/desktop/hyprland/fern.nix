{ lib, pkgs, config, inputs, ... }:

let
  cfg = config.desktop.hyprland;
  fernPkgs = inputs.fern.packages.${pkgs.system};
in
lib.mkIf (cfg.enable && cfg.fern.enable) {
  # Install fern-shell packages
  home.packages = [
    fernPkgs.fern-shell
    fernPkgs.fern-theme
    fernPkgs.fernctl
  ] ++ lib.optionals cfg.fern.obs.enable [ fernPkgs.fern-obs ];

  # Symlink QML to quickshell config location
  xdg.configFile."quickshell/fern".source = "${fernPkgs.fern-shell}/share/fern";

  # Ensure state directory exists
  home.activation.fernStateDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ~/.local/state/fern
  '';

  # Main shell systemd service
  systemd.user.services.fern-shell = {
    Unit = {
      Description = "Fern Shell (QuickShell)";
      After = [ "graphical-session.target" ];
      PartOf = [ "hyprland-session.target" ];
    };
    Service = {
      ExecStart = "${fernPkgs.quickshell}/bin/quickshell -c fern";
      Restart = "on-failure";
      RestartSec = 1;
    };
    Install.WantedBy = [ "hyprland-session.target" ];
  };

  # Optional: fern-obs daemon
  systemd.user.services.fern-obs = lib.mkIf cfg.fern.obs.enable {
    Unit = {
      Description = "Fern OBS Bridge";
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${fernPkgs.fern-obs}/bin/fern-obs daemon";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "default.target" ];
  };

  # Optional: fern-theme watcher
  systemd.user.services.fern-theme-watcher = lib.mkIf cfg.fern.themeWatcher.enable {
    Unit = {
      Description = "Fern Theme Watcher";
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${fernPkgs.fern-theme}/bin/fern-theme watch";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "default.target" ];
  };

  # Hyprland layer rules for fern (quickshell)
  wayland.windowManager.hyprland.settings.layerrule = [
    "blur, quickshell"
    "ignorealpha 0.2, quickshell"
  ];
}
