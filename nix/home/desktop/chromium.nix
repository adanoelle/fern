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

  # Optional: set as default browser (update .desktop name after first build)
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html"              = [ "ungoogled-chromium.desktop" ];
      "x-scheme-handler/http"  = [ "ungoogled-chromium.desktop" ];
      "x-scheme-handler/https" = [ "ungoogled-chromium.desktop" ];
    };
  };
}

