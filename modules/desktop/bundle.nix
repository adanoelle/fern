# modules/desktop/bundle.nix — core desktop applications bundle
#
# What every graphical machine wants. Compositor sessions, streaming,
# gaming and music are separate opt-in layers that hosts forward to
# their users (see host-fern.nix).
#
# NOTE: den.aspects.niri is deliberately NOT in this bundle. Its
# homeManager side defines programs.niri.* options that only exist on
# hosts importing the niri-flake NixOS module; such hosts forward it
# to their users via provides.to-users (see host-fern.nix).
{ den, ... }:
{
  den.aspects.desktop-apps = {
    includes = [
      den.aspects.zen
      den.aspects.chromium
      den.aspects.screenshot
      den.aspects.imv
      den.aspects.pdf
      den.aspects.bitwarden
    ];
  };
}
