# modules/asahi/graphics.nix — Apple Silicon GPU (Asahi)
{ den, ... }:
{
  den.aspects.graphics-asahi.nixos = { pkgs, ... }: {
    # GPU driver options removed — asahi support is now in mainline mesa
    programs.hyprland.enable = true;

    environment.systemPackages = with pkgs; [
      mesa-demos
      vulkan-tools
    ];
  };
}
