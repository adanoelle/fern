# Grove Design: Naming and Topology

## Overview

This document defines the naming conventions and machine topology for **grove**,
a new NixOS configuration repository built on the
[den](https://github.com/vic/den) (dendritic/aspect-driven) pattern. Grove
replaces the original `fern` repository, which was designed around a single host
and later had a second host (moss) tacked on.

## Naming System

Three layers, all botanical, all distinct, no collisions.

### garden — The Network

- **What:** The name of the home network/homelab infrastructure
- **Where it appears:** DNS, VPN configuration, UniFi management, SSH config
- **Usage:** `ssh fern.garden`, VPN tunnel names, VLAN labels
- **Hardware:** UniFi Dream Machine Pro as the network backbone

### grove — The NixOS Configuration Repository

- **What:** The den-based NixOS configuration that defines all machines
- **Where it appears:** GitHub repo name (`adanoelle/grove`), local development
- **Relationship:** Grove is the _blueprint_. Garden is the _thing_. Grove defines
  garden.

### frond — The Desktop Shell

- **What:** A separate repository (`adanoelle/frond`) containing the custom
  desktop environment built on quickshell + niri compositor + custom Rust control
  plane
- **Where it appears:** GitHub repo, flake input in grove
- **Aesthetic:** PC-98 / vintage computing inspired, are.na influenced
- **Key metaphor:** A fern frond is a fractal structure — the frond divides into
  pinnae (channels/workspaces), which divide into pinnules (blocks/windows).
  This maps directly to frond's channel-and-block UI architecture.
- **Previously:** Called `fern-shell`. Renamed because multiple hosts will use it.

## Host Naming

All hosts use botanical names, consistent with the garden theme.

| Host | Hardware | Arch | Role | Status |
|------|----------|------|------|--------|
| **fern** | Minisforum MS-A2 | x86_64, AMD | Primary dev workstation + homelab services | First priority |
| **moss** | Apple Silicon laptop | aarch64 | Portable laptop, Asahi Linux | Existing |
| **oak** | TBD | x86_64 | Future services/homelab machine | Planned |
| **NAS** (name TBD) | TBD | x86_64 | Storage — ZFS, Samba/NFS, snapshots | Future |
| **laptop** (name TBD) | Framework or Razer | x86_64 | Portable dev laptop | Future |

Future host name candidates (botanical): `lichen`, `cedar`, `ivy`, `sage`,
`reed`, `elm`, `peat`, `loam`

## Network Topology

```
garden (network — UniFi Dream Machine Pro)
│
├── VLAN: management
│   └── UniFi devices
│
├── VLAN: homelab
│   ├── fern (ms-a2 — dev workstation + services)
│   ├── oak (future services)
│   └── NAS (future storage)
│
├── VLAN: devices
│   ├── moss (asahi laptop)
│   └── future laptops
│
└── VPN tunnel (remote access to VLANs)
```

## User

All machines are configured for a single user: **ada**

- Personal identity: `adanoelle` / `adanoelleyoung@gmail.com`
- Work identity: `youngt0dd` / `todd.young@pinnaclereliability.com`
- Git signing keys: `~/.ssh/github` (personal), `~/.ssh/github-work` (work)

## Machine Capability Matrix

This matrix shows which aspects/features each machine needs. This directly
informs which den aspects each host's aspect will `include`.

| Concern | fern | moss | oak | NAS | laptop |
|---------|------|------|-----|-----|--------|
| Base/core (nix, users, secrets) | x | x | x | x | x |
| Desktop (Hyprland/niri, audio, fonts) | x | x | | | x |
| Nvidia GPU | | | | | maybe |
| Asahi graphics | | x | | | |
| AMD iGPU | x | | | | |
| Intel/AMD iGPU | | | | | maybe |
| Frond shell (quickshell + niri) | x | x | | | x |
| Dev toolchains (Rust, TS, Python) | x | x | | | x |
| Server services (caddy, gitea, etc.) | x | | x | | |
| Storage (ZFS, Samba, SMART) | | | | x | |
| Laptop (TLP, power, wifi, bluetooth) | | x | | | x |
| Docker | x | x | x | | x |
| Monitoring | x | x | x | x | x |
| Home-manager (full desktop) | x | x | | | x |
| Home-manager (minimal/headless) | | | x | x | |

## Design Decisions Log

1. **Separate repos for grove and frond:** frond has its own development
   lifecycle (Rust crates, quickshell iteration) and will be consumed by
   multiple machines. It exports packages; grove aspects handle integration.

2. **frond exports packages, not NixOS modules:** Since grove is the only
   consumer and uses den, integration logic lives in den aspects. No `mkIf` or
   enable flags needed — aspect inclusion handles composition. If frond needs to
   be shared with non-den consumers later, NixOS modules can be added then.

3. **Dependency reconciliation via `follows`:** grove's flake.nix will use
   `inputs.frond.inputs.nixpkgs.follows = "nixpkgs"` (and similar for
   rust-overlay) to ensure a single nixpkgs evaluation.

4. **Single user (ada) across all machines:** Simplifies den schema. No
   multi-user complexity needed.

5. **fern name reused for ms-a2:** The original fern hardware died. The name
   transfers to the new primary workstation.
