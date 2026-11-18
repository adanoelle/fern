# History: the Move to den

> **Historical.** This page describes a layout that no longer exists, so
> that old commits, branches and notes can be read. Nothing here is
> needed to work on the repository today; for the current structure
> start at [Design & Layering](../start/design-and-layering.md).

## Before

From June 2025 until April 2026 the flake used flake-parts with
hand-maintained registries:

- `flake.nix` imported a fixed list of numbered files:
  `flake.parts/00-overlay.nix`, `10-core.nix`, `20-nixos-mods.nix`,
  `30-home-mods.nix`, `40-hosts.nix`, `50-dev.nix`, `60-docs.nix`.
- System modules lived in `nix/modules/` and Home Manager modules in a
  parallel `nix/home/` tree, so one tool could be split across both.
- `20-nixos-mods.nix` and `30-home-mods.nix` were registries: every
  module had to be added by hand as `flake.nixosModules.<name>` or
  `flake.homeModules.<name>`.
- Each machine had `hosts/<name>/configuration.nix`, which imported
  `self.nixosModules.*` one by one and wired the user's Home Manager
  modules inline; `40-hosts.nix` called `nixosSystem` per host with
  `withSystem` and `specialArgs`.
- Category files such as `nix/home/cli.nix` were aggregators with their
  own import lists.

## The migration

The switch to den and import-tree was a single commit, `92e4c34`
("migrate from hand-rolled modules to vic/den aspect framework"), on
**4 April 2026**, merged the next day. It replaced `flake.parts/`,
`nix/` and the per-host `configuration.nix` files with one `modules/`
tree, leaving only `hardware.nix` under `hosts/`.

The second step came on 16 July 2026 (`7c54dd0`, "layer user aspects and
introduce host roles"): the single user aspect was split into a base
layer plus forwarded layers, and `modules/roles/` was added.

## Why

- **Registries rot.** A module that existed but was not registered, or
  was registered but not imported by a host, did nothing and said
  nothing. With import-tree a file is active because it exists.
- **Two trees for one concern.** The system and user halves of a tool
  were in different directories. An aspect keeps both sides in one file.
- **Adding a machine meant copying a configuration.** Each
  `configuration.nix` repeated the import list. Topology plus roles
  makes a new host a short composition.
- **User setup was tied to the host file.** A separate user aspect, and
  later layers, lets one user be configured differently per machine.

## Old term to new term

| Then | Now |
| ---- | --- |
| `flake.parts/NN-*.nix`, imported by list | any file under `modules/`, imported by import-tree |
| `nix/modules/<x>.nix` + `nix/home/<x>.nix` | one aspect, `den.aspects.<x>`, with `nixos` and `homeManager` sides |
| `flake.nixosModules.<x>` / `flake.homeModules.<x>` registry entry | nothing: the aspect exists once its file does |
| `imports = [ self.nixosModules.<x> ]` in a host | `includes = [ den.aspects.<x> ]` |
| aggregator (`nix/home/cli.nix`) | bundle (`modules/cli/bundle.nix`) |
| `hosts/<name>/configuration.nix` | host aspect, `modules/host-<name>.nix` |
| `flake.parts/40-hosts.nix` (`nixosSystem` calls) | topology, `modules/hosts.nix` |
| `hosts/common-hm.nix` and inline user wiring | user layers, `modules/user-ada*.nix` |
| `inputs.fern` (the fern-shell flake) | `inputs.garden-shell` and the `garden` namespace |

The commits before `92e4c34` still contain the old tree, including its
own READMEs, for anyone who needs the detail.
