
{ pkgs, ... }:
{
  boot.loader.grub = {
    enable      = true;
    efiSupport  = true;
    devices     = [ "nodev" ];
  };
  boot.loader.efi.canTouchEfiVariables = true;
}
