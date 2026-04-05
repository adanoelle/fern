# Topology & Hosts

> Den's topology declares which machines exist, what architecture they run, and
> which users live on each. Host aspects then define what each machine includes.

## The topology

The entire host/user structure is declared in three lines:

```nix
# modules/hosts.nix
{ ... }:
{
  den.hosts.x86_64-linux.fern.users.ada = {};
  den.hosts.aarch64-linux.moss.users.ada = {};
}
```

The path structure is `den.hosts.<system>.<hostname>.users.<username>`. Den uses
this to:

1. Generate `nixosConfigurations.fern` and `nixosConfigurations.moss` as flake
   outputs
2. Set the correct `system` (architecture) for each host's package set
3. Wire Home Manager for each declared user on each host
4. Resolve which aspects apply to which host/user combination

## The two hosts

| Property | fern | moss |
|----------|------|------|
| Architecture | x86_64-linux | aarch64-linux |
| GPU | AMD (Mesa/AMDGPU) | Apple Silicon (Asahi) |
| Boot | systemd-boot + Zen kernel | systemd-boot |
| Gaming | Steam, Gamescope, GameMode | Not included |
| Cloud tools | AWS, Azure, LocalStack | Not included |
| Dev toolchains | Rust, C/C++, TypeScript | Not included |
| Desktop | Hyprland + Fern Shell | Hyprland + Fern Shell |
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
      den.aspects.core
      den.aspects.audio
      den.aspects.monitoring
      den.aspects.users
      den.aspects.secrets-guard
      den.aspects.greetd
      den.aspects.fonts
      den.aspects.docker
      den.aspects.c-cpp
      den.aspects.localstack
      den.aspects.rust
      den.aspects.node-ts
      den.aspects.aws-cli
      den.aspects.azure-cli
      den.aspects.lmstudio
      den.aspects.teams
      den.aspects.vscode
      den.aspects.sqlserver
    ];

    nixos = { pkgs, lib, ... }: {
      imports = [ ../hosts/fern/hardware.nix ];

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.kernelPackages = pkgs.linuxPackages_zen;

      hardware.graphics.enable = true;
      programs.hyprland.enable = true;

      environment.systemPackages = with pkgs; [
        mesa-demos vulkan-tools firefox
      ];

      nix.settings.trusted-users = [ "root" "ada" ];
      time.timeZone = "America/New_York";
    };
  };
}
```

The `includes` list pulls in shared aspects (core, audio, docker) and
fern-specific ones (cloud tools, dev toolchains, desktop apps). The `nixos`
block contains configuration that only makes sense for this specific machine:
hardware imports, boot loader, GPU setup, and timezone.

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

    nixos = { pkgs, ... }: {
      imports = [
        ../hosts/moss/hardware.nix
        inputs.nixos-apple-silicon.nixosModules.apple-silicon-support
      ];

      programs.nix-ld.enable = true;
      nix.settings.trusted-users = [ "root" "ada" ];
      time.timeZone = "America/New_York";
    };
  };
}
```

Moss includes fewer aspects -- no dev toolchains, no cloud tools, no gaming. It
uses `boot-asahi` and `graphics-asahi` instead of the x86-specific equivalents.

## Shared vs divergent

Both hosts include `core`, `audio`, `users`, `docker`, `greetd`, and
`secrets-guard`. The divergence is in:

- **Boot**: fern uses systemd-boot + Zen kernel inline; moss uses the
  `boot-asahi` aspect
- **GPU**: fern enables Mesa/AMDGPU inline; moss uses the `graphics-asahi`
  aspect
- **Dev tools**: only fern includes `rust`, `c-cpp`, `node-ts`, cloud CLIs
- **Desktop apps**: only fern includes `lmstudio`, `teams`, `vscode`,
  `sqlserver`

User-level configuration (cli, git, shells, desktop) is handled by the user
aspect (`modules/user-ada.nix`), which applies to `ada` on both machines via the
mutual provider.

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
| `modules/user-ada.nix` | User ada aspect and includes |
| `hosts/fern/hardware.nix` | Fern hardware (auto-generated) |
| `hosts/moss/hardware.nix` | Moss hardware (auto-generated) |
