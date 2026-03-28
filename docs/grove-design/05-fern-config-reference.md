# Grove Design: Fern Config Reference

## Overview

This document captures the exact configuration from the original `fern`
repository so that agents and developers can port it to grove without needing to
read the old repo. It serves as a reference during migration.

## Flake Inputs (from fern/flake.nix)

| Input | URL | Follows |
|-------|-----|---------|
| `nixpkgs` | `github:NixOS/nixpkgs/nixos-unstable` | — |
| `flake-parts` | `github:hercules-ci/flake-parts` | — |
| `flake-utils` | `github:numtide/flake-utils` | — |
| `home-manager` | `github:nix-community/home-manager` | nixpkgs |
| `fern` (fern-shell) | `github:adanoelle/fern-shell` | — |
| `devenv` | `github:cachix/devenv` | nixpkgs |
| `claude-desktop` | `github:k3d3/claude-desktop-linux-flake` | nixpkgs, flake-utils |
| `rust-overlay` | `github:oxalica/rust-overlay` | nixpkgs |
| `zig-overlay` | `github:mitchellh/zig-overlay` | nixpkgs |
| `sops-nix` | `github:Mic92/sops-nix` | nixpkgs |
| `nixos-apple-silicon` | `github:tpwrules/nixos-apple-silicon` | nixpkgs |
| `claude-code` | `github:ryoppippi/claude-code-overlay` | nixpkgs |

### Inputs to carry forward to grove

- `nixpkgs`, `home-manager`, `rust-overlay`, `sops-nix`, `claude-code`,
  `nixos-apple-silicon`
- Replace `fern` (fern-shell) with `frond`
- Add `den`, `flake-aspects`, `import-tree`

### Inputs to evaluate / potentially drop

- `flake-utils` — likely replaced by den/flake-parts
- `flake-parts` — kept, den uses it
- `devenv` — evaluate if still used
- `zig-overlay` — drop unless actively developing Zig
- `claude-desktop` — evaluate if still needed
- `fern-shell` modules (`fern-shell`, `fern-fonts`) — replaced by frond packages

## Overlays Applied (from flake.parts/10-core.nix)

```nix
# Applied to pkgs for all systems (x86_64-linux)
overlays = [
  inputs.rust-overlay.overlays.default
  inputs.zig-overlay.overlays.default
  inputs.claude-code.overlays.default
];
```

In grove, these will be applied via den's perSystem or similar mechanism. Drop
`zig-overlay` if not needed.

## NixOS Modules (from flake.parts/20-nixos-mods.nix)

Complete list of exported `nixosModules`:

| Module | Source File | Migrate? | Grove Aspect |
|--------|-----------|----------|-------------|
| `ada-dev` | `nix/modules/devtools/ada-toolchain.nix` | Evaluate | `devtools/ada-lang.nix` |
| `audio` | `nix/modules/audio.nix` | Yes | `desktop/default.nix` (audio section) |
| `aws` | `nix/modules/cloud/aws-cli.nix` | Later | `cloud/aws.nix` |
| `azure-cli` | `nix/modules/azure-cli.nix` | Later | `cloud/azure.nix` |
| `boot` | `nix/modules/boot.nix` | Yes | `base.nix` or `boot.nix` |
| `boot-asahi` | `nix/modules/boot-asahi.nix` | Phase 2 | `desktop/asahi.nix` |
| `core` | `nix/modules/core.nix` | Yes | `base.nix` |
| `c-dev` | `nix/modules/devtools/c-toolchain.nix` | Evaluate | `devtools/c.nix` |
| `claude` | `nix/modules/desktop/claude.nix` | Evaluate | `desktop/claude.nix` |
| `cursor` | `nix/modules/desktop/cursor.nix` | Evaluate | Drop or `desktop/editors.nix` |
| `docker` | `nix/modules/devtools/docker.nix` | Yes | `docker.nix` |
| `fonts` | `nix/modules/fonts.nix` | Yes | `desktop/default.nix` (fonts section) |
| `gaming` | `nix/modules/gaming.nix` | Later | `desktop/gaming.nix` |
| `graphics` | `nix/modules/graphics.nix` | Yes | `desktop/nvidia.nix` (provides) |
| `graphics-asahi` | `nix/modules/graphics-asahi.nix` | Phase 2 | `desktop/asahi.nix` (provides) |
| `greet` | `nix/modules/desktop/greetd.nix` | Yes | `desktop/default.nix` (greetd section) |
| `localstack` | `nix/modules/devtools/localstack.nix` | Evaluate | `cloud/localstack.nix` |
| `lmstudio` | `nix/modules/desktop/lmstudio.nix` | Evaluate | `desktop/ai.nix` |
| `monitoring` | `nix/modules/monitoring.nix` | Yes | `monitoring.nix` |
| `rust-dev` | `nix/modules/devtools/rust.nix` | Yes | `devtools/rust.nix` |
| `secrets` | `nix/modules/secrets.nix` | Yes | `secrets.nix` |
| `guard` | `nix/modules/secrets-guard.nix` | Yes | `secrets.nix` (merged) |
| `teams` | `nix/modules/desktop/teams.nix` | Evaluate | Drop or `desktop/work.nix` |
| `typescript` | `nix/modules/devtools/node-ts.nix` | Yes | `devtools/node-ts.nix` |
| `users` | `nix/modules/users.nix` | Yes | `users/ada.nix` or den.provides |
| `vscode` | `nix/modules/desktop/vscode.nix` | Evaluate | Drop or `desktop/editors.nix` |
| `sqlserver` | `nix/modules/desktop/sqlserver.nix` | Evaluate | `server/sqlserver.nix` |

## Home Manager Modules (from flake.parts/30-home-mods.nix)

| Module | Source | Submodules |
|--------|--------|------------|
| `cli` | `nix/home/cli.nix` | audio-tools, bat, broot, claude-code, crypt, delta, ghostty, glow, helix, hyfetch, nix-tree, prettier, tree |
| `git` | `nix/home/git/` | core, aliases, identities, github, tools, safety, help (feature-gated via `programs.gitSuite`) |
| `desktop` | `nix/home/desktop.nix` | chromium, gaming, hyprland, nyxt, obs, screenshot + hyprland submodules (bar, core, fern, hyprland, idlelock, wallpaper) |
| `devtools` | `nix/home/devtools.nix` | ada, cpp, csharp, gamedev, python, typescript, zig |
| `shells` | `nix/home/shells.nix` | devenv, nushell, starship, zoxide |
| `workspace` | `nix/home/workspace.nix` | XDG directories management |

### Migration notes for Home Manager modules

In grove, these are **co-located with their NixOS counterparts** in aspect
files. For example:

- `cli` tools → spread across relevant aspects (bat/delta go in `base.nix`,
  ghostty goes in `desktop/default.nix`, etc.)
- `git` suite → `users/ada.nix` (git is a user concern)
- `desktop` → `desktop/default.nix` + `desktop/frond.nix`
- `devtools` → `devtools/*.nix` (one per language)
- `shells` → `users/ada.nix` or `base.nix` (nushell, starship, zoxide)
- `workspace` → `users/ada.nix` (XDG is a user concern)

## Host: fern (x86_64 Desktop)

### NixOS imports (from hosts/fern/configuration.nix)

```
boot, core, c-dev, aws, azure-cli, cursor, claude, docker, lmstudio,
users, audio, gaming, graphics, monitoring, greet, localstack, rust-dev,
teams, typescript, secrets, guard, vscode, sqlserver, home-manager
```

Also imports from fern-shell flake:
- `inputs.fern.nixosModules.fern-shell`
- `inputs.fern.nixosModules.fern-fonts`

### Home Manager config for user ada

```nix
home-manager.users.ada = {
  imports = [ cli, git, desktop, devtools, shells, workspace ];
  home.stateVersion = "25.11";

  programs.gitSuite = {
    enable = true;
    userName = "adanoelle";
    userEmail = "adanoelleyoung@gmail.com";
    editor = "hx";
    enableGithub = true;
    enableTools = true;
    enableSafety = true;
    enableHelp = true;
  };

  programs.gitIdentities.identities = {
    personal = {
      name = "adanoelle";
      email = "adanoelleyoung@gmail.com";
      directory = "/home/ada/personal/";
      signingKey = "/home/ada/.ssh/github";
    };
    work = {
      name = "youngt0dd";
      email = "todd.young@pinnaclereliability.com";
      directory = "/home/ada/work/";
      signingKey = "/home/ada/.ssh/github-work";
    };
  };
};
```

### Grove equivalent for fern

```nix
# modules/hosts/fern.nix
{ den, ... }: {
  den.aspects.fern = {
    includes = [
      den.aspects.desktop
      den.aspects.desktop.provides.igpu   # AMD integrated on MS-A2
      den.aspects.frond
      den.aspects.devtools                  # all toolchains
      # or selectively:
      # den.aspects.devtools.provides.rust
      # den.aspects.devtools.provides.node-ts
      # den.aspects.devtools.provides.python
      # den.aspects.devtools.provides.c
      den.aspects.docker
      den.aspects.server                   # if running gitea etc. on fern
      # den.aspects.cloud-aws             # add when needed
      # den.aspects.cloud-azure           # add when needed
    ];
  };
}
```

## Host: moss (aarch64 Asahi Laptop)

### NixOS imports (from hosts/moss/configuration.nix)

```
hardware.nix, nixos-apple-silicon, boot-asahi, core, docker, users,
audio, graphics-asahi, greet, secrets, guard, home-manager
```

### Home Manager config

Same as fern (identical imports and git config).

### Grove equivalent for moss

```nix
# modules/hosts/moss.nix
{ den, ... }: {
  den.aspects.moss = {
    includes = [
      den.aspects.desktop
      den.aspects.desktop.provides.asahi
      den.aspects.frond
      den.aspects.laptop
      den.aspects.devtools                  # all toolchains
      den.aspects.docker
    ];
  };
}
```

## Git Suite Configuration (for reference)

The git suite in the old fern repo uses a feature-gated module pattern with
these options:

```nix
options.programs.gitSuite = {
  enable = mkEnableOption "Complete Git suite configuration";
  userName = mkOption { type = types.str; default = "adanoelle"; };
  userEmail = mkOption { type = types.str; default = "adanoelleyoung@gmail.com"; };
  editor = mkOption { type = types.str; default = "hx"; };
  enableGithub = mkOption { type = types.bool; default = true; };
  enableTools = mkOption { type = types.bool; default = true; };
  enableSafety = mkOption { type = types.bool; default = true; };
  enableHelp = mkOption { type = types.bool; default = true; };
};
```

Sub-modules: `core.nix`, `aliases.nix`, `identities.nix`, `github.nix`,
`tools.nix`, `safety.nix`, `help.nix`

### Grove migration approach

In grove, the git suite lives in `modules/users/ada.nix` as part of the ada
user aspect. The feature-gating (`enableGithub`, etc.) is replaced by aspect
composition — if a machine shouldn't have GitHub CLI, don't include that
sub-aspect. However, since all machines get the same git config for ada, this
can simply be a flat `homeManager` block in the ada aspect with everything
enabled.

```nix
# modules/users/ada.nix
{ den, ... }: {
  den.aspects.ada = {
    homeManager = { pkgs, ... }: {
      programs.git = {
        enable = true;
        userName = "adanoelle";
        userEmail = "adanoelleyoung@gmail.com";
        # ... full git config from core.nix, aliases.nix, etc.
      };
      programs.gh.enable = true;       # GitHub CLI
      programs.lazygit.enable = true;  # from tools.nix
      # ... starship, nushell, zoxide, bat, delta, helix, etc.
    };
  };
}
```
