# Module Patterns

> This page documents common patterns used across modules in the configuration:
> option gating, aggregators, environment setup, LSP integration, and hardening.

## Option gating with mkIf

Most Home Manager modules in this repo use options to control whether they are
active. The Hyprland module is a good example:

```nix
{ config, lib, pkgs, ... }:
let
  cfg = config.desktop.hyprland;
in
{
  options.desktop.hyprland = {
    enable = lib.mkEnableOption "Hyprland desktop environment";
    modKey = lib.mkOption {
      type = lib.types.str;
      default = "SUPER";
    };
    # ... more options
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.enable = true;
    # ... rest of configuration
  };
}
```

The host configuration then sets `desktop.hyprland.enable = true` and optionally
overrides defaults. Nothing activates until `enable` is set.

System modules in this repo tend to be simpler -- most are config-only (no
`options` block) and are gated purely by whether the host imports them. This
works because each host's `configuration.nix` explicitly lists its imports.

## Aggregator modules

Several top-level files act as aggregators, importing groups of related modules
without adding configuration of their own:

```nix
# nix/home/cli.nix
{ ... }:
{
  imports = [
    ./cli/bat.nix
    ./cli/broot.nix
    ./cli/ghostty.nix
    ./cli/helix.nix
    # ... 12 modules total
  ];
}
```

The aggregators are:

| Aggregator | Path                       | Contains                                                  |
| ---------- | -------------------------- | --------------------------------------------------------- |
| `cli`      | `nix/home/cli.nix`         | bat, broot, ghostty, helix, delta, glow, etc.             |
| `desktop`  | `nix/home/desktop.nix`     | chromium, gaming, hyprland, nyxt, obs, screenshot         |
| `devtools` | `nix/home/devtools.nix`    | ada, cpp, csharp, python, typescript, gamedev, zig        |
| `shells`   | `nix/home/shells.nix`      | devenv, nushell, starship, zoxide                         |
| `git`      | `nix/home/git/default.nix` | core, aliases, identities, safety, tools, worktrees, etc. |

This pattern keeps `configuration.nix` clean -- it imports six modules instead
of 50+.

## Environment variable setup

Language toolchain modules set environment variables so that compilers, LSPs,
and build tools can find each other:

```nix
# nix/modules/devtools/rust.nix
environment.variables = {
  RUSTFLAGS = lib.strings.concatStringsSep " " commonFlags;
  RUST_SRC_PATH = "${stable}/lib/rustlib/src/rust/library";
};

# nix/modules/devtools/c-toolchain.nix
environment.variables = {
  CFLAGS  = lib.concatStringsSep " " safeFlags;
  CXXFLAGS = lib.concatStringsSep " " safeFlags;
};

# nix/modules/devtools/csharp-toolchain.nix
environment.variables.DOTNET_ROOT = "${pkgs.dotnetCorePackages.sdk_8_0}";
```

The gamedev home module sets `CMAKE_PREFIX_PATH` and `PKG_CONFIG_PATH` to
include all game development libraries, so CMake can find SDL2, ImGui, Tracy,
and others without manual configuration.

## Helix LSP integration per language

Each language's home module configures Helix's language server. This keeps LSP
configuration co-located with the toolchain rather than centralized in the Helix
module:

```nix
# nix/home/devtools/cpp.nix
programs.helix.languages.language-server.clangd = {
  command = "${pkgs.clang-tools}/bin/clangd";
  args = [ "--background-index" "--clang-tidy" ];
};

# nix/home/devtools/python.nix
programs.helix.languages.language-server.pyright = {
  command = "${pkgs.pyright}/bin/pyright-langserver";
  args = [ "--stdio" ];
};

# nix/home/devtools/typescript.nix
programs.helix.languages.language-server.typescript-language-server = {
  command = "${pkgs.typescript-language-server}/bin/typescript-language-server";
  args = [ "--stdio" ];
};
```

Helix's config merges all of these together, so enabling a language toolchain
automatically adds its LSP to the editor.

## Hardening flags

The C and Rust toolchain modules apply security hardening by default:

**C/C++** (`c-toolchain.nix`):

- `-fstack-protector-strong` -- stack buffer overflow detection
- `-Wl,-z,relro,-z,now` -- full RELRO (read-only relocations)

**Rust** (`rust.nix`):

- `-C link-args=-Wl,-z,relro,-z,now` -- full RELRO
- `-C opt-level=z` -- optimize for size
- `-C target-cpu=native` -- use host CPU features

These are set via `CFLAGS`, `CXXFLAGS`, and `RUSTFLAGS` environment variables
and apply to all builds in the user's shell.

## Systemd service hardening

The Fern Shell home module applies systemd hardening to user services:

```nix
Service = {
  PrivateTmp = true;
  ProtectSystem = "strict";
  ProtectHome = "read-only";
  MemoryMax = "200M";
  TasksMax = 50;
};
```

This limits what the shell bar process can do: it cannot write to the filesystem
(except its own temp), cannot consume unbounded memory, and has a capped number
of threads.

## Key files

| File                                   | Purpose                           |
| -------------------------------------- | --------------------------------- |
| `nix/home/cli.nix`                     | CLI aggregator module             |
| `nix/home/desktop.nix`                 | Desktop aggregator module         |
| `nix/home/devtools.nix`                | Dev tools aggregator module       |
| `nix/home/git/default.nix`             | Git suite aggregator with options |
| `nix/modules/devtools/rust.nix`        | Rust env vars + hardening         |
| `nix/modules/devtools/c-toolchain.nix` | C/C++ env vars + hardening        |
| `nix/home/desktop/hyprland/fern.nix`   | Systemd hardening example         |
