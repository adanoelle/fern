{ inputs, ... }:

{
  imports = [
    ./desktop/hyprland.nix
    ./desktop/obs.nix
    ./desktop/quickshell.nix
  ];
}
