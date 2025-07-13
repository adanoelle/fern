# flake.parts/10-core.nix
{ self, inputs, ... }:

let
  # Capture all overlays once; 'self.overlays.caelestia' is top‑level.
  sharedOverlays = [
    inputs.rust-overlay.overlays.default
    inputs.zig-overlay.overlays.default
  ];
in
{
  systems = [ "x86_64-linux" ];

  perSystem = { system, ... }: {
    _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = sharedOverlays;
    };
  };
}
