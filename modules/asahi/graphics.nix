# modules/asahi/graphics.nix — Apple Silicon GPU (Asahi)
_: {
  den.aspects.graphics-asahi.nixos =
    { pkgs, ... }:
    {
      # GPU driver options removed — asahi support is now in mainline mesa
      environment.systemPackages = with pkgs; [
        mesa-demos
        vulkan-tools
      ];
    };
}
