{ config, lib, pkgs, ... }:

let
  cfg = config.virtualisation.vfio;
in
{
  options.virtualisation.vfio = {
    enable = lib.mkEnableOption "VFIO GPU passthrough for virtual machines";

    gpuPciIds = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "10de:2484" ];  # RTX 3070 video only (audio stays on host)
      description = "PCI IDs of GPU devices to pass through";
    };

    iommuType = lib.mkOption {
      type = lib.types.enum [ "intel" "amd" ];
      default = "amd";
      description = "CPU manufacturer for IOMMU configuration";
    };
  };

  config = lib.mkIf cfg.enable {
    # --- Enable IOMMU and VFIO kernel modules
    boot.kernelParams = [
      "${cfg.iommuType}_iommu=on"
      "iommu=pt"  # Passthrough mode for better performance
    ];

    # --- Bind GPU to VFIO driver early in boot process
    boot.extraModprobeConfig = ''
      options vfio-pci ids=${lib.concatStringsSep "," cfg.gpuPciIds}
    '';

    # --- Load VFIO modules in initrd before GPU drivers to ensure early binding
    boot.initrd.kernelModules = [
      "vfio_pci"
      "vfio"
      "vfio_iommu_type1"
    ];

    # --- Diagnostic tools
    environment.systemPackages = with pkgs; [
      pciutils  # lspci to verify VFIO binding
    ];
  };
}
