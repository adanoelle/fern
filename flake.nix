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

    # The collection app (channels of images, links and notes). Not to
    # be confused with garden-shell above, which is the palette.
    garden = {
      url = "github:adanoelle/garden";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.rust-overlay.follows = "rust-overlay";
    };

    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
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

    # Per-model hardware quirks (the Framework laptop, yarrow). Only its
    # NixOS modules are used; `follows` keeps its test-only nixpkgs out
    # of the lock.
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
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

    # Fresh nixpkgs for individual packages the shared pin carries too old.
    # Deliberately does NOT follow `nixpkgs`, so those packages substitute
    # from cache.nixos.org instead of forcing a full local rebuild. Used by:
    #   - uv (modules/devtools/python.nix): projects such as wildfire need
    #     uv >= 0.13.1, which knows the Python 3.15 release; the shared pin
    #     carries 0.11
    #   - postgresql (modules/cli/postgres.nix): 18.6 security fixes; the
    #     shared pin carries 18.4
    # Drop this input (and the overrides in those aspects) after the next
    # `just update`.
    nixpkgs-uv.url = "github:NixOS/nixpkgs/nixos-unstable";

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
