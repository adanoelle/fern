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
{ den, ... }:
{
  den.aspects.newhost = {
    includes = [
      den.aspects.boot          # systemd-boot (UEFI x86)
      den.aspects.workstation   # role: graphical machine base
      # or den.aspects.server for a headless box
      # Add host-specific aspects as needed
    ];

    # Graphical/dev hosts forward user layers; a server forwards none
    # and its users get only the base ada aspect.
    provides.to-users.includes = [
      den.aspects.ada-desktop
      den.aspects.ada-dev
    ];

    nixos = { pkgs, ... }: {
      imports = [ ../hosts/newhost/hardware.nix ];

      # GPU (choose one or configure inline)
      hardware.graphics.enable = true;

      # Pin at the NixOS release current when this machine is installed
      system.stateVersion = "25.11";
    };
  };
}
```

Pick a **role** from `modules/roles/` (workstation, server, dev-machine) as the
base, then add host-specific aspects. Fleet defaults — timezone, trusted-users,
nix-ld — come from `core` via `mkDefault`; override them in the `nixos` block
only if this machine differs.

## Step 4: Register the host as a sops recipient

**Do this before the first build.** Any role that includes the `secrets`
aspect (workstation does) needs the host registered in `.sops.yaml`, or the
first activation will fail loudly — by design.

The host's decryption identity is derived from its SSH host key, so it exists
as soon as the machine has booted NixOS once:

```bash
ssh-keyscan -t ed25519 <host> | ssh-to-age
```

Add the resulting `age1...` recipient to `.sops.yaml` as `&host_<name>`,
extend the `creation_rules` to include it, then re-key and commit:

```bash
sops updatekeys secrets/*.yaml
git commit -am "chore(secrets): register <host> as sops recipient"
```

See [SOPS-nix](../security/sops-nix.md) for details and recovery procedures.

## Step 5: Test the build

```bash
# Dry build (does not require the target machine)
nix build .#nixosConfigurations.newhost.config.system.build.toplevel --dry-run

# Full test build
sudo nixos-rebuild test --flake .#newhost

# If building remotely:
nixos-rebuild test --flake .#newhost --target-host newhost --build-host localhost
```

## Step 6: Deploy

On the target machine (or via remote deploy):

```bash
sudo nixos-rebuild switch --flake .#newhost
```

## Example: fern and moss

The two existing hosts show the pattern:

**Fern** (roles + fern-specific aspects):
```nix
den.aspects.fern.includes = [
  den.aspects.boot  den.aspects.workstation  den.aspects.dev-machine
  den.aspects.monitoring  den.aspects.niri
  den.aspects.lmstudio  den.aspects.teams
];
```

**Moss** (explicit list -- Asahi hardware makes it quirky enough to compose by
hand):
```nix
den.aspects.moss.includes = [
  den.aspects.boot-asahi  den.aspects.core  den.aspects.docker
  den.aspects.users  den.aspects.audio  den.aspects.graphics-asahi
  den.aspects.greetd  den.aspects.secrets  den.aspects.secrets-guard
];
```

User-level configuration is layered: every host's `ada` gets the base aspect
(CLI tools, git suite, shells) automatically, and each host decides which extra
layers to forward via `provides.to-users` -- both current machines forward
`ada-desktop` and `ada-dev`.

## Key files

| File | Purpose |
|------|---------|
| `modules/hosts.nix` | Topology (add your host here) |
| `modules/roles/` | Role bundles: workstation, server, dev-machine |
| `modules/host-fern.nix` | Example: role-composed workstation host |
| `modules/host-moss.nix` | Example: explicitly-composed host |
| `modules/defaults.nix` | Defaults applied to all hosts |
| `.sops.yaml` | Sops recipient registry (register new hosts here) |
| `hosts/<name>/hardware.nix` | Auto-generated hardware config |
