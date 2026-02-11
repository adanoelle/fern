# Environment Variables

> All environment variables set by system and home modules, organized by
> category.

## Rust

Set by `nix/modules/devtools/rust.nix`:

| Variable        | Value                                                                  | Purpose                                   |
| --------------- | ---------------------------------------------------------------------- | ----------------------------------------- |
| `RUSTFLAGS`     | `-C link-args=-Wl,-z,relro,-z,now -C opt-level=z -C target-cpu=native` | Hardening and optimization flags          |
| `RUST_SRC_PATH` | `<nix-store>/lib/rustlib/src/rust/library`                             | Standard library source for rust-analyzer |

## C / C++

Set by `nix/modules/devtools/c-toolchain.nix`:

| Variable   | Value                                          | Purpose                      |
| ---------- | ---------------------------------------------- | ---------------------------- |
| `CFLAGS`   | `-fstack-protector-strong -Wl,-z,relro,-z,now` | C compiler hardening flags   |
| `CXXFLAGS` | `-fstack-protector-strong -Wl,-z,relro,-z,now` | C++ compiler hardening flags |

## .NET

Set by `nix/modules/devtools/csharp-toolchain.nix`:

| Variable      | Value                        | Purpose                     |
| ------------- | ---------------------------- | --------------------------- |
| `DOTNET_ROOT` | `<nix-store>/dotnet-sdk-8.0` | .NET SDK location for tools |

## Ada

Set by `nix/modules/devtools/ada-toolchain.nix`:

| Variable           | Value                            | Purpose                 |
| ------------------ | -------------------------------- | ----------------------- |
| `ADA_PROJECT_PATH` | `$HOME/.config/ada_project_path` | GPR project search path |

## Game development

Set by `nix/home/devtools/gamedev.nix`:

| Variable            | Value                             | Purpose                 |
| ------------------- | --------------------------------- | ----------------------- |
| `CMAKE_PREFIX_PATH` | Paths to SDL2, ImGui, Tracy, etc. | CMake package discovery |
| `PKG_CONFIG_PATH`   | Paths to game library `.pc` files | pkg-config discovery    |

## NVIDIA / Graphics

Set by `nix/modules/graphics.nix`:

| Variable                    | Value    | Purpose                              |
| --------------------------- | -------- | ------------------------------------ |
| `__GL_GSYNC_ALLOWED`        | `1`      | Enable GSync/VRR                     |
| `__GL_VRR_ALLOWED`          | `1`      | Enable variable refresh rate         |
| `WLR_NO_HARDWARE_CURSORS`   | `1`      | Software cursors (NVIDIA workaround) |
| `__GLX_VENDOR_LIBRARY_NAME` | `nvidia` | Force NVIDIA GLX provider            |

## Wayland / Desktop

Set by `nix/home/desktop/chromium.nix`:

| Variable         | Value | Purpose                              |
| ---------------- | ----- | ------------------------------------ |
| `NIXOS_OZONE_WL` | `1`   | Signal Wayland mode to Electron apps |

Set by `nix/home/desktop/nyxt.nix` (wrapper):

| Variable                          | Value | Purpose                     |
| --------------------------------- | ----- | --------------------------- |
| `WEBKIT_DISABLE_COMPOSITING_MODE` | `1`   | WebKitGTK NVIDIA workaround |
| `WEBKIT_DISABLE_DMABUF_RENDERER`  | `1`   | Disable DMA-BUF rendering   |
| `__GL_THREADED_OPTIMIZATIONS`     | `0`   | Disable threaded GL         |

## AWS / Cloud

Set by `nix/modules/cloud/aws-cli.nix`:

| Variable              | Value | Purpose                          |
| --------------------- | ----- | -------------------------------- |
| `AWS_SDK_LOAD_CONFIG` | `1`   | Load config from `~/.aws/config` |

Set by `nix/modules/devtools/localstack.nix`:

| Variable                | Value                   | Purpose                     |
| ----------------------- | ----------------------- | --------------------------- |
| `AWS_ENDPOINT_URL`      | `http://localhost:4566` | LocalStack endpoint         |
| `AWS_ACCESS_KEY_ID`     | `test`                  | LocalStack test credentials |
| `AWS_SECRET_ACCESS_KEY` | `test`                  | LocalStack test credentials |
| `AWS_DEFAULT_REGION`    | `us-east-1`             | LocalStack default region   |
| `LOCALSTACK_HOST`       | `localhost`             | LocalStack hostname         |

## Azure

Set by `nix/modules/azure-cli.nix`:

| Variable         | Value                   | Purpose                                 |
| ---------------- | ----------------------- | --------------------------------------- |
| `PYTHONWARNINGS` | `ignore::FutureWarning` | Suppress Azure CLI deprecation warnings |

## Shell

Set by `nix/home/shells/nushell.nix`:

| Variable    | Value   | Purpose               |
| ----------- | ------- | --------------------- |
| `EDITOR`    | `hx`    | Default text editor   |
| `VISUAL`    | `hx`    | Default visual editor |
| `PAGER`     | `delta` | Default pager         |
| `GIT_PAGER` | `delta` | Git diff pager        |
