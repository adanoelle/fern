# Hardware configuration for moss (Apple Silicon M1 Pro)
#
# REPLACE THIS FILE after booting the NixOS installer:
#   1. Partition and format your disk
#   2. Mount at /mnt
#   3. Run: sudo nixos-generate-config --root /mnt
#   4. Copy /mnt/etc/nixos/hardware-configuration.nix to this file
#
{ lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  nixpkgs.hostPlatform = "aarch64-linux";
}
