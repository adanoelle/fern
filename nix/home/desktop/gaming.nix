{ pkgs, ... }:

{
  home.packages = with pkgs; [
    mangohud # Vulkan/OpenGL HUD overlay (FPS, temps, frametimes)
    protonup-qt # Manage GE-Proton versions
    lutris # Game launcher for non-Steam games
    protontricks # Winetricks for Proton prefixes
  ];
}
