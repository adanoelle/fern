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
        overlays = import ./_lib/overlays.nix inputs;
      };
    };
}
