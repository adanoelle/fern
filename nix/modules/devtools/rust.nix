{ config, lib, pkgs, rust-overlay, ... }:

let
  # Choose exact versions once; every rebuild is reproducible
  stable = pkgs.rust-bin.stable.latest.default;
  clippy = pkgs.rust-bin.stable.latest.clippy;
  fmt    = pkgs.rust-bin.stable.latest.rustfmt;

  # Harden compiler flags globally (Cargo inherits them)
  commonFlags = [
    "-C" "link-args=-Wl,-z,relro,-z,now"
    "-C" "opt-level=z"
    "-C" "target-cpu=native"   # local optimisations
  ];
in
{
  nixpkgs.overlays = [ rust-overlay.overlays.default ];

  environment.systemPackages =
    [ stable clippy fmt pkgs.rust-analyzer pkgs.cargo-audit pkgs.cargo-deny ];

  # Pass hardening flags through environment
  environment.variables.RUSTFLAGS = lib.strings.concatStringsSep " " commonFlags;

  # Source path for IDEs/LSPs
  environment.variables.RUST_SRC_PATH =
    "${stable}/lib/rustlib/src/rust/library";
}

