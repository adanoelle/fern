# modules/desktop/bundle.nix — desktop applications bundle
{ den, ... }:
{
  den.aspects.desktop-apps = {
    includes = [
      den.aspects.niri
      den.aspects.hyprland
      den.aspects.chromium
      den.aspects.obs
      den.aspects.screenshot
      den.aspects.gaming-hm
    ];
  };
}
