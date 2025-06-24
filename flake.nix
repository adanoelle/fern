
{
  description = "Fern NixOS configuration";

  inputs = {
    nixpkgs.url        = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url   = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url    = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, home-manager, ... }:
    flake-parts.lib.mkFlake { inherit self inputs; } {
      systems = [ "x86_64-linux" ];

      # 1️⃣ System modules
      nixosModules.workspace = import ./nix/modules/workspace.nix;

      # 2️⃣ Per-system config
      perSystem = { pkgs, ... }: { };

      # 3️⃣ Hosts
      nixosConfigurations.fern = nixpkgs.lib.nixosSystem {
        system   = "x86_64-linux";
        modules  = [
          ./nix/hosts/fern   # your existing host module
          self.nixosModules.workspace
        ];
      };

      # 4️⃣ Home-Manager for your user
      homeConfigurations.ada = home-manager.lib.homeManagerConfiguration {
        pkgs   = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          ./home/ada/workspace.nix
        ];
        username = "ada";
        homeDirectory = "/home/ada";
      };
    };
}
