# Rust

> Stable Rust toolchain with rust-analyzer, cargo-audit and cargo-deny.

## Overview

The Rust toolchain is managed through the `rust-overlay` flake input, which
provides `pkgs.rust-bin` for selecting specific toolchain versions. The
configuration uses the latest stable release with rustfmt, clippy, and
rust-analyzer.

## Aspect

The Rust aspect (`modules/devtools/rust.nix`) installs:

| Package                          | Purpose                                 |
| -------------------------------- | --------------------------------------- |
| `rust-bin.stable.latest.default` | Stable compiler, cargo, clippy, rustfmt; overridden to add `rust-src` |
| `rust-analyzer`                  | Language server                         |
| `cargo-audit`                    | Dependency vulnerability scanner        |
| `cargo-deny`                     | Dependency license and advisory checker |

### Environment variables

```bash
RUST_SRC_PATH="<toolchain>/lib/rustlib/src/rust/library"
```

`RUST_SRC_PATH` points rust-analyzer at the standard library sources, which
come from the `rust-src` component added to the toolchain.

There is deliberately **no global `RUSTFLAGS`**. An environment `RUSTFLAGS`
replaces every project's own `.cargo/config.toml` rustflags, and the flags
that used to be set here caused real problems: `opt-level=z` overrode release
profiles, `target-cpu=native` produced binaries tied to the build machine's
CPU, and a GNU-ld link argument broke targets such as `wasm32`. Put hardening
or tuning flags in the project's own cargo config.

## Helix integration

Rust LSP integration with Helix is provided through rust-analyzer (installed by
the aspect). Helix detects rust-analyzer automatically. Auto-format is
disabled in Helix for Rust files -- use `cargo fmt` manually.

## Key files

| File                        | Purpose                                      |
| --------------------------- | -------------------------------------------- |
| `modules/devtools/rust.nix` | Rust toolchain and `RUST_SRC_PATH`           |
| `modules/cli/helix.nix`    | Helix Rust language config (auto-format off) |
| `flake.nix`                 | `rust-overlay` input                         |
| `modules/core.nix`          | Rust overlay applied to pkgs                 |
