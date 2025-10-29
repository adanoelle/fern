{ config, lib, pkgs, ... }:

let
  cfg = config.programs.looking-glass;
in
{
  options.programs.looking-glass = {
    enable = lib.mkEnableOption "Looking Glass client for seamless Windows VM integration";

    sharedMemorySize = lib.mkOption {
      type = lib.types.int;
      default = 32;
      description = ''
        Shared memory size in MB for frame capture.
        32MB supports up to 1440p SDR displays.
        Increase for 4K or HDR: 64MB for 4K SDR, 128MB for 4K HDR.
      '';
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "ada";
      description = "User who will run Looking Glass client";
    };
  };

  config = lib.mkIf cfg.enable {
    # --- Looking Glass client application
    environment.systemPackages = with pkgs; [
      looking-glass-client
    ];

    # --- Enable kvmfr kernel module
    boot.extraModulePackages = with config.boot.kernelPackages; [
      kvmfr
    ];

    boot.extraModprobeConfig = ''
      options kvmfr static_size_mb=${toString cfg.sharedMemorySize}
    '';

    # --- Load kvmfr module after boot via systemd to avoid early boot hang
    systemd.services.load-kvmfr = {
      description = "Load kvmfr kernel module for Looking Glass";
      wantedBy = [ "multi-user.target" ];
      after = [ "systemd-modules-load.service" ];
      script = ''
        # Check if module is available before trying to load it
        if ${pkgs.kmod}/bin/modinfo kvmfr &>/dev/null; then
          ${pkgs.kmod}/bin/modprobe kvmfr || {
            echo "Warning: kvmfr module found but failed to load. May need reboot."
            exit 0
          }
        else
          echo "kvmfr module not available yet. Will be available after reboot."
          exit 0
        fi
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
    };

    # --- Set up shared memory device with proper permissions
    systemd.tmpfiles.rules = [
      "f /dev/shm/looking-glass 0660 ${cfg.user} qemu-libvirtd -"
    ];

    # --- Ensure user can access the shared memory
    users.users.${cfg.user}.extraGroups = [ "libvirtd" ];
  };
}
