# modules/boot.nix — systemd-boot bootloader (UEFI x86 default)
#
# Kernel choice is deliberately not set here — hosts pick their own
# (e.g. zen on fern, LTS on a server). Apple Silicon hosts use the
# boot-asahi aspect instead (canTouchEfiVariables must be false there).
_: {
  den.aspects.boot.nixos = {
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
  };
}
