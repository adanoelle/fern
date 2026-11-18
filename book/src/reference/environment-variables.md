# Environment Variables

> All environment variables set by system and home modules, organized by
> category.

## Rust

Set by `modules/devtools/rust.nix`:

| Variable        | Value                                                                  | Purpose                                   |
| --------------- | ---------------------------------------------------------------------- | ----------------------------------------- |
| `RUST_SRC_PATH` | `<nix-store>/lib/rustlib/src/rust/library`                             | Standard library source for rust-analyzer |

## C / C++

Set by `modules/devtools/c-cpp.nix`:

| Variable   | Value                                          | Purpose                      |
| ---------- | ---------------------------------------------- | ---------------------------- |
| `CFLAGS`   | `-fstack-protector-strong -Wl,-z,relro,-z,now` | C compiler hardening flags   |
| `CXXFLAGS` | `-fstack-protector-strong -Wl,-z,relro,-z,now` | C++ compiler hardening flags |

## Ada

Set by `modules/devtools/ada.nix`:

| Variable           | Value                            | Purpose                 |
| ------------------ | -------------------------------- | ----------------------- |
| `ADA_PROJECT_PATH` | `$HOME/.config/ada_project_path` | GPR project search path |

## Game development

Set by `modules/devtools/gamedev.nix`:

| Variable            | Value                             | Purpose                 |
| ------------------- | --------------------------------- | ----------------------- |
| `CMAKE_PREFIX_PATH` | Paths to SDL2, ImGui, Tracy, etc. | CMake package discovery |
| `PKG_CONFIG_PATH`   | Paths to game library `.pc` files | pkg-config discovery    |

## Wayland / Desktop

Set by `modules/desktop/chromium.nix`:

| Variable         | Value | Purpose                              |
| ---------------- | ----- | ------------------------------------ |
| `NIXOS_OZONE_WL` | `1`   | Signal Wayland mode to Electron apps |

## AWS / Cloud

Set by `modules/cloud/aws-cli.nix`:

| Variable              | Value | Purpose                          |
| --------------------- | ----- | -------------------------------- |
| `AWS_SDK_LOAD_CONFIG` | `1`   | Load config from `~/.aws/config` |

## Shell

Set by `modules/shells/nushell.nix`:

| Variable    | Value   | Purpose               |
| ----------- | ------- | --------------------- |
| `EDITOR`    | `hx`    | Default text editor   |
| `VISUAL`    | `hx`    | Default visual editor |
| `PAGER`     | `delta` | Default pager         |
| `GIT_PAGER` | `delta` | Git diff pager        |
