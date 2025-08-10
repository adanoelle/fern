{ inputs, ... }:

{
  imports = [
    ./desktop/chromium.nix
    ./desktop/hyprland.nix
    ./desktop/obs.nix
    ./desktop/screenshot.nix
  ];
}
