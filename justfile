# Fern NixOS Configuration

# List available recipes
default:
    @just --list

# --- System ---

# Rebuild and switch to the new configuration
switch:
    nh os switch .

# Test the configuration without switching
test:
    nh os test .

# Test with --show-trace for debugging
test-trace:
    nh os test . -- --show-trace

# Dry-build the configuration (no activation)
dry:
    nh os build . -- --dry-run

# Rollback to the previous generation
rollback:
    sudo nixos-rebuild switch --rollback

# Bootstrap rebuild (when nh is not yet installed)
bootstrap:
    sudo nixos-rebuild test --flake .#fern

# Update all flake inputs
update:
    nix flake update

# Garbage-collect old generations (nh smart clean)
gc:
    nh clean all --keep 5 --keep-since 7d

# --- Quality ---

# Format all Nix files
fmt:
    find . -name '*.nix' -not -path './.direnv/*' -not -path './result/*' -not -path './.claude/*' | xargs nixfmt

# Run flake check
check:
    nix flake check

# Lint: format, flake check, statix, deadnix
lint: fmt check statix deadnix

# Run statix linter (ignore agent worktrees under .claude/)
statix:
    statix check -i '.claude'

# Check for dead Nix code (hardware.nix files are generated — never hand-edited)
deadnix:
    deadnix . --exclude hosts/fern/hardware.nix hosts/moss/hardware.nix

# Check flake.lock health
flake-health:
    flake-checker

# Diff the last two system generations
diff-gen:
    nvd diff $(ls -d1v /nix/var/nix/profiles/system-*-link | tail -2)

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
