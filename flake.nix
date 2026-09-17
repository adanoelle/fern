{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    den.url = "github:vic/den";

    import-tree.url = "github:vic/import-tree";

    garden-shell = {
      url = "github:adanoelle/garden-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.den.follows = "den";
    };

    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-desktop = {
      url = "github:k3d3/claude-desktop-linux-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
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

    musnix = {
      url = "github:musnix/musnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-apple-silicon = {
      url = "github:tpwrules/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-code = {
      url = "github:ryoppippi/claude-code-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Fresh nixpkgs for Thunderbird only (modules/desktop/thunderbird.nix):
    # Microsoft Graph support needs Thunderbird >= 154, newer than the
    # shared pin carries. Deliberately does NOT follow `nixpkgs`, so it
    # substitutes from cache.nixos.org instead of dragging every overlay
    # package into a local rebuild. Drop this input (and the package
    # override in the aspect) after the next `just update`.
    nixpkgs-thunderbird.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Zen browser (Firefox-based; workspaces + nested tab folders). Not in
    # nixpkgs; the community flake re-hosts upstream release artifacts and
    # ships a programs.zen-browser home-manager module.
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    herdr = {
      url = "github:herdrdev/herdr";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # GL/Vulkan wrappers for running Nix-built graphical apps on foreign
    # distros (the ORNL Ubuntu laptop). Unused on NixOS hosts.
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs =
    inputs@{ flake-parts, import-tree, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (import-tree ./modules);
}
