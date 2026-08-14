_:
let
  commonFlags = [
    "-C"
    "link-args=-Wl,-z,relro,-z,now"
    "-C"
    "opt-level=z"
    "-C"
    "target-cpu=native"
  ];
in
{
  den.aspects.rust = {
    nixos =
      { lib, pkgs, ... }:
      let
        # `default` already bundles clippy and rustfmt (as *-preview
        # components); adding them separately collides in buildEnv.
        stable = pkgs.rust-bin.stable.latest.default;
      in
      {
        environment = {
          systemPackages = [
            stable
            pkgs.rust-analyzer
            pkgs.cargo-audit
            pkgs.cargo-deny
          ];

          variables = {
            RUSTFLAGS = lib.strings.concatStringsSep " " commonFlags;
            RUST_SRC_PATH = "${stable}/lib/rustlib/src/rust/library";
          };
        };
      };

    homeManager =
      { lib, pkgs, ... }:
      let
        stable = pkgs.rust-bin.stable.latest.default;
      in
      {
        home.packages = [
          stable
          pkgs.rust-analyzer
          pkgs.cargo-audit
          pkgs.cargo-deny
        ];

        home.sessionVariables = {
          RUSTFLAGS = lib.strings.concatStringsSep " " commonFlags;
          RUST_SRC_PATH = "${stable}/lib/rustlib/src/rust/library";
        };
      };
  };
}
