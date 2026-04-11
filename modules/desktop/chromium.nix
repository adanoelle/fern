{ den, ... }:
{
  den.aspects.chromium.homeManager =
    { pkgs, ... }:
    {
      programs.chromium = {
        enable = true;
        package = pkgs.ungoogled-chromium;

        commandLineArgs = [
          "--ozone-platform=wayland"
          "--enable-features=UseOzonePlatform,WaylandWindowDecorations"
          "--use-gl=egl"
          "--enable-features=VaapiVideoDecodeLinuxGL,VaapiVideoEncoder,CanvasOopRasterization"
          "--disable-sync"
          "--password-store=basic"
          "--disable-features=FedCm,InterestCohortApi,AutofillServerCommunication"
        ];
      };

      home.sessionVariables = {
        NIXOS_OZONE_WL = "1";
      };
    };
}
