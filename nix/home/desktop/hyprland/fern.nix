{ lib, pkgs, config, inputs, ... }:

let
  cfg = config.desktop.hyprland;
  fernPkgs = inputs.fern.packages.${pkgs.system};
in
lib.mkIf (cfg.enable && cfg.fern.enable) {
  # Install fern-shell packages (including quickshell for CLI access)
  home.packages = [
    fernPkgs.fern-shell
    fernPkgs.fern-theme
    fernPkgs.fernctl
    fernPkgs.quickshell
  ] ++ lib.optionals cfg.fern.obs.enable [ fernPkgs.fern-obs ];

  # Symlink QML to quickshell config location
  xdg.configFile."quickshell/fern".source = "${fernPkgs.fern-shell}/share/fern";

  # Ensure state directory exists with proper permissions
  home.activation.fernStateDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ${config.xdg.stateHome}/fern
    chmod 700 ${config.xdg.stateHome}/fern
  '';

  # Main shell systemd service (fully hardened)
  systemd.user.services.fern-shell = {
    Unit = {
      Description = "Fern Shell (QuickShell Panel)";
      Documentation = "https://github.com/adanoelle/fern-shell";
      After = [ "graphical-session.target" ];
      PartOf = [ "hyprland-session.target" ];
      Requires = [ "hyprland-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${fernPkgs.quickshell}/bin/quickshell -c fern";

      # Restart policy with limits (prevent restart storms)
      Restart = "on-failure";
      RestartSec = 2;
      StartLimitBurst = 5;
      StartLimitIntervalSec = 60;

      # Environment
      Environment = [
        "QT_QPA_PLATFORM=wayland"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION=1"
      ];

      # Logging
      StandardOutput = "journal";
      StandardError = "journal";
      SyslogIdentifier = "fern-shell";

      # Security sandboxing
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = "read-only";
      ReadWritePaths = [ "%h/.local/state/fern" "%h/.config/fern" ];
      NoNewPrivileges = true;
      CapabilityBoundingSet = "";
      RestrictNamespaces = true;
      LockPersonality = true;

      # Resource limits
      MemoryMax = "200M";
      TasksMax = 50;
    };
    Install.WantedBy = [ "hyprland-session.target" ];
  };

  # Optional: fern-obs daemon (with proper dependencies)
  systemd.user.services.fern-obs = lib.mkIf cfg.fern.obs.enable {
    Unit = {
      Description = "Fern OBS Bridge";
      After = [ "graphical-session.target" "fern-shell.service" ];
      BindsTo = [ "fern-shell.service" ];
    };
    Service = {
      ExecStart = "${fernPkgs.fern-obs}/bin/fern-obs daemon";
      Restart = "on-failure";
      RestartSec = 5;
      StartLimitBurst = 3;
      StartLimitIntervalSec = 30;

      Environment = [ "RUST_LOG=fern_obs=info" ];
      StandardOutput = "journal";
      StandardError = "journal";
      SyslogIdentifier = "fern-obs";

      # Sandboxing
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = "read-only";
      ReadWritePaths = [ "%h/.local/state/fern" ];
      NoNewPrivileges = true;

      MemoryMax = "50M";
      TasksMax = 10;
    };
    Install.WantedBy = [ "hyprland-session.target" ];
  };

  # Optional: fern-theme watcher (stops with fern-shell)
  systemd.user.services.fern-theme-watcher = lib.mkIf cfg.fern.themeWatcher.enable {
    Unit = {
      Description = "Fern Theme Watcher";
      After = [ "graphical-session.target" "fern-shell.service" ];
      PartOf = [ "fern-shell.service" ];
    };
    Service = {
      ExecStart = "${fernPkgs.fern-theme}/bin/fern-theme watch";
      Restart = "on-failure";
      RestartSec = 2;
      StartLimitBurst = 5;
      StartLimitIntervalSec = 60;

      StandardOutput = "journal";
      StandardError = "journal";
      SyslogIdentifier = "fern-theme";

      # Sandboxing
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = "read-only";
      ReadWritePaths = [ "%h/.local/state/fern" ];
      NoNewPrivileges = true;

      MemoryMax = "50M";
      TasksMax = 10;
    };
    Install.WantedBy = [ "fern-shell.service" ];
  };

  # Hyprland layer rules for fern (quickshell)
  wayland.windowManager.hyprland.settings.layerrule = [
    "blur, quickshell"
    "ignorealpha 0.2, quickshell"
  ];
}
