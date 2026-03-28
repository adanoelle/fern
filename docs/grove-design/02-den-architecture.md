# Grove Design: Den Architecture

## Overview

Grove uses [den](https://github.com/vic/den), an aspect-oriented NixOS
configuration framework built on
[flake-aspects](https://github.com/vic/flake-aspects). This document explains
the den pattern and how grove will be structured.

## What is the Dendritic Pattern?

The dendritic pattern (formalized by
[mightyiam](https://github.com/mightyiam/dendritic)) has one core rule: **every
.nix file (except flake.nix) is a flake-parts module**. This eliminates the
question "what kind of Nix file is this?" — the answer is always the same.

Key principles:

1. **Feature-oriented, not class-oriented** — never create `nixos/`,
   `home-manager/`, `darwin/` directories. One file per feature, spanning all
   configuration classes.
2. **Auto-import** — since all files are the same type, they are bulk-imported
   by [import-tree](https://github.com/vic/import-tree).
3. **No specialArgs** — values shared through `let` bindings and flake-parts
   options, never through `specialArgs`.

## What Den Adds

Den is a framework built on top of the dendritic pattern. It adds:

### Aspects

The central abstraction. An aspect is a named feature that declares its behavior
across multiple Nix "classes" (nixos, darwin, homeManager, etc.) in one place:

```nix
den.aspects.desktop = {
  nixos = { pkgs, ... }: {
    programs.hyprland.enable = true;
    services.pipewire.enable = true;
  };
  homeManager = { pkgs, ... }: {
    programs.ghostty.enable = true;
  };
  includes = [ den.aspects.audio den.aspects.fonts ];
  provides.nvidia = {
    nixos = { config, ... }: {
      hardware.nvidia.modesetting.enable = true;
    };
  };
};
```

### Context-Driven Dispatch (replaces mkIf)

Aspect functions declare what context they need via argument patterns. They only
run when that context exists:

```nix
den.aspects.tools.includes = [
  # Only runs when both host AND user context exist
  ({ host, user, ... }: { nixos.time.timeZone = "UTC"; })
  # Only runs when host context exists
  ({ host, ... }: { nixos.networking.hostName = host.hostName; })
];
```

No `mkIf`, no `mkEnableOption`, no enable flags at the composition level. The
context shape _is_ the condition.

### Context Pipeline

Den transforms entity declarations through a pipeline:

1. **Host context** — resolves the host's aspect
2. **User context** — for each user, resolves user aspects with both host and
   user in context
3. **Derived contexts** — Home Manager, WSL, etc. activate automatically
4. **Final output** — collected into `nixosConfigurations`, etc.

### Provides (Sub-aspects)

Aspects can expose named sub-features scoped within the parent:

```nix
den.aspects.desktop.provides.nvidia = { ... };
den.aspects.desktop.provides.asahi = { ... };
den.aspects.desktop.provides.igpu = { ... };
```

These are applied selectively in host aspects via includes.

### Batteries

Den ships reusable built-in aspects:

- `den.provides.hostname` — sets `networking.hostName` from host entity
- `den.provides.define-user` — auto-creates OS user accounts
- `den.provides.primary-user` — adds wheel/networkmanager groups
- `den.provides.user-shell` — parametric, e.g.,
  `(den.provides.user-shell "nushell")`
- `den.provides.mutual-provider` — enables cross-entity configuration

## Grove Repository Structure

```
grove/
├── flake.nix                   # minimal — den + flake-parts + import-tree
├── flake.lock
│
├── modules/                    # every file is a flake-parts module (auto-imported)
│   │
│   ├── hosts.nix               # all host/user declarations (one-liners)
│   ├── defaults.nix            # den.default — shared baseline for all hosts
│   │
│   ├── # ── Shared aspects (features) ──
│   ├── base.nix                # nix daemon, experimental features, garbage collection
│   ├── networking.nix          # shared networking config
│   ├── secrets.nix             # sops-nix integration
│   ├── docker.nix              # container runtime
│   ├── monitoring.nix          # system monitoring
│   │
│   ├── # ── User aspects ──
│   ├── users/
│   │   └── ada.nix             # den.aspects.ada — user config, git, identities
│   │
│   ├── # ── Desktop aspects ──
│   ├── desktop/
│   │   ├── default.nix         # hyprland/niri, audio, fonts, greetd
│   │   ├── nvidia.nix          # provides.nvidia GPU config
│   │   ├── asahi.nix           # provides.asahi GPU config
│   │   ├── igpu.nix            # provides.igpu (Intel/AMD integrated)
│   │   └── frond.nix           # frond shell integration (quickshell + niri + control plane)
│   │
│   ├── # ── Laptop aspects ──
│   ├── laptop.nix              # TLP, power mgmt, wifi, bluetooth, lid switch
│   │
│   ├── # ── Server aspects ──
│   ├── server/
│   │   ├── default.nix         # ssh hardening, firewall baseline
│   │   ├── caddy.nix           # reverse proxy + ACME
│   │   ├── gitea.nix           # git forge
│   │   └── personal-site.nix   # personal website
│   │
│   ├── # ── Storage aspects ──
│   ├── storage/
│   │   ├── zfs.nix             # ZFS pools, snapshots, scrubs
│   │   └── samba.nix           # network file sharing
│   │
│   ├── # ── Dev toolchain aspects ──
│   ├── devtools/
│   │   ├── default.nix         # den.aspects.devtools aggregator (includes all provides)
│   │   ├── rust.nix            # den.aspects.devtools.provides.rust
│   │   ├── node-ts.nix         # den.aspects.devtools.provides.node-ts
│   │   ├── python.nix          # den.aspects.devtools.provides.python
│   │   ├── c.nix               # den.aspects.devtools.provides.c
│   │   └── ada-lang.nix        # den.aspects.devtools.provides.ada-lang
│   │
│   ├── # ── Per-host aspects (just includes lists) ──
│   ├── hosts/
│   │   ├── fern.nix            # ms-a2 dev workstation
│   │   ├── moss.nix            # asahi laptop
│   │   ├── oak.nix             # future services machine
│   │   └── nas.nix             # future storage machine
│   │
│   └── vm.nix                  # test VM support
│
├── hardware/                   # hardware-configuration.nix per host (NOT auto-imported)
│   ├── fern.nix
│   └── moss.nix
│
└── secrets/                    # sops-encrypted secrets
    └── ...
```

## Key Files Explained

### modules/hosts.nix — Entity Declarations

```nix
# One line per host+user combination. This is the complete topology.
{
  den.hosts.x86_64-linux.fern.users.ada = {};
  den.hosts.aarch64-linux.moss.users.ada = {};
  den.hosts.x86_64-linux.oak.users.ada = {};
  # den.hosts.x86_64-linux.nas.users.ada = {};   # uncomment when ready
}
```

### modules/defaults.nix — Global Baseline

```nix
{ den, ... }: {
  den.default = {
    nixos.system.stateVersion = "25.11";
    homeManager.home.stateVersion = "25.11";
  };
  den.default.includes = [
    den.provides.hostname
    den.provides.define-user
    den.provides.primary-user
    den.aspects.base
  ];
}
```

### modules/hosts/fern.nix — Per-Host Aspect

```nix
{ den, ... }: {
  den.aspects.fern = {
    includes = [
      den.aspects.desktop
      den.aspects.desktop.provides.igpu    # MS-A2 has AMD integrated
      den.aspects.frond                     # quickshell + niri
      den.aspects.devtools                  # all toolchains (or pick individually below)
      # den.aspects.devtools.provides.rust  # alternative: just Rust
      den.aspects.docker
      den.aspects.server                    # gitea, personal site on this machine too
    ];
    nixos = { ... }: {
      # fern-specific NixOS config (if any beyond what aspects provide)
    };
  };
}
```

### modules/hosts/moss.nix — Per-Host Aspect

```nix
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

## Aggregator Aspects (provides as sub-features)

Some aspects serve as aggregators — they group related sub-features via
`provides`. This replaces the old fern pattern of aggregator modules that
import sub-files.

### Example: devtools

```nix
# modules/devtools/default.nix — the aggregator
{ den, ... }: {
  den.aspects.devtools = {
    # Including devtools gives you ALL toolchains
    includes = [
      den.aspects.devtools.provides.rust
      den.aspects.devtools.provides.node-ts
      den.aspects.devtools.provides.python
      den.aspects.devtools.provides.c
    ];
  };
}

# modules/devtools/rust.nix — a single toolchain
{ den, ... }: {
  den.aspects.devtools.provides.rust = {
    nixos = { pkgs, ... }: {
      # system-level Rust packages
    };
    homeManager = { pkgs, ... }: {
      # user-level Rust tools (cargo, rustfmt, clippy, etc.)
    };
  };
}
```

Hosts can include the whole bundle or pick selectively:

```nix
# Dev workstation — everything
den.aspects.fern.includes = [ den.aspects.devtools ];

# Server — just Rust (for building frond control plane, etc.)
den.aspects.oak.includes = [ den.aspects.devtools.provides.rust ];
```

This same pattern applies to other aggregator-style aspects:

- **`desktop`** uses `provides` for GPU variants: `.provides.nvidia`,
  `.provides.asahi`, `.provides.igpu`
- **`server`** could use `provides` for individual services: `.provides.gitea`,
  `.provides.caddy`
- **`storage`** could use `provides` for storage backends: `.provides.zfs`,
  `.provides.samba`

The key benefit over fern's aggregator pattern: **selective inclusion without
enable flags**. In fern, `devtools.nix` imports everything and you use boolean
options to toggle pieces. In grove, inclusion _is_ enablement.

## How Composition Works (No mkIf)

In the old fern repo, conditional configuration used `mkIf` and enable flags:

```nix
# OLD: fern pattern
config = lib.mkIf cfg.enable { ... };
options.programs.gitSuite.enableGithub = mkOption { ... };
```

In grove, composition is structural:

- **Host gets a feature:** add it to the host aspect's `includes`
- **Host doesn't get a feature:** don't include it
- **Feature needs sub-features:** the aspect declares `includes` of its own
- **Hardware variant:** use `provides` sub-aspects

No boolean flags. No `mkIf`. The aspect graph _is_ the configuration.

## Dependencies (flake inputs)

Grove's flake.nix will need these inputs:

| Input | URL | Purpose |
|-------|-----|---------|
| `nixpkgs` | `github:NixOS/nixpkgs/nixos-unstable` | Base packages |
| `den` | `github:vic/den` | Den framework |
| `flake-aspects` | `github:vic/flake-aspects` | Aspect composition (den dep) |
| `flake-parts` | `github:hercules-ci/flake-parts` | Flake organization |
| `import-tree` | `github:vic/import-tree` | Auto-import modules |
| `home-manager` | `github:nix-community/home-manager` | User environment (follows nixpkgs) |
| `frond` | `github:adanoelle/frond` | Desktop shell (follows nixpkgs, rust-overlay) |
| `rust-overlay` | `github:oxalica/rust-overlay` | Rust toolchain (follows nixpkgs) |
| `sops-nix` | `github:Mic92/sops-nix` | Secret management (follows nixpkgs) |
| `nixos-apple-silicon` | `github:tpwrules/nixos-apple-silicon` | Asahi support (follows nixpkgs) |
| `claude-code` | `github:ryoppippi/claude-code-overlay` | Claude Code (follows nixpkgs) |

Inputs no longer needed (from old fern repo):
- `zig-overlay` — remove unless actively using Zig
- `devenv` — evaluate if still needed
- `flake-utils` — den/flake-parts handles this
- `claude-desktop` — evaluate if still needed

## Key Differences from Old Fern Repo

| Dimension | fern (old) | grove (new) |
|-----------|-----------|-------------|
| Organization | By class (`nix/modules/`, `nix/home/`) | By feature (`modules/desktop/`, `modules/server/`) |
| File type | Mix of NixOS modules, HM modules, configs | Every file is a flake-parts module |
| Host definition | Explicit import lists (20+ lines) | One-liner in `hosts.nix` + aspect includes |
| Module registration | Manual in `flake.parts/20-nixos-mods.nix` | Auto-import via `import-tree` |
| Conditional config | `mkIf`, `mkEnableOption`, enable flags | Context dispatch, aspect includes |
| Adding a host | Create `hosts/dir/`, copy imports, adjust | 1 line in `hosts.nix` + 1 aspect file |
| NixOS + HM co-location | Separate directories | Same file per feature |
| Feature dependencies | Implicit (you remember) | Explicit (`includes = [...]`) |
