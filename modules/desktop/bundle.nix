# modules/desktop/bundle.nix — desktop applications bundle
#
# NOTE: den.aspects.niri is deliberately NOT in this bundle. Its
# homeManager side defines programs.niri.* options that only exist on
# hosts importing the niri-flake NixOS module; such hosts forward it
# to their users via provides.to-users (see host-fern.nix).
{ den, ... }:
{
  den.aspects.desktop-apps = {
    includes = [
      den.aspects.hyprland
      den.aspects.chromium
      den.aspects.obs
      den.aspects.screenshot
      den.aspects.gaming-hm
      den.aspects.daw
    ];
  };
}
