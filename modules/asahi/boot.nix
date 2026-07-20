# modules/asahi/boot.nix — Apple Silicon bootloader
_: {
  den.aspects.boot-asahi.nixos = {
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = false;
  };
}
