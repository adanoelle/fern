# Introduction

Fern is a NixOS configuration for a development workstation. It manages the full
stack from bootloader to shell prompt using Nix flakes, Home Manager, and the
[vic/den](https://github.com/vic/den) aspect framework with automatic module
discovery.

## Key technologies

- **Niri** -- Primary scrollable-tiling Wayland compositor, paired with the
  garden shell (QuickShell); Hyprland is retained as a fallback session
- **Helix** -- Modal text editor with per-language LSP integration
- **Nushell** -- Structured-data shell with Starship prompt and Zoxide
  navigation
- **Nix flakes** -- Reproducible system builds with pinned inputs via
  `flake.lock`
- **Home Manager** -- User-space configuration (dotfiles, services, packages) as
  NixOS modules
- **den** -- Aspect framework providing topology, includes, and dual-side
  modules
- **import-tree** -- Automatic recursive discovery of all modules in the tree
- **SOPS-nix** -- Age-encrypted secrets decrypted at activation time

## Quick start

```bash
# Enter the dev shell (provides just, mdbook, nixfmt)
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
chapter. It explains flakes, the module system, Home Manager, and the
[aspects, bundles, and topology](concepts/aspects-bundles-topology.md)
vocabulary used throughout this book.

If you already know NixOS and want to understand how this repository is
organized, go to [Architecture](architecture/repository-layout.md). The
architecture section explains the flake entry point, den bootstrap, topology,
aspect patterns, and bundle composition.

If you are migrating from the old garden.* / flake-parts architecture, the
[Migration](migration/why-den.md) section explains what changed and why.

Everything else is reference material organized by topic: desktop environment,
git suite, shells, language toolchains, game development, system services,
security, and operations.
