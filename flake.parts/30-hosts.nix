# flake.parts/50-hosts.nix
{ self, inputs, ... }:

let
  system = "x86_64-linux";
in
{
  # One output for each machine you want to build
  flake.nixosConfigurations.fern =
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;

      # Pass flake inputs to NixOS / HM modules
      specialArgs = {
        inherit inputs self;
        rust-overlay = inputs.rust-overlay;
        zig-overlay  = inputs.zig-overlay;
      };

      modules = [
        ./../hosts/fern/hardware.nix         # generated by nixos-generate-config
        ./../hosts/fern/configuration.nix    # your thin host file
      ];
    };
}

