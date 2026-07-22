# Design Philosophy

> Every choice in this repository answers the same question: *how do you keep a
> fleet of very different machines coherent without a central registry that rots?*

## Why declarative

The entire system — bootloader, kernel modules, desktop, dotfiles, secrets —
is described in Nix expressions and built from a pinned `flake.lock`. There is
no drift to audit: if it isn't in the repo, it isn't on the machine. Rollback
is a bootloader menu entry, and a broken experiment costs one `just rollback`,
not an evening of archaeology.

## Why dendritic

Fern uses the **dendritic pattern**: flake-parts +
[import-tree](https://github.com/vic/import-tree) + [den](https://github.com/vic/den).
Every `.nix` file under `modules/` is a flake-parts module and is imported
automatically. **File existence is registration** — there is no central import
list to update, no `default.nix` to keep in sync, no forgotten module silently
doing nothing. Deleting a file removes the feature; creating one adds it.

The unit of composition is the **aspect**: one file describing one concern,
with an optional system (`nixos`) side and user (`homeManager`) side. Aspects
compose via `includes`, and bundles/roles are just aspects that mostly include
other aspects.

## Why layering

Machines differ; identity shouldn't. The configuration is layered so each fact
lives in the *most-shared place it is correct for*:

- **User base layer** (`ada`) — shells, git, CLI. Safe on any host, even a
  headless server. Never gains GUI or toolchain config.
- **User feature layers** (`ada-desktop`, `ada-dev`) — forwarded per-host by
  the host aspect, so the same user gets a full desktop on fern but would stay
  minimal on a server.
- **Roles** (`workstation`, `dev-machine`, `homelab`, `server`) — bundles of
  system aspects a *kind* of machine wants. A future machine is "hardware file
  + role + quirks".
- **Host aspects** (`fern`, `moss`) — composition plus genuinely
  machine-specific facts: kernel choice, udev rules, sensor chips.
- **Fleet defaults** (`core.nix`) — set with `lib.mkDefault` so any host can
  override without fighting the framework.

## Why this book leads with *why*

Nix code shows *what* is configured; it rarely explains why an option exists,
why an alternative was rejected, or which invariant you'd break by "cleaning
it up". Each chapter here states the reasoning first, then the mechanics —
so future changes (including by AI assistants) start from intent, not just
syntax. When a chapter documents a workaround (say, a module imported at host
level rather than in its aspect), the *why* is the part that keeps the
workaround from being reverted.
