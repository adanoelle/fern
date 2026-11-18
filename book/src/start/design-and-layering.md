# Design & Layering

> Fern is one flake that describes several quite different machines.
> Everything is declared in Nix, every file under `modules/` is picked up
> automatically, and each fact lives in exactly one layer: the base user,
> a forwarded user layer, a role, a host aspect, or the fleet defaults.
> This page is the single statement of those layering rules.

**Goes on:** every host

## Why declarative

Bootloader, kernel, services, desktop, dotfiles and secrets are all Nix
expressions built against a pinned `flake.lock`. If it is not in the
repository it is not on the machine, a bad change is one rollback away,
and a second machine is a composition exercise rather than a reinstall
diary.

## Why dendritic

The repository follows the dendritic pattern: flake-parts +
[import-tree](https://github.com/vic/import-tree) +
[den](https://github.com/vic/den). Every `.nix` file under `modules/` is
a flake-parts module and is imported automatically, so creating a file
registers it and deleting it removes it. There is no import list to
forget.

The unit of configuration is the **aspect**: one concern, with an
optional system side and an optional user side, composed with
`includes`. The vocabulary is defined once, in
[Aspects & Composition](../architecture/aspects.md).

## The layers

| Layer | Aspects | Lives in | Holds |
| ----- | ------- | -------- | ----- |
| Fleet defaults | `den.default`, `core` | `modules/defaults.nix`, `modules/core.nix` | Settings every host starts from, mostly `lib.mkDefault` |
| Roles | `workstation`, `laptop`, `dev-machine`, `homelab`, `server` | `modules/roles/` | The system aspects a *kind* of machine wants |
| Host aspect | one per machine | `modules/host-<name>.nix` | Roles, forwarded user layers, and facts true of that hardware alone |
| User base layer | `ada` | `modules/user-ada.nix` | Shells, CLI tools, git, SSH, home directory layout |
| Forwarded user layers | `ada-desktop`, `ada-dev`, `ada-hyprland`, `ada-work`, plus single aspects | `modules/user-ada-*.nix` | Everything about the user that only some machines should carry |

Which machine takes which roles and layers is recorded per machine:
[fern](../machines/fern.md), [yarrow](../machines/yarrow.md),
[work laptop](../machines/work-laptop.md), [moss](../machines/moss.md).

## The rules

1. **The base user layer is safe everywhere.** `ada` must apply cleanly
   on any host, including a headless one. It never gains GUI, compositor
   or language-toolchain configuration. The garden terminal stack is not
   in it either: that arrives with the desktop layer.
2. **Anything machine-dependent about the user is a forwarded layer.**
   A host opts in by listing the layer in `provides.to-users.includes`.
   `ada-desktop` is the core of a graphical session, `ada-dev` the
   language toolchains, `ada-hyprland` the fallback compositor session.
   `ada-work` is the work laptop's layer and is attached to its
   standalone home rather than forwarded by a host.
3. **Heavier or hardware-bound pieces are opt-in per host, one aspect at
   a time.** Compositor session, brightness backend, idle suspend,
   streaming, music, game development and gaming are forwarded
   individually next to the `ada-*` layers, so each machine picks what
   fits it.
4. **Roles describe kinds of machine, not machines.** `workstation` is
   the shared base of every graphical x86 host; `laptop` adds what a
   battery-powered machine needs; `dev-machine` adds host-level
   development services; `homelab` is the always-on self-hosted
   services; `server` is the headless base (no host uses it yet). A new
   machine should be "hardware file + roles + quirks".
5. **Host aspects are composition plus hardware facts.** Kernel choice,
   udev rules, sensor modules, per-model `nixos-hardware` imports and
   `system.stateVersion` belong there. Anything a second machine could
   want belongs in a role or a shared aspect instead.
6. **Fleet defaults yield.** `core` sets its preferences with
   `lib.mkDefault` so a host overrides them with a plain definition. The
   exception, and the reason for it, is in
   [Defaults, Core & Users](../architecture/defaults-core-users.md).
7. **New configuration goes in the most-shared place it is correct
   for.** A preference goes in a user layer, a kind-of-machine need in a
   role, a hardware fact in the host aspect.

## System side or user side

Within an aspect, the rule of thumb is: if it needs root or affects the
whole machine (services, kernel, drivers, groups), it goes on the
`nixos` side; if it is per-user configuration (dotfiles, user services,
user packages), it goes on the `homeManager` side. Preferring the user
side keeps an aspect usable on the work laptop, which has no NixOS
system to configure.

## Key files

| File | Role |
| ---- | ---- |
| `modules/user-ada.nix` | Base user layer |
| `modules/user-ada-*.nix` | Forwarded user layers |
| `modules/roles/` | Role aspects |
| `modules/host-*.nix` | Host aspects |
| `modules/core.nix`, `modules/defaults.nix` | Fleet defaults |
