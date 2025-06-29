{ pkgs, config, ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable     = true;              # Wayland/GBM
    powerManagement.enable = false;             # keep discrete GPU on
    open                   = false;             # use proprietary blobs
    package = config.boot.kernelPackages.nvidiaPackages.production;
  };

  # --- Environment tweaks 
  environment.variables = {
    __GL_GSYNC_ALLOWED       = "1";
    __GL_VRR_ALLOWED         = "1";
    WLR_NO_HARDWARE_CURSORS  = "1";   # cursor glitch workaround
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  # --- Diagnostic utilities
  environment.systemPackages = with pkgs; [
    mesa-demos     # glxinfo, glxgears
    vulkan-tools   # vulkaninfo, vkcube
  ];

  # --- Hyprland + greetd
  programs.hyprland.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = { command = "Hyprland"; user = "ada"; };

      # Optional textual fallback
      sessions = [
        { command = "Hyprland"; user = "ada"; }
        { command = "tty1";     user = "root"; }
      ];
    };
  };
}

