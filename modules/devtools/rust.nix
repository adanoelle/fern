_: {
  den.aspects.rust.nixos =
    { lib, pkgs, ... }:
    let
      stable = pkgs.rust-bin.stable.latest.default;
      clippy = pkgs.rust-bin.stable.latest.clippy;
      fmt = pkgs.rust-bin.stable.latest.rustfmt;

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
      environment = {
        systemPackages = [
          stable
          clippy
          fmt
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
}
