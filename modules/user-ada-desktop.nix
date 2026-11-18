# modules/user-ada-desktop.nix — user ada, desktop layer
#
# The core of a graphical session: the everyday desktop applications and
# the garden terminal stack. Only hosts with a graphical session forward
# this layer (via provides.to-users); a headless host never applies it.
#
# Heavier or host-specific layers are forwarded separately so each
# machine picks what fits: ada-hyprland (fallback compositor), music,
# obs, gaming-hm, gamedev — see the host aspects.
{ den, garden, ... }:
{
  den.aspects.ada-desktop = {
    includes = [
      den.aspects.desktop-apps
      garden.terminal
    ];
  };
}
