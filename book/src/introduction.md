# Introduction

Fern is a **multi-machine NixOS configuration**. It exists so that several
very different computers — a pro-audio dev workstation, a parked Apple
Silicon laptop, a future homelab server — can share one identity, one set of
conventions, and one review surface, while each machine only carries what it
actually needs.

The trick is **layering**: every fact lives in the most-shared place it is
correct for. A machine is "hardware file + role + quirks"; a user is a
machine-agnostic base layer plus feature layers (desktop, dev toolchain) that
hosts forward when appropriate. The mechanics come from the **dendritic
pattern** — flake-parts + [import-tree](https://github.com/vic/import-tree) +
[den](https://github.com/vic/den) — where every file under `modules/` is
auto-imported and file existence is registration. The reasoning behind all of
this is in [Design Philosophy](concepts/design-philosophy.md).

## What runs where

| Machine | Hardware | Status | Carries |
|---------|----------|--------|---------|
| **fern** | x86_64 desktop (AMD) | Active | workstation + dev-machine + homelab roles, Niri/garden desktop, pro audio, gaming |
| **moss** | Apple Silicon laptop (Asahi) | Parked | placeholder hardware config; waiting on aarch64 fixes |
| *(planned)* | homelab server | — | server + homelab roles (fern drops homelab) |
| *(planned)* | gaming machine | — | hardware + gaming role + quirks |

## Choose your path

| You are… | Start here |
|----------|-----------|
| New to NixOS entirely | [Part I: Understanding Fern](concepts/design-philosophy.md), in order — philosophy, then [NixOS & Flakes](concepts/nixos-and-flakes.md) |
| Comfortable with NixOS, new to den/dendritic | [Aspects, Bundles & Topology](concepts/aspects-bundles-topology.md), then [Part V: Architecture Internals](architecture/repository-layout.md) |
| Curious about the desktop | [Part II: The Desktop](desktop/garden.md) — the garden design system, then [Niri](desktop/niri.md) |
| Setting up or debugging homelab services | [Homelab (Tailscale & Radicale)](services/homelab.md) |
| About to hack on this repo | [Part VI: Operations](operations/rebuilding.md) — rebuilding, [adding an aspect](operations/adding-an-aspect.md), [adding a host](operations/adding-a-host.md) |
| Looking something up | [Reference](reference/aspect-index.md) — aspect index, aliases, environment variables |
| Interested in how it got this way | [Appendix: Migration](migration/why-den.md) |

## Quick start

```bash
# Enter the dev shell (provides just, mdbook, nixfmt)
nix develop            # or: direnv allow

# Test a rebuild without switching
just test

# Rebuild and switch
just switch

# Serve this documentation with live reload
just book-serve

# Format Nix files
just fmt
```

## How this book is organized

Every chapter leads with **why** — the reasoning and constraints — before
**how** — the mechanics. If you only remember the why, you can rediscover the
how; the reverse is not true.

- **Part I: Understanding Fern** — the concepts: philosophy, flakes, the
  module system, Home Manager, and the den vocabulary.
- **Part II: The Desktop (Garden)** — the garden design system, Niri, and
  browsers; the retired Hyprland stack is kept as a documented fallback.
- **Part III: Daily Life** — shells, the git suite, language toolchains, and
  game development tooling.
- **Part IV: The Machine** — system services (homelab, audio, graphics,
  gaming, containers) and security/secrets.
- **Part V: Architecture Internals** — how the flake, dendritic bootstrap,
  topology, and aspect patterns actually work.
- **Part VI: Operations & Reference** — day-to-day procedures and lookup
  tables.
- **Appendix: Migration** — the historical record of the move to den.
