# Adding a Host

> How to add a new machine to the configuration: generate hardware config,
> create a host aspect, and add a topology line.

## Prerequisites

- The new machine must be running NixOS (or you need its hardware configuration
  from a NixOS installer)
- You know the machine's architecture (`x86_64-linux` or `aarch64-linux`)

## Step 1: Generate hardware configuration

On the target machine, run:

```bash
nixos-generate-config --show-hardware-config > hardware.nix
```

Place this file at `hosts/<hostname>/hardware.nix`. This file describes the
machine's disk layout, kernel modules, and firmware. It is auto-generated and
should not be edited by hand.

## Step 2: Add a topology line

Add the new host to `modules/hosts.nix`:

```nix
# modules/hosts.nix
{ ... }:
{
  den.hosts.x86_64-linux.fern.users.ada = {};
  den.hosts.aarch64-linux.moss.users.ada = {};
  den.hosts.x86_64-linux.newhost.users.ada = {};   # Add this
}
```

This tells den that `newhost` exists, runs on x86_64, and has a user `ada`.
Den will generate `nixosConfigurations.newhost` as a flake output.

## Step 3: Create the host aspect

Create `modules/host-newhost.nix`:

```nix
# modules/host-newhost.nix
{ den, inputs, ... }:
{
  den.aspects.newhost = {
    includes = [
      den.aspects.core         # Nix settings, garbage collection
      den.aspects.users        # User account, NetworkManager
      den.aspects.audio        # PipeWire (if needed)
      den.aspects.greetd       # Display manager (if desktop)
      den.aspects.fonts        # Fonts (if desktop)
      # Add other aspects as needed
    ];

    nixos = { pkgs, ... }: {
      imports = [ ../hosts/newhost/hardware.nix ];

      # Boot loader
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      # GPU (choose one or configure inline)
      hardware.graphics.enable = true;

      # Timezone
      time.timeZone = "America/New_York";

      # Trusted users for remote builds
      nix.settings.trusted-users = [ "root" "ada" ];
    };
  };
}
```

The `includes` list determines which shared aspects the new host uses. Start
with `core` and `users`, then add aspects as needed.

## Step 4: Test the build

```bash
# Dry build (does not require the target machine)
nix build .#nixosConfigurations.newhost.config.system.build.toplevel --dry-run

# Full test build
sudo nixos-rebuild test --flake .#newhost

# If building remotely:
nixos-rebuild test --flake .#newhost --target-host newhost --build-host localhost
```

## Step 5: Deploy

On the target machine (or via remote deploy):

```bash
sudo nixos-rebuild switch --flake .#newhost
```

## Example: fern and moss

The two existing hosts show the pattern:

**Fern** (full workstation -- 18 aspect includes):
```nix
den.aspects.fern.includes = [
  den.aspects.core  den.aspects.audio  den.aspects.monitoring
  den.aspects.users  den.aspects.secrets-guard  den.aspects.greetd
  den.aspects.fonts  den.aspects.docker  den.aspects.c-cpp
  den.aspects.localstack  den.aspects.rust  den.aspects.node-ts
  den.aspects.aws-cli  den.aspects.azure-cli  den.aspects.lmstudio
  den.aspects.teams  den.aspects.vscode  den.aspects.sqlserver
];
```

**Moss** (minimal -- 9 aspect includes):
```nix
den.aspects.moss.includes = [
  den.aspects.boot-asahi  den.aspects.core  den.aspects.docker
  den.aspects.users  den.aspects.audio  den.aspects.graphics-asahi
  den.aspects.greetd  den.aspects.secrets  den.aspects.secrets-guard
];
```

User-level configuration is shared automatically -- both hosts have user `ada`,
so both get the same CLI tools, git suite, desktop environment, and shell
configuration through the user aspect.

## Key files

| File | Purpose |
|------|---------|
| `modules/hosts.nix` | Topology (add your host here) |
| `modules/host-fern.nix` | Example: full workstation host |
| `modules/host-moss.nix` | Example: minimal host |
| `modules/defaults.nix` | Defaults applied to all hosts |
| `hosts/<name>/hardware.nix` | Auto-generated hardware config |
