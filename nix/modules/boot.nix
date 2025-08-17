
{ pkgs, ... }:
{
  boot.kernelPackages = pkgs.linuxPackages_zen;

  boot.loader.grub = {
    enable      = true;
    efiSupport  = true;
    devices     = [ "nodev" ];
  };
  boot.loader.efi.canTouchEfiVariables = true;
}
