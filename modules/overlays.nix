# modules/overlays.nix — nixpkgs configuration and overlays
{ inputs, ... }:
{
  # Support both architectures
  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];

  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          inputs.rust-overlay.overlays.default
          inputs.zig-overlay.overlays.default
          inputs.claude-code.overlays.default
        ];
      };
    };
}
