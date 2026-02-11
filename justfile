# Fern NixOS Configuration

# List available recipes
default:
    @just --list

# --- System ---

# Rebuild and switch to the new configuration
switch:
    sudo nixos-rebuild switch --flake .#fern

# Test the configuration without switching
test:
    sudo nixos-rebuild test --flake .#fern

# Test with --show-trace for debugging
test-trace:
    sudo nixos-rebuild test --flake .#fern --show-trace

# Dry-build the configuration (no activation)
dry:
    sudo nixos-rebuild dry-build --flake .#fern

# Rollback to the previous generation
rollback:
    sudo nixos-rebuild switch --rollback

# Update all flake inputs
update:
    nix flake update

# Garbage-collect old generations (user + root)
gc:
    nix-collect-garbage -d
    sudo nix-collect-garbage -d

# --- Quality ---

# Format all Nix files
fmt:
    nixpkgs-fmt .

# Run flake check
check:
    nix flake check

# Format then check
lint: fmt check

# --- Documentation ---

# Serve the documentation book with live reload
book-serve:
    mdbook serve book --open

# Build the documentation book to book/build/
book-build:
    mdbook build book

# Build the documentation book as a pure Nix derivation
book-nix:
    nix build .#book
