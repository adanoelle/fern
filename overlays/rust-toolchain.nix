# overlays/rust-toolchain.nix
self: super:
let
  rust-overlay = import (builtins.fetchTarball
    "https://github.com/oxalica/rust-overlay/archive/master.tar.gz");
  pkgs = import super.path { overlays = [ rust-overlay ]; };
in
{
  # expose channels as pkgs.rust.<channel>
  rust = pkgs.rust-bin.stable.latest.default;
  rust-nightly = pkgs.rust-bin.nightly.latest.default;

  # clippy, rustfmt, analysis tools for the same version as stable
  clippy   = pkgs.rust-bin.stable.latest.clippy;
  rustfmt  = pkgs.rust-bin.stable.latest.rustfmt;
  rust-analyzer = pkgs.rust-analyzer;
}
