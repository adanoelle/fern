# Repository Layout

> The repository is organized into flake parts, host configurations, system
> modules, and home modules -- each in its own directory.

```
fern/
├── flake.nix              # Flake definition (inputs + imports)
├── flake.lock             # Pinned dependency revisions
├── flake.parts/           # Modular flake organization
│   ├── 00-overlay.nix     # Package overlays
│   ├── 10-core.nix        # System list, nixpkgs config, overlays
│   ├── 20-nixos-mods.nix  # NixOS module registry
│   ├── 30-home-mods.nix   # Home Manager module registry
│   ├── 40-hosts.nix       # Host configurations (fern, moss)
│   ├── 50-dev.nix         # Development shell
│   └── 60-docs.nix        # mdBook documentation build
├── hosts/                 # Machine-specific configurations
│   ├── fern/              # x86_64 workstation (NVIDIA)
│   │   ├── configuration.nix
│   │   └── hardware.nix
│   └── moss/              # aarch64 laptop (Apple Silicon)
│       ├── configuration.nix
│       └── hardware.nix
├── nix/
│   ├── modules/           # NixOS system modules
│   │   ├── core.nix       # Nix settings, garbage collection
│   │   ├── boot.nix       # GRUB + Zen kernel
│   │   ├── boot-asahi.nix # systemd-boot for Apple Silicon
│   │   ├── users.nix      # User account, NetworkManager, SSH
│   │   ├── audio.nix      # PipeWire, low-latency, Audient iD24
│   │   ├── graphics.nix   # NVIDIA modesetting, VRR, Wayland
│   │   ├── graphics-asahi.nix  # Asahi GPU driver
│   │   ├── fonts.nix      # Nerd Fonts, fontconfig
│   │   ├── gaming.nix     # Steam, Gamescope, GameMode, controllers
│   │   ├── secrets.nix    # SOPS-nix, age keys, SSH key decryption
│   │   ├── secrets-guard.nix   # git-secrets, trufflehog
│   │   ├── azure-cli.nix  # Azure CLI with extensions
│   │   ├── cloud/
│   │   │   └── aws-cli.nix    # AWS CLI, SAM, Terraform, vault
│   │   ├── desktop/
│   │   │   ├── greetd.nix     # Display manager, XDG portals, Polkit
│   │   │   ├── claude.nix     # VS Code
│   │   │   ├── cursor.nix     # Cursor IDE
│   │   │   ├── lmstudio.nix   # LM Studio AppImage
│   │   │   ├── teams.nix      # Microsoft Teams
│   │   │   ├── sqlserver.nix  # SQL Studio
│   │   │   └── vscode.nix     # VS Code (alternate)
│   │   └── devtools/
│   │       ├── ada-toolchain.nix    # GNAT, GPRBuild, Alire
│   │       ├── c-toolchain.nix      # GCC, Clang, CMake, hardening flags
│   │       ├── csharp-toolchain.nix # .NET 8, Mono, MSBuild
│   │       ├── python-toolchain.nix # Python 3.12, uv
│   │       ├── rust.nix             # Stable Rust, rust-analyzer, cargo tools
│   │       ├── node-ts.nix          # Node.js 24, pnpm, Deno, CDK
│   │       ├── docker.nix           # Docker, BuildKit, Compose, utilities
│   │       └── localstack.nix       # LocalStack container, awslocal
│   └── home/              # Home Manager modules
│       ├── cli.nix        # Aggregator: bat, helix, ghostty, etc.
│       ├── desktop.nix    # Aggregator: hyprland, browsers, OBS
│       ├── devtools.nix   # Aggregator: language-specific tools
│       ├── shells.nix     # Aggregator: nushell, starship, zoxide
│       ├── workspace.nix  # XDG directory management
│       ├── cli/           # Individual CLI tool modules
│       ├── desktop/       # Desktop app modules
│       │   └── hyprland/  # Hyprland sub-modules
│       ├── devtools/      # Per-language tool modules
│       ├── git/           # Git suite (12 modules)
│       └── shells/        # Shell configuration modules
├── book/                  # This documentation (mdBook)
│   ├── book.toml
│   └── src/
├── secrets/               # SOPS-encrypted secrets
│   └── main.yaml
├── justfile               # Command recipes
└── docs/                  # Additional documentation
```

## Where to find things

| Looking for...                   | Go to...                                                        |
| -------------------------------- | --------------------------------------------------------------- |
| Flake inputs and dependencies    | `flake.nix`                                                     |
| Which modules exist              | `flake.parts/20-nixos-mods.nix`, `flake.parts/30-home-mods.nix` |
| What a specific host enables     | `hosts/<name>/configuration.nix`                                |
| A system-level service or driver | `nix/modules/`                                                  |
| A user-level tool or dotfile     | `nix/home/`                                                     |
| Git configuration (all of it)    | `nix/home/git/`                                                 |
| Hyprland setup                   | `nix/home/desktop/hyprland/`                                    |
| Language toolchains              | `nix/modules/devtools/` (system) + `nix/home/devtools/` (user)  |
| Encrypted secrets                | `secrets/main.yaml`                                             |
| Build/test/format commands       | `justfile`                                                      |
