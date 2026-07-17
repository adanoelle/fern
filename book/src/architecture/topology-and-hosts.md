# Topology & Hosts

> Den's topology declares which machines exist, what architecture they run, and
> which users live on each. Host aspects then define what each machine includes.

## The topology

The entire host/user structure is declared in a few lines:

```nix
# modules/hosts.nix
{ ... }:
{
  den.hosts.x86_64-linux.fern.users.ada = {};
  # moss is parked (see below)
  # den.hosts.aarch64-linux.moss.users.ada = {};
}
```

> **Moss is currently parked.** Its `hardware.nix` is still the installer
> placeholder and several aspects pull x86_64-only packages (gnat13, ldtk,
> renderdoc), so the config cannot evaluate on aarch64-linux. Its topology
> line is commented out in `modules/hosts.nix`; the host aspect and docs
> below describe its intended shape. Re-enable after generating the real
> hardware.nix and platform-gating those packages.

The path structure is `den.hosts.<system>.<hostname>.users.<username>`. Den uses
this to:

1. Generate `nixosConfigurations.fern` and `nixosConfigurations.moss` as flake
   outputs
2. Set the correct `system` (architecture) for each host's package set
3. Wire Home Manager for each declared user on each host
4. Resolve which aspects apply to which host/user combination

## The two hosts

| Property | fern | moss (parked) |
|----------|------|------|
| Architecture | x86_64-linux | aarch64-linux |
| GPU | AMD (Mesa/AMDGPU) | Apple Silicon (Asahi) |
| Boot | systemd-boot + Zen kernel | systemd-boot |
| Gaming | Steam, Gamescope, GameMode | Not included |
| Cloud tools | AWS, LocalStack | Not included |
| Dev toolchains | Rust, C/C++, TypeScript | Not included |
| Desktop | Niri (+ Hyprland fallback) + garden shell | Niri (+ Hyprland fallback) + garden shell |
| Shells | Nushell, Starship, Zoxide | Nushell, Starship, Zoxide |
| Git suite | Full suite | Full suite |

## Host aspects

Each host has an aspect that defines its system-level configuration and declares
which other aspects it includes.

### Fern (primary workstation)

```nix
# modules/host-fern.nix
{ den, inputs, ... }:
{
  den.aspects.fern = {
    includes = [
      den.aspects.boot         # systemd-boot (UEFI x86 default)
      den.aspects.workstation  # role: core, nh, users, greetd, fonts, audio, docker, ...
      den.aspects.dev-machine  # role: c-cpp, rust, node-ts, localstack, aws-cli
      den.aspects.monitoring
      den.aspects.niri
      den.aspects.lmstudio
      den.aspects.teams
    ];

    # Forward user layers: fern's users get desktop + dev on top of
    # the base ada aspect.
    provides.to-users.includes = [
      den.aspects.ada-desktop
      den.aspects.ada-dev
    ];

    nixos = { pkgs, ... }: {
      imports = [ ../hosts/fern/hardware.nix ];

      boot.kernelPackages = pkgs.linuxPackages_zen;

      hardware.graphics.enable = true;
      programs.hyprland.enable = true;

      environment.systemPackages = with pkgs; [
        mesa-demos vulkan-tools firefox
      ];
    };
  };
}
```

The `includes` list composes **roles** (workstation, dev-machine) plus
fern-specific aspects. The `nixos` block contains configuration that only makes
sense for this specific machine: hardware imports, kernel choice, GPU setup,
and audio-device quirks. Fleet-wide defaults (timezone, trusted-users, nix-ld)
come from `core` via `mkDefault`.

### Moss (Apple Silicon)

```nix
# modules/host-moss.nix
{ den, inputs, ... }:
{
  den.aspects.moss = {
    includes = [
      den.aspects.boot-asahi
      den.aspects.core
      den.aspects.docker
      den.aspects.users
      den.aspects.audio
      den.aspects.graphics-asahi
      den.aspects.greetd
      den.aspects.secrets
      den.aspects.secrets-guard
    ];

    provides.to-users.includes = [
      den.aspects.ada-desktop
      den.aspects.ada-dev
    ];

    nixos = {
      imports = [
        ../hosts/moss/hardware.nix
        inputs.nixos-apple-silicon.nixosModules.apple-silicon-support
      ];
    };
  };
}
```

Moss includes fewer aspects -- no dev toolchains, no cloud tools, no gaming. It
uses `boot-asahi` and `graphics-asahi` instead of the x86-specific equivalents.

## Shared vs divergent

Both hosts include `core`, `audio`, `users`, `docker`, `greetd`, and
`secrets-guard`. The divergence is in:

- **Boot**: fern uses the `boot` aspect (systemd-boot) + Zen kernel; moss uses
  the `boot-asahi` aspect
- **GPU**: fern enables Mesa/AMDGPU inline; moss uses the `graphics-asahi`
  aspect
- **Dev tools**: only fern includes `rust`, `c-cpp`, `node-ts`, cloud CLIs
- **Desktop apps**: only fern includes `lmstudio`, `teams`

User-level configuration is layered: the base aspect (`modules/user-ada.nix` —
cli, git, shells) applies to `ada` on every machine, while each host forwards
the `ada-desktop` and `ada-dev` layers via `provides.to-users` (the mutual
provider). A future headless host would forward neither, keeping its `ada`
minimal.

## How den resolves the pipeline

When you run `nixos-rebuild switch --flake .#fern`:

1. Den reads the topology: fern is x86_64-linux with user ada
2. Den evaluates `den.aspects.fern` and recursively resolves all its `includes`
3. Each included aspect's `nixos` side is collected into the NixOS configuration
4. The mutual provider forwards each aspect's `homeManager` side to user ada
5. Den evaluates `den.aspects.ada` (the user aspect) and its includes
6. All `homeManager` sides merge into ada's Home Manager configuration
7. Flake-parts emits the final `nixosConfigurations.fern`

## Key files

| File | Purpose |
|------|---------|
| `modules/hosts.nix` | Topology declaration |
| `modules/host-fern.nix` | Fern host aspect and includes |
| `modules/host-moss.nix` | Moss host aspect and includes |
| `modules/roles/` | Role bundles composed by host aspects |
| `modules/user-ada.nix` | User ada base layer |
| `modules/user-ada-desktop.nix` | Desktop layer (forwarded by GUI hosts) |
| `modules/user-ada-dev.nix` | Dev-toolchain layer (forwarded per host) |
| `hosts/fern/hardware.nix` | Fern hardware (auto-generated) |
| `hosts/moss/hardware.nix` | Moss hardware (auto-generated) |
