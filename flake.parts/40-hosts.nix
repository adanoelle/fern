# flake.parts/40-hosts.nix
{ withSystem, inputs, self, ... }:

{
  # --- Fern host
  flake.nixosConfigurations.fern =
    withSystem "x86_64-linux"
      ({ pkgs, system, ... }:
        inputs.nixpkgs.lib.nixosSystem {
          inherit pkgs system;
          modules = [
            ../hosts/fern/hardware.nix
            ../hosts/fern/configuration.nix
            inputs.home-manager.nixosModules.default
            inputs.fern.nixosModules.fern-shell
            inputs.fern.nixosModules.fern-fonts
          ];
          specialArgs = { inherit self inputs; };
        });
}
