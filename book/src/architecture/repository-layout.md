# Repository Layout

> All configuration lives in a flat `modules/` tree. Aspects are discovered
> automatically by `import-tree` -- no registration files, no numbered parts.

```
fern/
├── flake.nix              # Inputs + import-tree ./modules
├── flake.lock             # Pinned dependency revisions
├── modules/               # All aspects, bundles, topology, and defaults
│   ├── dendritic.nix      # Den bootstrap + Home Manager bridge
│   ├── hosts.nix          # Topology: hosts, architectures, users
│   ├── defaults.nix       # Global defaults (stateVersion, helpers)
│   ├── overlays.nix       # Nixpkgs config + overlays (Rust, Zig, Claude)
│   ├── host-fern.nix      # Fern host aspect (x86_64, AMD GPU)
│   ├── host-moss.nix      # Moss host aspect (aarch64, Asahi)
│   ├── user-ada.nix       # User ada BASE layer (shells, cli, git, ssh)
│   ├── user-ada-desktop.nix  # Desktop layer (forwarded by GUI hosts)
│   ├── user-ada-dev.nix   # Dev-toolchain layer (forwarded per host)
│   ├── roles/             # Host role bundles
│   │   ├── workstation.nix   # Graphical machine base
│   │   ├── dev-machine.nix   # Host-side dev toolchains
│   │   └── server.nix        # Headless skeleton (homelab landing zone)
│   ├── core.nix           # Nix settings, overlays, fleet defaults
│   ├── boot.nix           # systemd-boot (UEFI x86 default)
│   ├── users.nix          # User account, NetworkManager, SSH
│   ├── audio.nix          # PipeWire, low-latency, Audient iD24
│   ├── graphics.nix       # NVIDIA modesetting, VRR, Wayland
│   ├── fonts.nix          # Nerd Fonts, fontconfig
│   ├── gaming.nix         # Steam, Gamescope, GameMode
│   ├── secrets.nix        # SOPS-nix, age keys
│   ├── secrets-guard.nix  # git-secrets, trufflehog
│   ├── monitoring.nix     # Hardware sensors (lm_sensors)
│   ├── workspace.nix      # XDG user directories
│   ├── dev.nix            # Dev shell (just, mdbook, nixpkgs-fmt)
│   ├── docs.nix           # mdBook documentation build
│   ├── cli/               # CLI tool aspects
│   │   ├── bundle.nix     # CLI bundle (13 aspects)
│   │   ├── bat.nix
│   │   ├── broot.nix
│   │   ├── claude-code.nix
│   │   ├── delta.nix
│   │   ├── ghostty.nix
│   │   ├── helix.nix
│   │   └── ...
│   ├── git/               # Git suite aspects
│   │   ├── bundle.nix     # Git suite orchestrator (13 aspects)
│   │   ├── core.nix
│   │   ├── aliases.nix
│   │   ├── identities.nix
│   │   ├── safety.nix
│   │   ├── worktree.nix
│   │   └── ...
│   ├── desktop/           # Desktop environment aspects
│   │   ├── bundle.nix     # Desktop apps bundle
│   │   ├── hyprland.nix   # Hyprland compositor
│   │   ├── _hyprland/     # Hyprland sub-modules (not auto-imported)
│   │   │   ├── bar.nix
│   │   │   ├── fern.nix
│   │   │   ├── idlelock.nix
│   │   │   └── wallpaper.nix
│   │   ├── chromium.nix
│   │   ├── greetd.nix
│   │   └── ...
│   ├── shells/            # Shell environment aspects
│   │   ├── bundle.nix     # Shells bundle (4 aspects)
│   │   ├── nushell.nix
│   │   ├── starship.nix
│   │   ├── zoxide.nix
│   │   └── devenv.nix
│   ├── devtools/          # Language toolchain aspects
│   │   ├── bundle.nix     # Devtools bundle (10 aspects)
│   │   ├── rust.nix
│   │   ├── c-cpp.nix
│   │   ├── node-ts.nix
│   │   ├── docker.nix
│   │   └── ...
│   ├── asahi/             # Apple Silicon (Asahi) aspects
│   │   ├── boot.nix       # systemd-boot for Apple Silicon
│   │   └── graphics.nix   # Asahi GPU driver
│   └── cloud/             # Cloud platform aspects
│       └── aws-cli.nix
├── hosts/                 # Hardware configurations (auto-generated)
│   ├── fern/
│   │   └── hardware.nix
│   └── moss/
│       └── hardware.nix
├── book/                  # This documentation (mdBook)
│   ├── book.toml
│   └── src/
├── secrets/               # SOPS-encrypted secrets
│   └── main.yaml
├── justfile               # Command recipes
└── docs/                  # Additional documentation
```

## Where to find things

| Looking for... | Go to... |
|----------------|----------|
| Flake inputs and dependencies | `flake.nix` |
| Den bootstrap and HM bridge | `modules/dendritic.nix` |
| Host/user topology | `modules/hosts.nix` |
| What a specific host includes | `modules/host-fern.nix`, `modules/host-moss.nix` |
| Host role bundles | `modules/roles/` |
| What a user includes | `modules/user-ada.nix` (+ `-desktop`/`-dev` layers) |
| A system-level service or driver | `modules/*.nix` (top-level) |
| A user-level tool or dotfile | `modules/cli/`, `modules/shells/`, `modules/desktop/` |
| Git configuration (all of it) | `modules/git/` |
| Hyprland setup | `modules/desktop/hyprland.nix` + `modules/desktop/_hyprland/` |
| Language toolchains | `modules/devtools/` |
| Cloud platform tools | `modules/cloud/` |
| Encrypted secrets | `secrets/main.yaml` |
| Build/test/format commands | `justfile` |

## Key structural differences from the old layout

| Old | New | Why |
|-----|-----|-----|
| `flake.parts/` (7 numbered files) | `modules/` (flat tree) | `import-tree` discovers everything automatically |
| `nix/modules/` (system) + `nix/home/` (user) | `modules/` (unified) | Aspects can have both `nixos` and `homeManager` sides |
| `flake.parts/20-nixos-mods.nix` (registry) | None needed | `import-tree` replaces manual registration |
| `hosts/*/configuration.nix` (import lists) | `modules/host-*.nix` (includes) | Den `includes` replace explicit `imports` |
| Aggregator files (`cli.nix`, `desktop.nix`) | Bundle files (`cli/bundle.nix`) | Bundles use `den.aspects` includes |

## The underscore convention

Directories prefixed with `_` (like `_hyprland/`) are skipped by `import-tree`.
Files in these directories are not standalone aspects -- they are imported
explicitly by a parent aspect. Use this when a complex aspect needs to split
into sub-files.
