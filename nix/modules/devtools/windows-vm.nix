{ config, lib, pkgs, ... }:

let
  cfg = config.virtualisation.windows-vm;
in
{
  options.virtualisation.windows-vm = {
    enable = lib.mkEnableOption "Windows VM with KVM/QEMU and optimal performance settings";

    user = lib.mkOption {
      type = lib.types.str;
      default = "ada";
      description = "User who will manage virtual machines";
    };

    enableVirtManager = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable virt-manager GUI for VM management";
    };
  };

  config = lib.mkIf cfg.enable {
    # --- KVM/QEMU virtualization with libvirt
    virtualisation.libvirtd = {
      enable = true;

      # Use QEMU with KVM acceleration
      qemu = {
        package = pkgs.qemu_kvm;

        # Enable UEFI firmware for Windows VMs
        ovmf = {
          enable = true;
          packages = [ pkgs.OVMFFull.fd ];
        };

        # Run QEMU as root for hardware access
        runAsRoot = true;

        # Enable TPM emulation for Windows 11
        swtpm.enable = true;

        # Verbose logging for debugging
        verbatimConfig = ''
          # Improved performance and security
          user = "root"
          group = "root"

          # Networking
          security_driver = "none"
        '';
      };

      # Allow user-session VMs
      allowedBridges = [
        "virbr0"
      ];
    };

    # --- User permissions
    users.users.${cfg.user}.extraGroups = [ "libvirtd" "kvm" ];

    # --- Management tools
    environment.systemPackages = with pkgs; [
      # GUI management
      (lib.mkIf cfg.enableVirtManager virt-manager)

      # CLI tools
      libvirt           # virsh, virt-install
      qemu_kvm          # QEMU binaries

      # Utilities for Windows integration
      virt-viewer       # View VM display
      spice-gtk         # SPICE client for clipboard/USB sharing
      win-virtio        # Windows VirtIO drivers ISO
      win-spice         # Windows SPICE guest tools
    ];

    # --- Networking: default NAT network
    virtualisation.libvirtd.onBoot = "start";
    virtualisation.libvirtd.onShutdown = "shutdown";

    # --- Enable nested virtualization
    boot.kernelModules = [ "kvm-amd" ];  # Use kvm-intel for Intel CPUs
    boot.extraModprobeConfig = ''
      options kvm_amd nested=1
    '';
  };
}
