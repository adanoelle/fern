# modules/devtools/rust.nix — Rust toolchain (stable, via rust-overlay)
#
# No global RUSTFLAGS on purpose. An environment RUSTFLAGS replaces every
# project's own `.cargo/config.toml` rustflags, and the flags that used
# to live here did real damage: `opt-level=z` overrode release profiles,
# `target-cpu=native` produced binaries that only run on the build
# machine's CPU, and a GNU-ld link argument broke non-gcc targets such
# as wasm32. Hardening or tuning flags belong in a project's own config.
_:
let
  # `default` already bundles clippy and rustfmt (as *-preview
  # components); adding them separately collides in buildEnv. rust-src
  # is not part of `default` and is what rust-analyzer needs to resolve
  # the standard library (RUST_SRC_PATH below).
  toolchainFor =
    pkgs:
    pkgs.rust-bin.stable.latest.default.override {
      extensions = [ "rust-src" ];
    };
  srcPath = toolchain: "${toolchain}/lib/rustlib/src/rust/library";
in
{
  den.aspects.rust = {
    nixos =
      { pkgs, ... }:
      let
        stable = toolchainFor pkgs;
      in
      {
        environment = {
          systemPackages = [
            stable
            pkgs.rust-analyzer
            pkgs.cargo-audit
            pkgs.cargo-deny
          ];

          variables.RUST_SRC_PATH = srcPath stable;
        };
      };

    homeManager =
      { pkgs, ... }:
      let
        stable = toolchainFor pkgs;
      in
      {
        home.packages = [
          stable
          pkgs.rust-analyzer
          pkgs.cargo-audit
          pkgs.cargo-deny
        ];

        home.sessionVariables.RUST_SRC_PATH = srcPath stable;
      };
  };
}
