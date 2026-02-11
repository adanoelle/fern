# Rust

> Stable Rust toolchain with rust-analyzer, cargo-audit, cargo-deny, and
> hardening flags applied via RUSTFLAGS.

## Overview

The Rust toolchain is managed through the `rust-overlay` flake input, which
provides `pkgs.rust-bin` for selecting specific toolchain versions. The
configuration uses the latest stable release with rustfmt, clippy, and
rust-analyzer.

## System module

The system module (`nix/modules/devtools/rust.nix`) installs:

| Package                          | Purpose                                 |
| -------------------------------- | --------------------------------------- |
| `rust-bin.stable.latest.default` | Stable Rust compiler + cargo            |
| `rust-bin.stable.latest.clippy`  | Linter                                  |
| `rust-bin.stable.latest.rustfmt` | Formatter                               |
| `rust-analyzer`                  | Language server                         |
| `cargo-audit`                    | Dependency vulnerability scanner        |
| `cargo-deny`                     | Dependency license and advisory checker |

### Environment variables

```bash
RUSTFLAGS="-C link-args=-Wl,-z,relro,-z,now -C opt-level=z -C target-cpu=native"
RUST_SRC_PATH="<nix-store>/lib/rustlib/src/rust/library"
```

- **`-Wl,-z,relro,-z,now`** -- Full RELRO for hardened binaries
- **`-C opt-level=z`** -- Optimize for binary size
- **`-C target-cpu=native`** -- Use host CPU features
- **`RUST_SRC_PATH`** -- Points rust-analyzer to standard library sources

## Home module

Rust LSP integration with Helix is provided through rust-analyzer (installed by
the system module). Helix detects rust-analyzer automatically. Auto-format is
disabled in Helix for Rust files -- use `cargo fmt` manually.

## Key files

| File                            | Purpose                                      |
| ------------------------------- | -------------------------------------------- |
| `nix/modules/devtools/rust.nix` | Rust toolchain, env vars, hardening          |
| `nix/home/cli/helix.nix`        | Helix Rust language config (auto-format off) |
| `flake.nix`                     | `rust-overlay` input                         |
| `flake.parts/10-core.nix`       | Rust overlay applied to pkgs                 |
