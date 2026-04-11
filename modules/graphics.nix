# modules/graphics.nix — Nvidia GPU drivers
{ den, ... }:
{
  den.aspects.graphics.nixos =
    { config, pkgs, ... }:
    {
      services.xserver.videoDrivers = [ "nvidia" ];

      hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = false;
        open = false;
        package = config.boot.kernelPackages.nvidiaPackages.production;
      };

      environment.variables = {
        __GL_GSYNC_ALLOWED = "1";
        __GL_VRR_ALLOWED = "1";
        WLR_NO_HARDWARE_CURSORS = "1";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      };

      environment.systemPackages = with pkgs; [
        mesa-demos
        vulkan-tools
      ];

      programs.hyprland.enable = true;
    };
}
