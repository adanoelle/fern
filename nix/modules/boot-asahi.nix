{ pkgs, ... }:

{
  # Apple Silicon uses systemd-boot (not GRUB)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;  # Required for Apple Silicon
}
