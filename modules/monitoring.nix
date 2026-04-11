# modules/monitoring.nix — hardware sensor monitoring
{ den, ... }:
{
  den.aspects.monitoring.nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      hasNvidia = builtins.elem "nvidia" config.services.xserver.videoDrivers;

      sensorScript = pkgs.writeShellScript "sensor-log" (
        ''
          if [ -f /var/log/sensors.log ] && [ "$(stat -c%s /var/log/sensors.log 2>/dev/null || echo 0)" -gt 10485760 ]; then
            mv /var/log/sensors.log /var/log/sensors.log.old
          fi
          echo "=== $(date -Iseconds) ===" >> /var/log/sensors.log
          ${pkgs.lm_sensors}/bin/sensors >> /var/log/sensors.log 2>&1
        ''
        + lib.optionalString hasNvidia ''
          ${config.hardware.nvidia.package.bin}/bin/nvidia-smi --query-gpu=temperature.gpu,power.draw,fan.speed,utilization.gpu --format=csv,noheader >> /var/log/sensors.log 2>&1
        ''
        + ''
          sync
        ''
      );
    in
    {
      environment.systemPackages = with pkgs; [
        lm_sensors
        s-tui
        stress-ng
      ];

      boot.kernelModules = [ "nct6775" ];

      systemd.services.sensor-logger = {
        description = "Log hardware sensors";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = sensorScript;
        };
      };

      systemd.timers.sensor-logger = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "30s";
          OnUnitActiveSec = "30s";
        };
      };
    };
}
