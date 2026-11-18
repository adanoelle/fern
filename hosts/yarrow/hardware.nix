# Hardware configuration for yarrow (Framework Laptop 13 Pro)
#
# PLACEHOLDER so the flake evaluates before the machine is installed.
# REPLACE THIS FILE during installation with the generated one:
#   sudo nixos-generate-config --root /mnt
#   cp /mnt/etc/nixos/hardware-configuration.nix hosts/yarrow/hardware.nix
# See book/src/operations/installing-yarrow.md. The labels below match
# the ones that page formats with, but the generated file is the truth.
{ lib, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
