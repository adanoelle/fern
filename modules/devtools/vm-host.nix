# modules/devtools/vm-host.nix — desktop VMs for testing software
#
# quickemu runs QEMU as the user with KVM, UEFI and a software TPM, so
# Windows 11 and Linux guests need no libvirt daemon. Projects keep their
# own VM recipes (pigment's justfile drives these for installer testing);
# this aspect only makes the tools available.
#
# /dev/kvm access: systemd's default udev rule makes it 0666 on NixOS, and
# Ubuntu grants it to the logged-in user through a uaccess ACL, so no group
# membership is needed on either.
#
# Shared folders: quickemu shares XDG_PUBLICSHARE_DIR with a guest unless
# the VM's .conf sets public_dir. modules/workspace.nix points that at the
# home directory, so always set public_dir (or public_dir="none").
_: {
  den.aspects.vm-host = {
    homeManager =
      { pkgs, config, ... }:
      {
        # QEMU's SDL window needs the host GL driver on non-NixOS; on NixOS
        # the wrapper is a no-op.
        home.packages = [ (config.lib.nixGL.wrap pkgs.quickemu) ];
      };
  };
}
