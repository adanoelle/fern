# modules/desktop/obs.nix — OBS Studio with capture plugins
_: {
  den.aspects.obs.homeManager =
    { pkgs, ... }:
    {
      programs.obs-studio = {
        enable = true;
        # The stock nixpkgs build, which the binary cache has. Hardware
        # encoding on AMD and Intel is VA-API (the obs-vaapi plugin
        # below). `cudaSupport = true` was set here; it is NVIDIA-only,
        # and its effect on these machines was to change the derivation
        # so OBS was compiled locally instead of fetched. A host with an
        # NVIDIA card should override the package in its own aspect.
        plugins = with pkgs.obs-studio-plugins; [
          wlrobs
          obs-backgroundremoval
          obs-pipewire-audio-capture
          obs-vaapi
          obs-gstreamer
          obs-vkcapture
        ];
      };
    };
}
