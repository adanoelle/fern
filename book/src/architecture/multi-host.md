# Multi-Host Design

> Fern supports two machines -- fern (x86_64/NVIDIA) and moss (aarch64/Apple
> Silicon) -- sharing most modules but diverging on hardware-specific
> configuration.

## The two hosts

| Property     | fern                             | moss                               |
| ------------ | -------------------------------- | ---------------------------------- |
| Architecture | x86_64-linux                     | aarch64-linux                      |
| GPU          | NVIDIA (production driver)       | Apple Silicon (Asahi experimental) |
| Boot         | GRUB + Zen kernel                | systemd-boot                       |
| Gaming       | Steam, Gamescope, GameMode       | Not enabled                        |
| Cloud tools  | AWS, Azure, LocalStack           | Not enabled                        |
| Dev IDEs     | VS Code, Cursor, LM Studio       | Not enabled                        |
| Desktop      | Hyprland + Fern Shell            | Hyprland + Fern Shell              |
| Shells       | Nushell, Starship, Zoxide        | Nushell, Starship, Zoxide          |
| Git suite    | Full (identities, safety, tools) | Full (identities, safety, tools)   |

## Shared vs divergent modules

Both hosts share the same Home Manager configuration (all six module groups:
cli, git, desktop, devtools, shells, workspace). The desktop environment,
editor, shell, and Git workflow are identical across machines.

The divergence is entirely at the NixOS system module level:

**Shared system modules** (used by both hosts):

- `core` -- Nix settings, garbage collection
- `users` -- User account, NetworkManager, SSH
- `audio` -- PipeWire
- `greet` -- Display manager
- `secrets` -- SOPS-nix
- `guard` -- git-secrets, trufflehog
- `docker` -- Container runtime

**Fern-only modules:**

- `boot` (GRUB + Zen kernel)
- `graphics` (NVIDIA)
- `c-dev`, `rust-dev`, `typescript` (dev toolchains)
- `gaming` (Steam, Gamescope)
- `aws`, `azure-cli`, `localstack` (cloud)
- `claude`, `cursor`, `vscode`, `lmstudio`, `teams`, `sqlserver` (desktop apps)

**Moss-only modules:**

- `boot-asahi` (systemd-boot)
- `graphics-asahi` (Asahi GPU)
- `nixos-apple-silicon` support module (from input)

## How it works in flake.parts

`40-hosts.nix` defines both configurations using `withSystem` to set the correct
architecture:

```nix
flake.nixosConfigurations.fern =
  withSystem "x86_64-linux"
    ({ pkgs, system, ... }:
      inputs.nixpkgs.lib.nixosSystem {
        inherit pkgs system;
        modules = [
          ../hosts/fern/hardware.nix
          ../hosts/fern/configuration.nix
          inputs.home-manager.nixosModules.default
          inputs.fern.nixosModules.fern-shell
          inputs.fern.nixosModules.fern-fonts
        ];
        specialArgs = { inherit self inputs; };
      });
```

Each host's `configuration.nix` then selects which `self.nixosModules.*` to
import.

## Adding a third host

1. Create `hosts/newhost/configuration.nix` and `hardware.nix`
2. Add a new entry in `flake.parts/40-hosts.nix` using `withSystem`
3. In `configuration.nix`, import the shared modules you want and add
   host-specific ones
4. If the architecture is new (neither x86_64 nor aarch64), add it to the
   `systems` list in `10-core.nix`
5. Build with `nixos-rebuild test --flake .#newhost`

The Home Manager modules are architecture-independent, so the same
`self.homeModules.*` imports work on any host.

## Key files

| File                           | Purpose                                    |
| ------------------------------ | ------------------------------------------ |
| `flake.parts/40-hosts.nix`     | Host definitions with `withSystem`         |
| `hosts/fern/configuration.nix` | Fern module imports and settings           |
| `hosts/moss/configuration.nix` | Moss module imports and settings           |
| `hosts/*/hardware.nix`         | Machine-specific hardware (auto-generated) |
