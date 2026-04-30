# Grove Design Documents

Design documents for **grove**, the den-based NixOS configuration that will
replace this (fern) repository.

## Documents

| Document | Purpose |
|----------|---------|
| [01-naming-and-topology.md](01-naming-and-topology.md) | Network, repo, and host naming. Machine topology and capability matrix. |
| [02-den-architecture.md](02-den-architecture.md) | How den/dendritic pattern works. Grove repo structure. Key differences from fern. |
| [03-frond-shell-integration.md](03-frond-shell-integration.md) | How the frond desktop shell (quickshell + niri) integrates with grove. |
| [04-migration-plan.md](04-migration-plan.md) | Phased plan for building grove and migrating from fern. |
| [05-fern-config-reference.md](05-fern-config-reference.md) | Exact config values from fern repo for porting. Module-to-aspect mapping. |

## Summary

- **garden** = the network (UniFi, VLANs, VPN)
- **grove** = the NixOS config repo (den-based, replaces fern repo)
- **frond** = the desktop shell repo (quickshell + niri, replaces fern-shell)
- **fern** = the primary dev workstation host (Minisforum MS-A2)
- **moss** = the Asahi Linux laptop host

## Key Decisions

1. Den (aspect-driven) pattern for multi-machine NixOS configuration
2. Separate repos: grove (config) + frond (shell)
3. Frond exports packages; grove aspects handle integration
4. Dependency reconciliation via flake `follows`
5. Phased migration starting with fern (MS-A2), then moss, then future hosts

## For Claude Code Agents

These documents contain enough detail to scaffold the grove repository. Start
with [04-migration-plan.md](04-migration-plan.md) Phase 1, using
[02-den-architecture.md](02-den-architecture.md) for structure and
[05-fern-config-reference.md](05-fern-config-reference.md) for config values.
