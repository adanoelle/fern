# 🔧 System Modules - Claude Context

## Module Purpose

System-level NixOS modules that configure core functionality, hardware support,
and system services. These require root privileges and affect the entire system.

## Key Modules

- `core.nix` - Nix daemon, flakes, garbage collection
- `boot.nix` - Bootloader, kernel (Zen), initrd
- `audio.nix` - PipeWire audio subsystem
- `graphics.nix` - GPU drivers (Nvidia), OpenGL/Vulkan
- `fonts.nix` - System fonts configuration
- `users.nix` - User accounts and groups
- `secrets.nix` - SOPS-nix integration
- `secrets-guard.nix` - Secret protection measures
- `desktop/` - Desktop services (greetd, apps)
- `devtools/` - Development tools (Docker, toolchains)

## Common Tasks

### Adding a New System Module

1. Create file:

```nix
# nix/modules/category/name.nix
{ config, lib, pkgs, ... }:
{
  options = {
    services.myService = {
      enable = lib.mkEnableOption "my service";
    };
  };

  config = lib.mkIf config.services.myService.enable {
    # Implementation
  };
}
```

2. Register in `flake.parts/20-nixos-mods.nix`:

```nix
myModule = ../nix/modules/category/name.nix;
```

3. Import in host configuration:

```nix
imports = [ self.nixosModules.myModule ];
```

### Modifying Hardware Configuration

⚠️ **WARNING**: Never edit `hardware-configuration.nix` directly!

- Use modules to override hardware settings
- Use `lib.mkForce` only when necessary

### Adding System Packages

```nix
# In appropriate module
environment.systemPackages = with pkgs; [
  package-name
];
```

## Testing Changes

```bash
# Always test system changes first
sudo nixos-rebuild test --flake .#fern

# Check service status
systemctl status service-name
journalctl -u service-name -f

# If test fails, check logs
journalctl -xe
```

## Module Patterns

### Service Configuration

```nix
systemd.services.myService = {
  description = "My Service";
  wantedBy = [ "multi-user.target" ];
  serviceConfig = {
    ExecStart = "${pkgs.myapp}/bin/myapp";
    Restart = "on-failure";
  };
};
```

### Kernel Modules

```nix
boot.kernelModules = [ "module-name" ];
boot.extraModulePackages = [ config.boot.kernelPackages.module ];
```

### Firewall Rules

```nix
networking.firewall = {
  allowedTCPPorts = [ 80 443 ];
  allowedUDPPorts = [ 53 ];
};
```

## Common Issues

### Module Not Found

```bash
# Check registration
grep "moduleName" flake.parts/20-nixos-mods.nix

# Check import
grep "nixosModules" hosts/fern/configuration.nix
```

### Service Won't Start

```bash
# Check status and logs
systemctl status service-name
journalctl -u service-name --since "5 minutes ago"

# Check configuration
systemctl cat service-name
```

### Kernel Module Issues

```bash
# Check loaded modules
lsmod | grep module-name

# Check available modules
find /run/current-system/kernel-modules -name "*.ko" | grep module
```

## Safety Rules

1. **Always test before switch**

   ```bash
   sudo nixos-rebuild test --flake .#fern
   ```

2. **Never modify during operation**

   - Don't edit while system is updating
   - Don't change kernel while running critical tasks

3. **Keep rollback ready**

   ```bash
   sudo nixos-rebuild list-generations
   sudo nixos-rebuild --rollback switch
   ```

4. **Document changes**
   - Add comments explaining why
   - Note any hardware-specific settings

## Critical Files

- `hardware-configuration.nix` - Auto-generated, don't edit
- `secrets/*.yaml` - Encrypted with SOPS
- Boot configuration - Test thoroughly

## Performance Considerations

- Minimize overlays in system modules
- Use binary caches when possible
- Avoid recursive module imports
- Keep boot modules minimal

## Integration Notes

- System modules affect all users
- Changes require root/sudo
- Reboot may be required for kernel changes
- Services restart automatically on switch

---

_System modules are the foundation - test everything twice._
