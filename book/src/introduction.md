# Introduction

Fern is a NixOS configuration for a development workstation. It manages the full
stack from bootloader to shell prompt using Nix flakes, Home Manager, and a
modular architecture that supports multiple machines with different hardware.

## Key technologies

- **Hyprland** -- Wayland compositor with per-workspace wallpapers and a custom
  QuickShell bar
- **Helix** -- Modal text editor with per-language LSP integration
- **Nushell** -- Structured-data shell with Starship prompt and Zoxide
  navigation
- **Nix flakes** -- Reproducible system builds with pinned inputs via
  `flake.lock`
- **Home Manager** -- User-space configuration (dotfiles, services, packages) as
  NixOS modules
- **SOPS-nix** -- Age-encrypted secrets decrypted at activation time
- **flake-parts** -- Modular flake organization across numbered files

## Quick start

```bash
# Enter the dev shell (provides just, mdbook, nixpkgs-fmt)
nix develop            # or: direnv allow

# Test a rebuild without switching
just test

# Rebuild and switch
just switch

# Serve this documentation with live reload
just book-serve

# Format Nix files
just fmt
```

## How to read this book

If you are new to NixOS, start with the [Concepts](concepts/nixos-and-flakes.md)
chapter. It explains flakes, the module system, and Home Manager without
assuming prior knowledge.

If you already know NixOS and want to understand how this repository is
organized, go to [Architecture](architecture/repository-layout.md).

Everything else is reference material organized by topic: desktop environment,
development tools, language toolchains, system services, security, and
operations.
