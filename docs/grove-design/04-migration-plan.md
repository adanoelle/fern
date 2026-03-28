# Grove Design: Migration Plan

## Overview

This document outlines the phased plan for creating the grove repository and
migrating configuration from the old fern repo. The old fern repo will be
archived after grove is stable.

## Principles

1. **Build incrementally** — each phase adds one host and forces shared config
   to become proper aspects
2. **Start with real hardware** — the Minisforum MS-A2 (fern) is the first
   machine, so start there
3. **Don't migrate blindly** — use the migration as an opportunity to clean up,
   simplify, and drop unused config
4. **Keep fern repo working** — don't archive until grove is fully operational
5. **Test at every step** — `nix flake check`, `nixos-rebuild test`, VM testing

## Prerequisites

Before starting grove:

- [ ] Minisforum MS-A2 hardware available
- [ ] UniFi Dream Machine Pro set up with basic VLAN structure
- [ ] `adanoelle/grove` repository created on GitHub
- [ ] `adanoelle/frond` repository created on GitHub (rename from fern-shell or
  create fresh)
- [ ] Familiarize with den by reading the
  [den docs](https://github.com/vic/den) and running the default template:
  `nix flake init -t github:vic/den`

## Phase 1: Bootstrap Grove + Fern Host

**Goal:** Get fern (MS-A2) booting with a minimal den-based config.

### Steps

1. **Initialize grove repo**
   ```bash
   mkdir grove && cd grove
   nix flake init -t github:vic/den
   ```

2. **Set up flake.nix with all inputs**
   - nixpkgs, den, flake-parts, import-tree, home-manager
   - frond (with follows for nixpkgs, rust-overlay)
   - rust-overlay, sops-nix, claude-code
   - Do NOT add nixos-apple-silicon yet (not needed for fern)

3. **Create base aspects (ported from fern repo)**
   - `modules/base.nix` — from `nix/modules/core.nix`
     - Nix daemon config, experimental features, garbage collection
   - `modules/networking.nix` — new, basic networking
   - `modules/secrets.nix` — from `nix/modules/secrets.nix` + `secrets-guard.nix`
   - `modules/defaults.nix` — stateVersion, default includes

4. **Create fern host declaration**
   - `modules/hosts.nix` — `den.hosts.x86_64-linux.fern.users.ada = {};`
   - `modules/hosts/fern.nix` — aspect with includes for fern
   - `hardware/fern.nix` — generate fresh with `nixos-generate-config` on MS-A2

5. **Create user aspect**
   - `modules/users/ada.nix` — from fern's home-manager user config
   - Git suite configuration, identities, editor preferences

6. **Create desktop aspects**
   - `modules/desktop/default.nix` — audio, fonts, greetd, compositor base
   - `modules/desktop/igpu.nix` — AMD integrated graphics for MS-A2
   - `modules/desktop/frond.nix` — frond integration aspect

7. **Create dev toolchain aspects (start with what's needed)**
   - `modules/devtools/default.nix` — aggregator aspect
     (`den.aspects.devtools`) with `includes` of all `provides.*`
   - `modules/devtools/rust.nix` — `den.aspects.devtools.provides.rust`,
     from `nix/modules/devtools/rust.nix`
   - `modules/devtools/node-ts.nix` — `den.aspects.devtools.provides.node-ts`,
     from `nix/modules/devtools/node-ts.nix`
   - Hosts include `den.aspects.devtools` for all toolchains, or
     `den.aspects.devtools.provides.rust` for just one

8. **Test**
   ```bash
   nix flake check
   # If VM testing works with den:
   nix run .#vm
   # Or build and deploy to MS-A2:
   nixos-rebuild test --flake .#fern --target-host fern.garden
   ```

### Success Criteria
- [ ] `nix flake check` passes
- [ ] fern boots to a desktop session with frond (niri + quickshell)
- [ ] Ada user can log in with full CLI tooling
- [ ] Git suite works with both identities
- [ ] Docker runs
- [ ] Secrets are decrypted via sops-nix

### Config to deliberately NOT migrate in Phase 1
- Cloud CLIs (aws, azure) — add when actually needed
- Gaming — not needed on MS-A2
- LM Studio — evaluate if still needed
- SQL Server — evaluate if still needed
- Teams — evaluate if still needed
- Cursor, VS Code — evaluate; may just use Helix + Claude Code
- Zig overlay — remove unless actively using

## Phase 2: Add Moss (Asahi Laptop)

**Goal:** Prove that aspects work across architectures and GPU variants.

### Steps

1. **Add nixos-apple-silicon input** to flake.nix

2. **Create asahi aspects**
   - `modules/desktop/asahi.nix` — `den.aspects.desktop.provides.asahi`
   - Port from `nix/modules/graphics-asahi.nix` and `nix/modules/boot-asahi.nix`

3. **Create laptop aspect**
   - `modules/laptop.nix` — TLP, power management, wifi, bluetooth, lid switch

4. **Create moss host**
   - Add to `modules/hosts.nix`:
     `den.hosts.aarch64-linux.moss.users.ada = {};`
   - `modules/hosts/moss.nix` — aspect with includes
   - `hardware/moss.nix` — copy from old fern repo's `hosts/moss/hardware.nix`

5. **Validate shared aspects work on both architectures**
   - Base, networking, secrets, docker, devtools should all work unchanged
   - Desktop aspect produces correct GPU config per host via provides

### Success Criteria
- [ ] moss boots with Asahi graphics
- [ ] Shared aspects (base, secrets, docker) work on both fern and moss
- [ ] Desktop aspect correctly applies AMD iGPU on fern, Asahi on moss
- [ ] Frond shell works on aarch64 (or gracefully falls back)

## Phase 3: Add Server Aspects (for oak or fern services)

**Goal:** Build server infrastructure aspects for homelab services.

### Steps

1. **Create server aspects**
   - `modules/server/default.nix` — SSH hardening, firewall, fail2ban
   - `modules/server/caddy.nix` — reverse proxy + ACME/Let's Encrypt
   - `modules/server/gitea.nix` — git forge
   - `modules/server/personal-site.nix` — personal website

2. **Decide: separate oak host or services on fern?**
   - If MS-A2 runs both desktop and services: add server aspects to fern's
     includes
   - If separate machine: create oak host declaration and aspect

3. **Set up garden networking**
   - VLAN configuration for homelab
   - DNS for `*.garden` domain
   - Caddy reverse proxy routing

### Success Criteria
- [ ] Gitea accessible at `gitea.garden` (or similar)
- [ ] Personal site served via caddy with TLS
- [ ] SSH hardened
- [ ] Services survive reboot

## Phase 4: NAS (Future)

**Goal:** Add storage-focused machine to the fleet.

### Steps

1. **Create storage aspects**
   - `modules/storage/zfs.nix` — pools, datasets, snapshots, scrubs
   - `modules/storage/samba.nix` — NFS/Samba network shares
   - `modules/storage/monitoring.nix` — SMART monitoring, disk alerts

2. **Create NAS host**
   - Host declaration + aspect
   - Hardware config

### Success Criteria
- [ ] ZFS pools healthy
- [ ] Network shares accessible from other garden machines
- [ ] Automated snapshots running
- [ ] SMART monitoring alerting

## Phase 5: Additional Laptops (Future)

**Goal:** Add Framework or Razer laptop to demonstrate easy host addition.

### Steps

1. **Create GPU variant** (if needed)
   - `modules/desktop/nvidia.nix` — for Razer
   - Or reuse igpu for Framework

2. **Create host** — should be ~10 lines:
   - 1 line in `hosts.nix`
   - 1 aspect file with includes list

### Success Criteria
- [ ] New laptop configured in under 30 minutes
- [ ] Reuses all existing shared aspects
- [ ] Only host-specific config is hardware + GPU variant selection

## Phase 6: Archive Fern Repo

**Goal:** Clean transition from old to new.

### Steps

1. Verify all machines are running from grove
2. Verify frond repo is working as the shell source
3. Archive `adanoelle/fern` on GitHub (read-only, keep for reference)
4. Archive `adanoelle/fern-shell` on GitHub
5. Update any documentation or references

## Per-Phase Checklist (apply to every phase)

- [ ] `nix flake check` passes
- [ ] All existing hosts still build after changes
- [ ] No secrets committed to git (check for .env, keys, etc.)
- [ ] Aspects are well-named and focused (one feature per aspect)
- [ ] Hardware configs are NOT manually edited
- [ ] Commit messages follow conventional commits (feat, fix, refactor, etc.)

## Porting Guide: Fern Module to Grove Aspect

When migrating a module from the old fern repo, follow this pattern:

### Old pattern (separate NixOS + HM files)

```
nix/modules/audio.nix           → NixOS audio config
nix/home/cli/audio-tools.nix    → Home Manager audio tools
```

### New pattern (single aspect file)

```nix
# grove/modules/audio.nix
{ den, ... }: {
  den.aspects.audio = {
    nixos = { pkgs, ... }: {
      # Content from nix/modules/audio.nix
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
        jack.enable = true;
      };
    };
    homeManager = { pkgs, ... }: {
      # Content from nix/home/cli/audio-tools.nix
      home.packages = with pkgs; [ pavucontrol pamixer ];
    };
  };
}
```

### Conversion checklist per module

- [ ] Identify the NixOS module in `nix/modules/`
- [ ] Identify any corresponding Home Manager config in `nix/home/`
- [ ] Create single aspect file in `grove/modules/`
- [ ] Place NixOS config under `.nixos = { ... }`
- [ ] Place HM config under `.homeManager = { ... }`
- [ ] Remove any `mkIf`/`mkEnableOption` — aspect inclusion replaces them
- [ ] Add to appropriate host aspect's `includes` list
- [ ] If hardware-specific, use `provides` sub-aspect instead
- [ ] Test
