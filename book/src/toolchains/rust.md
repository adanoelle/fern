# Rust

> The latest stable Rust toolchain from `rust-overlay`, with `rust-src`,
> rust-analyzer, cargo-audit and cargo-deny, and deliberately no global
> `RUSTFLAGS`.

**Goes on:** fern, yarrow, work laptop (through the `devtools` bundle in
the `ada-dev` user layer).

## What the aspect installs

`den.aspects.rust` (`modules/devtools/rust.nix`) has a NixOS side and a
home-manager side that install the same set, so the toolchain is present
on the NixOS hosts and on the standalone-home work laptop alike.

| Package                          | Purpose                                 |
| -------------------------------- | --------------------------------------- |
| `rust-bin.stable.latest.default` | rustc, cargo, clippy, rustfmt; overridden to add the `rust-src` extension |
| `rust-analyzer`                  | Language server                         |
| `cargo-audit`                    | Dependency vulnerability scanner        |
| `cargo-deny`                     | Dependency license and advisory checker |

clippy and rustfmt are part of the `default` profile; they are not listed
separately because the duplicate would collide in the profile.

## Where `rust-bin` comes from

`pkgs.rust-bin` is provided by the `rust-overlay` flake input. The
overlay is applied in two places, because there are two package sets:

| File                   | Package set                                         |
| ---------------------- | --------------------------------------------------- |
| `modules/core.nix`     | `nixpkgs.overlays` for the NixOS hosts              |
| `modules/overlays.nix` | the flake's `perSystem` pkgs, which the work laptop's standalone home reuses (`modules/hosts.nix`) |

See [Flake and bootstrap](../architecture/flake-and-bootstrap.md).

## Environment

`RUST_SRC_PATH` is set to `<toolchain>/lib/rustlib/src/rust/library` on
both sides (`environment.variables` and `home.sessionVariables`). It
points rust-analyzer at the standard library sources that the `rust-src`
extension adds.

There is no global `RUSTFLAGS`. An environment `RUSTFLAGS` replaces every
project's own `.cargo/config.toml` rustflags, so size, CPU-specific or
linker flags set here would override release profiles, tie binaries to
the build machine, or break non-gcc targets such as `wasm32`. Hardening
and tuning flags belong in each project's cargo config.

## Helix

rust-analyzer is on `PATH`, and Helix's built-in Rust configuration finds
it. The only override is in `modules/cli/helix.nix`: `auto-format = false`
for Rust, so formatting is an explicit `cargo fmt` or `:format`.

## Key files

| File                        | Purpose                                      |
| --------------------------- | -------------------------------------------- |
| `modules/devtools/rust.nix` | Toolchain, tools, `RUST_SRC_PATH`            |
| `modules/core.nix`          | Overlay for NixOS hosts                      |
| `modules/overlays.nix`      | Overlay for the `perSystem` package set      |
| `modules/cli/helix.nix`     | Helix Rust language entry (auto-format off)  |
| `flake.nix`                 | `rust-overlay` input                         |
