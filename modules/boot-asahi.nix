# modules/boot-asahi.nix — Apple Silicon bootloader
{ den, ... }:
{
  den.aspects.boot-asahi.nixos = {
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = false;
  };
}
