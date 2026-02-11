# nix/home/desktop/chromium.nix
#
# The ungoogled version of Chromium
{ pkgs, ... }:

{
  programs.chromium = {
    enable = true;
    package = pkgs.ungoogled-chromium;

    commandLineArgs = [
      # Wayland
      "--ozone-platform=wayland"
      "--enable-features=UseOzonePlatform,WaylandWindowDecorations"

      # Rendering / video (trim Vaapi if it misbehaves on your GPU)
      "--use-gl=egl"
      "--enable-features=VaapiVideoDecodeLinuxGL,VaapiVideoEncoder,CanvasOopRasterization"

      # Privacy/behavior
      "--disable-sync"
      "--password-store=basic"
      "--disable-features=FedCm,InterestCohortApi,AutofillServerCommunication"
    ];
  };

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

}

