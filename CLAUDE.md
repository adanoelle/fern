# 🤖 Claude Code Context - Fern NixOS Configuration

## Project Overview

A multi-machine NixOS configuration built on the **dendritic pattern**:
flake-parts + [import-tree](https://github.com/vic/import-tree) +
[den](https://github.com/vic/den). Every file under `modules/` is a
flake-parts module, auto-imported — there is no central import list.
Configuration is expressed as **den aspects** composed onto hosts and users.

Current machines:

- **fern** — x86_64 desktop workstation (AMD, Niri/Hyprland, pro audio, dev)
- **moss** — Apple Silicon laptop (Asahi) — parked: hardware.nix is still
  the installer placeholder and some aspects pull x86_64-only packages;
  see the comment in modules/hosts.nix

Planned: homelab server, dedicated gaming machine. The `modules/roles/`
layer exists so those become "hardware file + role + quirks".

## Quick Commands

```bash
# All common operations are available via just (inside devShell)
just              # list all recipes
just switch       # rebuild and switch (via nh)
just test         # test without switching (via nh)
just test-trace   # test with --show-trace
just dry          # dry-build only
just rollback     # rollback to previous generation
just update       # update flake inputs
just fmt          # format Nix files (nixfmt)
just check        # nix flake check
just lint         # fmt + check + statix + deadnix
just gc           # smart garbage-collect (nh clean)
just diff-gen     # diff last two system generations
just book-serve   # mdBook docs with live reload
direnv allow      # one-time; devShell auto-activates via .envrc
```

## Directory Structure

```
fern/
├── CLAUDE.md            # This file
├── flake.nix            # Inputs + mkFlake over (import-tree ./modules)
├── flake.lock           # Pinned dependencies (only touch via nix flake update)
├── justfile             # Command recipes (primary interface)
├── hosts/               # ONLY hardware-configuration files
│   ├── fern/hardware.nix
│   └── moss/hardware.nix
├── modules/             # Everything else — every .nix here is auto-imported
│   ├── dendritic.nix    # den bootstrap (mutual-provider, hm bridge, schema)
│   ├── hosts.nix        # Topology: den.hosts.<system>.<name>.users.<user>
│   ├── defaults.nix     # den.default — applied to all hosts/users
│   ├── core.nix         # Nix settings + fleet-wide defaults (mkDefault)
│   ├── host-fern.nix    # Host aspect: roles + user layers + hardware quirks
│   ├── host-moss.nix    # Host aspect for the Asahi laptop
│   ├── user-ada.nix     # User BASE layer (safe on any host, even headless)
│   ├── user-ada-desktop.nix  # User desktop layer (forwarded by GUI hosts)
│   ├── user-ada-dev.nix      # User dev-toolchain layer
│   ├── roles/           # Host role bundles: workstation, server, dev-machine
│   ├── boot.nix         # systemd-boot (UEFI x86 default); asahi/ has its own
│   ├── cli/ desktop/ devtools/ git/ shells/ ...  # aspect modules by category
│   └── */bundle.nix     # Category bundles (den.aspects.cli, devtools, …)
├── book/                # mdBook documentation
└── secrets/             # SOPS-encrypted secrets (edit only via sops)
```

## The Dendritic Pattern Here

### Aspects

Every unit of configuration is an aspect with optional per-class sides:

```nix
# modules/category/thing.nix
{ den, ... }:
{
  den.aspects.thing = {
    includes = [ den.aspects.other ];          # compose aspects
    nixos = { pkgs, ... }: { ... };            # system side
    homeManager = { pkgs, ... }: { ... };      # user side
  };
}
```

New module = new file under `modules/` — import-tree picks it up
automatically. Paths with a `_`-prefixed component (e.g.
`desktop/_hyprland/`) are NOT auto-imported; they're helpers imported
explicitly by a parent module.

### Topology and layering

- `modules/hosts.nix` declares machines and their users. A user named
  `ada` gets `den.aspects.ada` automatically.
- Host aspects (`host-*.nix`) compose **roles** from `modules/roles/`
  plus hardware-specific config, and forward extra user layers via
  `provides.to-users.includes` (enabled by `den._.mutual-provider` in
  `dendritic.nix`). This is how the same user gets a desktop on fern
  but would stay minimal on a server.
- User aspects are layered: `ada` (base, machine-agnostic) ←
  `ada-desktop`, `ada-dev` (forwarded per-host). Keep it that way:
  never add GUI or toolchain config to the base layer.
- Fleet-wide defaults live in `core.nix` with `lib.mkDefault` so hosts
  can override; per-machine facts (kernel, udev rules, sensors chip)
  live in the host aspect.

### Naming conventions

- Aspect files: `modules/category/name.nix`, dash-separated
  (`claude-code.nix`). Aspect name matches file name.
- `ada-*` aspect names are reserved for user layers; the Ada language
  toolchain is `ada-lang` (modules/devtools/ada.nix).
- Category bundles are `bundle.nix` defining `den.aspects.<category>`.

## Adding Things

### A new module/aspect

1. Create `modules/category/name.nix` defining `den.aspects.name`
2. Include it from a bundle, role, or host aspect
3. `just check`, `just test`, commit

### A new machine

1. Generate `hosts/<name>/hardware.nix` on the machine
2. Add topology: `den.hosts.<system>.<name>.users.ada = { };`
3. Create `modules/host-<name>.nix`: hardware import + boot aspect +
   role (+ `provides.to-users` layers if graphical)
4. Pin `system.stateVersion` for the new host at the current release
5. Register the host as a sops recipient BEFORE the first build with the
   `secrets` aspect (activation fails loudly otherwise):
   `ssh-keyscan -t ed25519 <host> | ssh-to-age`, add the `&host_<name>`
   anchor + rule to `.sops.yaml`, then `sops updatekeys secrets/*.yaml`

## Safety Rules

### ⚠️ CRITICAL - Always Follow

1. **NEVER** modify `hosts/*/hardware.nix` by hand
2. **NEVER** work directly in the main branch - use worktrees
3. **ALWAYS** run `nix flake check` before rebuilding
4. **ALWAYS** test with `just test` before `just switch`
5. **ALWAYS** format with `nixfmt` (`just fmt`) before committing
6. **NEVER** use `sudo` with git commands
7. **NEVER** edit files in `secrets/` directly - use sops
8. `flake.lock` changes only via `just update` / `nix flake update`

## Key Technologies

- **Compositor**: Niri (primary), Hyprland (fallback session)
- **Greeter**: greetd + tuigreet (regreet removed — GPU corruption)
- **Shell**: Fish (system) / Nushell; **Editor**: Helix; **Terminal**: Ghostty/Kitty
- **Theming**: garden-shell palette (`garden.terminal` aspect namespace)
- **Audio**: PipeWire + musnix low-latency (studio hardware on fern)
- **Secrets**: sops-nix with age keys

## Troubleshooting

```bash
just test-trace                       # detailed eval/build errors
nix eval .#nixosConfigurations.fern.config.system.build.toplevel.drvPath
grep -rn "aspects.name" modules/      # find aspect definition + includers
just diff-gen                         # what changed between generations
```

Common gotchas:

- "option does not exist" for `programs.niri.*`: the niri-flake NixOS
  module is imported once at host level (host-fern.nix), not in the
  niri aspect — a new host using Niri needs that import too.
- Duplicate option declaration: an upstream NixOS module imported
  inside an aspect that's included twice. Import such modules once at
  the host level instead.
- User half-defined ("exactly one of isSystemUser/isNormalUser"): a
  system aspect touches `users.users.<name>` on a host that doesn't
  include the `users` aspect.

## When Working on This Project

1. Follow the aspect layering: base vs role vs host vs user layer
2. New config goes in the most-shared place it's correct for —
   hardware facts in host aspects, preferences in user layers
3. Test incrementally; keep commits atomic; conventional commits
   (feat, fix, docs, refactor, …)

---

_This file helps Claude understand your project. Keep it updated as
conventions evolve._
