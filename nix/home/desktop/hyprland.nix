{ lib, ... }: {
  imports = [
    ./hyprland/core.nix
    ./hyprland/bar.nix
    ./hyprland/fern.nix
    ./hyprland/idlelock.nix
    ./hyprland/wallpaper.nix
  ];
}
