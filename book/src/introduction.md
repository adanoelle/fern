# Introduction

Fern is a NixOS configuration for a development workstation built around Hyprland, Helix, and Nushell. It uses Nix flakes with flake-parts for modular organization, Home Manager for user-level configuration, and SOPS-nix for secret management.

This book documents the system's architecture, development workflows, and tooling. Chapters marked as drafts in the sidebar are planned but not yet written.

## What's here now

- **Gamedev** — Full documentation of the C++/SDL2 game development stack, debug overlays, profiling tools, and GPU debugging workflows available through this configuration.

## Building the book

```bash
# Live preview with hot reload
nix run .#book-serve

# Build to book/build/
nix run .#book-build

# Pure Nix build (for CI)
nix build .#book

# Drop into a shell with mdbook available
nix develop .#docs
```

## Project layout

```
fern/
├── flake.nix              # Flake definition
├── flake.parts/           # Modular flake organization
├── hosts/fern/            # Machine-specific configuration
├── nix/home/              # Home Manager modules
├── nix/modules/           # NixOS system modules
├── book/                  # This documentation (mdBook)
│   ├── book.toml
│   └── src/
└── secrets/               # SOPS-encrypted secrets
```
