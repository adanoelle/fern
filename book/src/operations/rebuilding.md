# Rebuilding & Testing

> Use `just test` for safe iteration and `just switch` to apply changes. Always
> test before switching.

The `justfile` provides shortcuts for the most common rebuild operations. All
commands run `nixos-rebuild` with `--flake .#fern`.

## Rebuild commands

| Command           | What it does                                    |
| ----------------- | ----------------------------------------------- |
| `just test`       | Build and activate without adding to bootloader |
| `just test-trace` | Same as test with `--show-trace` for debugging  |
| `just switch`     | Build, activate, and add to bootloader          |
| `just dry`        | Evaluate and build without activating           |
| `just rollback`   | Switch to the previous generation               |

## Test vs switch

**`nixos-rebuild test`** builds the system and activates it (starts/stops
services, updates symlinks) but does not add it to the GRUB/systemd-boot menu.
If you reboot, the system reverts to the last `switch`ed generation. This is the
safe option for iterating on configuration changes.

**`nixos-rebuild switch`** does everything `test` does and also adds the
generation to the bootloader. Use this once you are confident the configuration
works.

## Debugging build failures

If a build fails, add `--show-trace` to see the full Nix evaluation trace:

```bash
sudo nixos-rebuild test --flake .#fern --show-trace
```

Common failure patterns:

- **Infinite recursion** -- Two modules reference each other's options
  circularly. The trace will show the recursion cycle.
- **Missing attribute** -- A module references a package or option that does not
  exist. Check spelling and whether the correct overlay is applied.
- **Type mismatch** -- An option received a value of the wrong type (e.g., a
  string where a list was expected).

## VM testing

Build a virtual machine from the configuration to test without affecting the
running system:

```bash
nixos-rebuild build-vm --flake .#fern
./result/bin/run-fern-vm
```

The VM boots the full configuration in QEMU. GPU acceleration and hardware-
specific features will not work, but service configuration, packages, and user
setup can be validated.

## Dry build

A dry build evaluates the Nix expression and fetches/builds all derivations but
does not activate anything:

```bash
just dry
# or: sudo nixos-rebuild dry-build --flake .#fern
```

This is useful for checking that a configuration evaluates correctly without
changing the running system.

## Pre-rebuild checklist

1. Format Nix files: `just fmt`
2. Check flake: `just check` (runs `nix flake check`)
3. Test build: `just test`
4. Check logs if test fails: `journalctl -xe`
5. Commit working configuration before switching
