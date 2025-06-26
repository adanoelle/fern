{
  inputs = {
    nixpkgs.url        = "github:NixOS/nixpkgs/nixos-23.11";
    flake-parts.url    = "github:hercules-ci/flake-parts";
    flake-utils.url    = "github:numtide/flake-utils";
    rust-overlay.url   = "github:oxalica/rust-overlay";
    home-manager.url   = "github:nix-community/home-manager/release-23.11";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./flake.parts/00-core.nix
        ./flake.parts/10-nixos-mods.nix
        ./flake.parts/20-home-mods.nix
      ];
    };
}

