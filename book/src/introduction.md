# Introduction

Fern is a **multi-machine NixOS configuration**. It exists so that
several very different computers can share one identity, one set of
conventions and one review surface, while each machine carries only what
it needs.

The trick is **layering**: every fact lives in the most-shared place it
is correct for. A machine is "hardware file + roles + quirks"; a user is
a machine-agnostic base layer plus feature layers that hosts forward
when they fit. The mechanics come from the **dendritic pattern**
(flake-parts, [import-tree](https://github.com/vic/import-tree) and
[den](https://github.com/vic/den)), where every file under `modules/` is
imported automatically. The reasoning is in
[Design & Layering](start/design-and-layering.md).

## The machines

| Machine | What it is | Status |
| --- | --- | --- |
| [fern](machines/fern.md) | x86_64 desktop workstation: Niri and the garden shell, studio audio, development, homelab services | active |
| [yarrow](machines/yarrow.md) | Framework Laptop 13 Pro: art, game development and playtesting | configured, [not yet installed](machines/installing-yarrow.md) |
| [work laptop](machines/work-laptop.md) | Ubuntu 24.04 with a standalone home-manager configuration | active |
| [moss](machines/moss.md) | Apple Silicon laptop (Asahi) | parked |

Each machine's page is the one place that says what that machine
carries. Topic pages say which machines a thing goes on and link back.

## Where to start

| You want to… | Go to |
| --- | --- |
| Understand why it is built this way | [Design & Layering](start/design-and-layering.md) |
| Learn the den vocabulary and patterns | [Aspects & Composition](architecture/aspects.md) |
| See what a machine has | [Machines](machines/fern.md) |
| Change something | [Day to Day](operations/day-to-day.md), then [Adding an Aspect](operations/adding-an-aspect.md) |
| Fix something | [Troubleshooting](operations/troubleshooting.md) |
| Look something up | [Aspect Index](reference/aspect-index.md), [Aliases](reference/aliases.md) |

## How this book is organised

- **Machines**: one page per machine.
- **How it's built**: the den vocabulary, the flake and its bootstrap,
  and the fleet defaults.
- **What's configured**: the desktop, terminal and shells, git,
  toolchains, creative tools, services and secrets. Each page states
  which machines carry it.
- **Operating**: the working loop, adding things, and what goes wrong.
- **Reference**: lookup tables.
- **History**: how it got this way.

Two rules keep the book honest. Every fact has one home, and other pages
link to it. And pages point at the code rather than copying it, so the
file named on a page is always the authority.

This book assumes working knowledge of Nix. For that, see
[nix.dev](https://nix.dev), the
[NixOS manual](https://nixos.org/manual/nixos/stable/) and the
[Home Manager manual](https://nix-community.github.io/home-manager/).
