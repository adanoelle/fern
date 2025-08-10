{ lib, ... }: {
  imports = [
    ./hyprland/core.nix
    ./hyprland/bar.nix
    ./hyprland/idlelock.nix
    ./hyprland/wallpaper.nix
    ./hyprland/theme.nix
  ];
}
