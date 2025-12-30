{ pkgs, ... }:

{
  # Apple Silicon GPU support via Asahi
  hardware.asahi = {
    useExperimentalGPUDriver = true;
    experimentalGPUInstallMode = "replace";  # Use Asahi Mesa instead of upstream
  };

  # Hyprland for Wayland compositor
  programs.hyprland.enable = true;

  # Diagnostic utilities
  environment.systemPackages = with pkgs; [
    mesa-demos     # glxinfo, glxgears
    vulkan-tools   # vulkaninfo, vkcube
  ];
}
