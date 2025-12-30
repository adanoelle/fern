# flake.parts/40-hosts.nix
{ withSystem, inputs, self, ... }:

{
  # --- Fern host (x86_64 + Nvidia)
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

  # --- Moss host (Apple Silicon M1 Pro)
  flake.nixosConfigurations.moss =
    withSystem "aarch64-linux"
      ({ pkgs, system, ... }:
        inputs.nixpkgs.lib.nixosSystem {
          inherit pkgs system;
          modules = [
            ../hosts/moss/configuration.nix
            inputs.home-manager.nixosModules.default
            inputs.fern.nixosModules.fern-shell
            inputs.fern.nixosModules.fern-fonts
          ];
          specialArgs = { inherit self inputs; };
        });
}
