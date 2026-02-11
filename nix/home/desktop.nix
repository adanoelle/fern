{ inputs, ... }:

{
  imports = [
    ./desktop/chromium.nix
    ./desktop/gaming.nix
    ./desktop/hyprland.nix
    ./desktop/nyxt.nix
    ./desktop/obs.nix
    ./desktop/screenshot.nix
  ];
}
