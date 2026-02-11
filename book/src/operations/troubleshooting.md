# Troubleshooting

> Common errors and their solutions when working with this NixOS configuration.

## Build failures

### Infinite recursion

**Symptom:** `error: infinite recursion encountered` during evaluation.

**Cause:** Two modules reference each other's options in a cycle.

**Fix:** Use `--show-trace` to identify the cycle:

```bash
sudo nixos-rebuild test --flake .#fern --show-trace
```

Common causes:

- A module's `config` block references an option defined in the same module
  without using `mkIf` or `mkDefault`
- Two modules import each other

### Module not found

**Symptom:** `error: attribute 'moduleName' missing` or `undefined variable`.

**Fix:** Check that the module is:

1. Registered in `flake.parts/20-nixos-mods.nix` (system modules)
2. Imported in the host's `configuration.nix`
3. Spelled correctly (names are case-sensitive)

```bash
# List available NixOS modules
nix eval .#nixosModules --apply builtins.attrNames

# List available home modules
nix eval .#homeModules --apply builtins.attrNames
```

### Package not found

**Symptom:** `error: undefined variable 'packageName'` or
`attribute 'packageName' missing`.

**Fix:** Check that:

- The package name is correct (search at
  [search.nixos.org](https://search.nixos.org))
- The overlays are applied (Rust and Zig need overlays from `10-core.nix`)
- Unfree packages are allowed (`config.allowUnfree = true` in `10-core.nix`)

### Type mismatch

**Symptom:** `error: value is a string while a list was expected` (or similar).

**Fix:** Check the option type in the NixOS manual or with:

```bash
nix eval .#nixosConfigurations.fern.options.path.to.option.type.description
```

Common mistakes:

- Passing a string where a list is expected (wrap in `[ ]`)
- Passing a path where a string is expected (use `toString` or string
  interpolation)

## Runtime issues

### Service not starting

```bash
# Check service status
systemctl status service-name
journalctl -u service-name -f

# For user services
systemctl --user status service-name
journalctl --user -u service-name -f
```

### Hyprland not launching

Check the display manager log:

```bash
journalctl -u greetd -b
```

Common issues:

- NVIDIA driver not loaded: check `nvidia-smi`
- Wrong Wayland session selected in greetd
- Missing environment variables (check `graphics.nix`)

### Audio not working

```bash
# Check PipeWire status
systemctl --user status pipewire pipewire-pulse wireplumber

# List audio devices
wpctl status

# Check if the Audient iD24 is detected
ls -la /dev/audio/
```

### Git identity wrong

```bash
# Check current identity
git config user.name
git config user.email

# Check which includeIf matched
git config --show-origin user.name
```

The identity is selected by the repository's directory path. Ensure your repo is
under the correct directory (`~/personal/` or `~/work/`).

## Flake issues

### Lock file conflicts

```bash
# Regenerate the lock file
nix flake update

# Update only one input
nix flake update nixpkgs
```

### Evaluation too slow

```bash
# Check for expensive evaluations
nix eval .#nixosConfigurations.fern.config.system.build.toplevel --show-trace 2>&1 | head -50
```

If evaluation is slow, check for:

- Large `builtins.readDir` calls
- Recursive imports
- Overlay chains that rebuild many packages

## Recovery

### Roll back

```bash
# Roll back to previous generation
just rollback

# Or select a specific generation at boot via GRUB
```

### Emergency rebuild from old generation

If the current configuration is broken and you cannot build:

```bash
# Boot into a previous generation from GRUB
# Then fix the configuration and rebuild
sudo nixos-rebuild switch --flake .#fern
```
