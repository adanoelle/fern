# modules/core.nix — Nix daemon, flakes, gc
{ den, inputs, ... }:
{
  den.aspects.core.nixos = {
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.permittedInsecurePackages = [
      "dotnet-sdk-6.0.428"
      "dotnet-runtime-6.0.36"
    ];
    nixpkgs.overlays = [
      inputs.rust-overlay.overlays.default
      inputs.zig-overlay.overlays.default
      inputs.claude-code.overlays.default
    ];
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
}
