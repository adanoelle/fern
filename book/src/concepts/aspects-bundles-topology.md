# Aspects, Bundles & Topology

> Den replaces hand-rolled option trees and import registries with three
> primitives: aspects (units of configuration), bundles (composition of
> aspects), and topology (host/user wiring).

This page introduces the [vic/den](https://github.com/vic/den) framework
vocabulary used throughout this configuration. If you are new to den, read this
before the Architecture section.

## What is an aspect?

An aspect is the den equivalent of a NixOS module, but with two key differences:

1. **No registration step.** Aspects are discovered automatically by
   `import-tree` -- placing a `.nix` file in the `modules/` tree is enough.
2. **Dual-sided by default.** A single aspect can provide both NixOS system
   configuration and Home Manager user configuration, eliminating the need for
   separate `nix/modules/` and `nix/home/` directories.

A minimal aspect looks like this:

```nix
# modules/audio.nix
{ den, ... }:
{
  den.aspects.audio.nixos = { pkgs, ... }: {
    services.pipewire.enable = true;
    environment.systemPackages = [ pkgs.pavucontrol ];
  };
}
```

The key structure is `den.aspects.<name>.<side>`, where `<side>` is `nixos`
(system configuration) or `homeManager` (user configuration). Many aspects use
only one side -- the audio stack is purely system-level, while bat is purely
user-level:

```nix
# modules/cli/bat.nix
{ den, ... }:
{
  den.aspects.bat.homeManager = { pkgs, ... }: {
    home.packages = [ pkgs.bat ];
    home.sessionVariables.MANPAGER = "sh -c 'col -bx | bat -l man -p'";
  };
}
```

Some aspects use both sides. The Hyprland aspect, for example, provides Home
Manager configuration (keybindings, theme, wallpaper) while the host aspect
enables the Wayland compositor at the system level.

## What is a bundle?

A bundle is an aspect that composes other aspects via `includes` without adding
configuration of its own (or with minimal orchestration logic). Bundles replace
the old aggregator modules that listed explicit imports.

```nix
# modules/cli/bundle.nix
{ den, ... }:
{
  den.aspects.cli = {
    includes = [
      den.aspects.bat
      den.aspects.broot
      den.aspects.ghostty
      den.aspects.helix
      # ... 13 aspects total
    ];
  };
}
```

When a host or user includes `den.aspects.cli`, all 13 sub-aspects activate.
Bundles give you one handle to grab a group of related functionality.

Some bundles also carry orchestrator logic. The git suite bundle defines
`programs.gitSuite` options and wires them to the sub-aspects it includes:

```nix
# modules/git/bundle.nix (simplified)
{ den, ... }:
{
  den.aspects.git-suite = {
    includes = [
      den.aspects.git-core
      den.aspects.git-aliases
      den.aspects.git-identities
      # ... 13 sub-aspects
    ];

    homeManager = { config, lib, ... }:
    let cfg = config.programs.gitSuite;
    in {
      options.programs.gitSuite = {
        enable = lib.mkEnableOption "Complete Git suite";
        userName = lib.mkOption { type = lib.types.str; default = "adanoelle"; };
        # ...
      };
      config = lib.mkIf cfg.enable {
        programs.gitCore.enable = true;
        programs.gitAliases.enable = true;
        # ...
      };
    };
  };
}
```

## What is topology?

Topology is den's way of declaring which hosts exist, what architecture they
run, and which users live on each host. The entire topology for this
configuration fits in three lines:

```nix
# modules/hosts.nix
{ ... }:
{
  den.hosts.x86_64-linux.fern.users.ada = {};
  den.hosts.aarch64-linux.moss.users.ada = {};
}
```

This tells den:
- There is an x86_64 host called `fern` with a user called `ada`
- There is an aarch64 host called `moss` with a user called `ada`

Den uses the topology to generate `nixosConfigurations.fern` and
`nixosConfigurations.moss` as flake outputs, wire Home Manager to each host for
the declared users, and resolve which aspects apply where.

## How includes replace enable flags

In the old architecture, you imported a module and then set `enable = true` to
activate it. Many modules existed in the evaluation even when disabled.

Den uses **includes** instead: an aspect only participates in evaluation when
something includes it. The host aspect includes the aspects it needs:

```nix
# modules/host-fern.nix (simplified)
{ den, ... }:
{
  den.aspects.fern = {
    includes = [
      den.aspects.core
      den.aspects.audio
      den.aspects.docker
      den.aspects.rust
      # ...
    ];
    nixos = { ... }: { /* host-specific config */ };
  };
}
```

The user aspect does the same for user-level bundles:

```nix
# modules/user-ada.nix (simplified)
{ den, ... }:
{
  den.aspects.ada = {
    includes = [
      den.aspects.cli
      den.aspects.git-suite
      den.aspects.desktop-apps
      den.aspects.shells
    ];
    homeManager = { ... }: { /* user-specific config */ };
  };
}
```

Aspects that are not included by any host or user are simply not evaluated. No
enable flags needed.

## Aspect naming conventions

| Pattern | Meaning | Example |
|---------|---------|---------|
| `den.aspects.<tool>` | Single-tool aspect | `den.aspects.bat`, `den.aspects.rust` |
| `den.aspects.<category>` | Bundle aspect | `den.aspects.cli`, `den.aspects.shells` |
| `den.aspects.<prefix>-<tool>` | Namespaced sub-aspect | `den.aspects.git-core`, `den.aspects.git-aliases` |
| `den.aspects.<hostname>` | Host aspect | `den.aspects.fern`, `den.aspects.moss` |
| `den.aspects.<username>` | User aspect | `den.aspects.ada` |

## How den differs from raw NixOS modules

| Concern | Raw NixOS modules | Den aspects |
|---------|-------------------|-------------|
| Discovery | Manual import lists | Automatic via `import-tree` |
| Registration | `flake.nixosModules.*` | None needed |
| Activation | `enable = true` flags | `includes` in host/user aspects |
| NixOS + HM | Separate file trees | Single file, dual sides |
| Host wiring | `specialArgs`, `withSystem` | `den.hosts` topology |
| Composition | Aggregator files with `imports` | Bundles with `includes` |

## Key files

| File | Purpose |
|------|---------|
| `modules/dendritic.nix` | Den bootstrap and Home Manager bridge |
| `modules/hosts.nix` | Topology: hosts, architectures, users |
| `modules/defaults.nix` | Global defaults applied to all hosts |
| `modules/cli/bundle.nix` | Example pure bundle (no extra logic) |
| `modules/git/bundle.nix` | Example orchestrator bundle |
| `modules/audio.nix` | Example single-side aspect (nixos only) |
| `modules/cli/bat.nix` | Example single-side aspect (homeManager only) |
