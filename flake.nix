{
  inputs = {
    nixpkgs.url       = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url   = "github:hercules-ci/flake-parts";
    flake-utils.url   = "github:numtide/flake-utils";

    home-manager = {
      url   = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    caelestia-shell = {
      url   = "github:caelestia-dots/shell";
      flake = false;
    };

    rust-overlay = {
      url   = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./flake.parts/00-core.nix
        ./flake.parts/10-nixos-mods.nix
        ./flake.parts/20-home-mods.nix
        ./flake.parts/30-hosts.nix
      ];
    };
}

