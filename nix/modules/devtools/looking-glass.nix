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

    boot.kernelModules = [ "kvmfr" ];

    boot.extraModprobeConfig = ''
      options kvmfr static_size_mb=${toString cfg.sharedMemorySize}
    '';

    # --- Set up shared memory device with proper permissions
    systemd.tmpfiles.rules = [
      "f /dev/shm/looking-glass 0660 ${cfg.user} qemu-libvirtd -"
    ];

    # --- Ensure user can access the shared memory
    users.users.${cfg.user}.extraGroups = [ "libvirtd" ];
  };
}
