# modules/roles/workstation.nix — graphical workstation role
#
# The aspect set every graphical x86 machine should share. Hosts add
# their bootloader aspect (boot / boot-asahi) and hardware quirks
# themselves. Niri is deliberately NOT part of the role: the niri-flake
# NixOS module must be imported exactly once at the host level (see
# host-fern.nix), so hosts opt into den.aspects.niri alongside that
# import.
{ den, ... }:
{
  den.aspects.workstation.includes = [
    den.aspects.core
    den.aspects.nh
    den.aspects.users
    den.aspects.secrets-guard
    den.aspects.greetd
    den.aspects.fonts
    den.aspects.audio
    den.aspects.docker
  ];
}
