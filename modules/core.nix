# modules/core.nix — Nix daemon, flakes, and fleet-wide defaults
#
# Everything here uses mkDefault where a host could reasonably want to
# override (a host in another timezone just sets time.timeZone).
{ den, inputs, ... }:
{
  den.aspects.core.nixos =
    { lib, ... }:
    {
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

      nix.settings.trusted-users = lib.mkDefault [
        "root"
        "ada"
      ];

      programs.nix-ld.enable = lib.mkDefault true;
      time.timeZone = lib.mkDefault "America/New_York";
    };
}
