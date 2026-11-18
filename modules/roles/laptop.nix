# modules/roles/laptop.nix — battery-powered machine role
#
# What a laptop needs on top of the workstation role: power profiles,
# compressed swap in RAM and firmware updates. Lid-close suspend is the
# logind default and is left alone. Model quirks come from the host's
# nixos-hardware import, not from here.
#
# The session side (backlight keys, suspend when idle on battery) is in
# den.aspects.brightness-backlight and den.aspects.idle-suspend, which
# the host forwards to its users.
_: {
  den.aspects.laptop.nixos =
    { lib, ... }:
    {
      # Balanced / power-saver / performance, switchable from the session
      # (powerprofilesctl) and by games through gamemode.
      services.power-profiles-daemon.enable = lib.mkDefault true;

      # No swap partition and no hibernation: zram absorbs memory
      # pressure without writing to the SSD.
      zramSwap.enable = lib.mkDefault true;

      # Firmware updates through LVFS (`fwupdmgr update`)
      services.fwupd.enable = lib.mkDefault true;
    };
}
