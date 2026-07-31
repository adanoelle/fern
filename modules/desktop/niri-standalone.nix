# modules/desktop/niri-standalone.nix — niri for non-NixOS hosts
#
# On NixOS hosts, programs.niri.* home options come from the niri-flake
# NixOS module's home-manager.sharedModules bridge (imported once at
# host level, see host-fern.nix). A standalone home has no such bridge,
# so this aspect imports niri-flake's home module directly — once, at
# home level, mirroring the same "import once" rule — and reuses the
# shared den.aspects.niri homeManager settings (keybinds, workspaces,
# swayidle, garden IPC) verbatim. The nixos side of den.aspects.niri is
# ignored in standalone-home evaluation.
#
# The niri package itself is chosen by the foreign-distro aspect
# (modules/foreign/ubuntu-desktop.nix wraps it with nixGL).
{ den, inputs, ... }:
{
  den.aspects.niri-standalone = {
    includes = [ den.aspects.niri ];

    homeManager = {
      imports = [ inputs.niri.homeModules.niri ];

      programs.niri.enable = true;
    };
  };
}
