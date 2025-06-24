# modules/devtools/rust.nix
{ pkgs, lib, ... }:

{
  nixpkgs.overlays = [ (import ../overlays/rust-toolchain.nix) ];

  environment.systemPackages = with pkgs; [
    rust
    clippy
    rustfmt
    rust-analyzer
    cargo-edit
    cargo-watch
  ];

  # Optional: make rust-analyzer available to VS Code/Helix via LSP
  programs.neovim.extraPackages = [ pkgs.rust-analyzer ];
}

