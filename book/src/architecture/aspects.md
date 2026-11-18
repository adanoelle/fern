# Aspects & Composition

> The vocabulary of this repository and the handful of composition
> patterns it uses: aspects and their two sides, bundles and roles,
> forwarding user layers from a host, parametric includes that read the
> topology, and the rules that keep an aspect from being applied twice.
> Other pages use these terms without redefining them.

**Goes on:** every host

For the generic NixOS module system (options, `mkIf`, priorities) see
[nix.dev](https://nix.dev/tutorials/module-system/) and the
[NixOS](https://nixos.org/manual/nixos/stable/) and
[Home Manager](https://nix-community.github.io/home-manager/) manuals;
for den itself see its [documentation](https://den.oeiuwq.com/).

## Vocabulary

| Term | Meaning here |
| ---- | ------------ |
| Aspect | `den.aspects.<name>`: one concern, defined in one file under `modules/` |
| Side (class) | The part of an aspect for one kind of configuration: `nixos` (system) or `homeManager` (user). Either may be absent |
| `includes` | List of other aspects (or functions) an aspect pulls in |
| Bundle | An aspect that is mostly `includes`, grouping a category: `cli`, `shells`, `git-suite`, `desktop-apps`, `devtools`. Defined in `modules/<category>/bundle.nix` |
| Role | A bundle of host-side aspects for a kind of machine, in `modules/roles/` |
| Host aspect | The aspect named after a host (`modules/host-<name>.nix`) |
| User layer | An aspect applied to the user: the base `ada`, or a forwarded `ada-*` layer |
| Topology | `den.hosts` / `den.homes` in `modules/hosts.nix`: which machines exist and who uses them |
| Namespace | A set of aspects imported from another flake; `garden.*` comes from garden-shell |

A host named `fern` gets `den.aspects.fern` and a user named `ada` gets
`den.aspects.ada`, by name. Nothing else is applied unless one of those
(or `den.default`) includes it. The layering rules that decide what goes
where are in [Design & Layering](../start/design-and-layering.md).

## An aspect

```nix
{ den, ... }:
{
  den.aspects.thing = {
    includes = [ den.aspects.other ];
    nixos = { pkgs, ... }: { /* system side */ };
    homeManager = { pkgs, ... }: { /* user side */ };
  };
}
```

Each side is an ordinary NixOS or Home Manager module. Most aspects have
one side only: `modules/devtools/docker.nix` is `nixos` only, most of
`modules/cli/` is `homeManager` only. `modules/desktop/niri.nix` and
`modules/desktop/teams.nix` have both.

There are no enable flags for aspects. Being in an include chain is what
turns one on; removing it from the chain turns it off.

## What reaches where

This is the part that is easy to get wrong, so it is stated from
observed behaviour (checked by evaluating the fern configuration).

| Where the aspect is listed | `nixos` side | `homeManager` side |
| -------------------------- | ------------ | ------------------ |
| Host aspect `includes` (directly or through a role) | applied to the host | **not** applied to the host's users |
| Host aspect `provides.to-users.includes` | applied to the host | applied to every user of the host |
| User aspect `includes` (the base `ada` layer) | not exercised: nothing in the base layer has a `nixos` side | applied to the user |
| `den.aspects.ada.provides."<hostname>"` (standalone home) | ignored: there is no system | applied to that home |

Consequences:

- An aspect with both sides that should work for the user must be
  forwarded. The host aspects list `den.aspects.niri` in **both**
  `includes` and `provides.to-users.includes`; the forwarded copy is the
  one that delivers the Home Manager settings.
- An aspect listed only in a host's `includes` contributes its `nixos`
  side alone. `teams` on fern is an example: the system package is
  installed, its `homeManager` side is not evaluated there.
- A forwarded layer can carry system configuration. `ada-dev` includes
  the `devtools` bundle, and the `nixos` sides inside it land on the
  host.

### `provides.to-users.includes`

A host aspect forwards user layers like this (from
`modules/host-yarrow.nix`, shortened):

```nix
provides.to-users.includes = [
  den.aspects.ada-desktop
  den.aspects.ada-dev
  den.aspects.niri
];
```

The routing is done by `den._.mutual-provider`, enabled in
`modules/dendritic.nix` (see
[The Flake & Bootstrap](flake-and-bootstrap.md)). This is how the same
user gets a desktop on one host and stays minimal on another.

### `provides."<hostname>"` for standalone homes

A standalone Home Manager configuration has no host aspect to forward
from. Instead the *user* aspect declares a layer keyed by the home's
host name, at the bottom of `modules/user-ada-work.nix`:

```nix
den.aspects.ada.provides."<hostname>".includes = [ den.aspects.ada-work ];
```

The host name is taken from the `"<user>@<hostname>"` key of the
`den.homes` entry in `modules/hosts.nix`. See
[the work laptop](../machines/work-laptop.md).

## Parametric includes

An entry in `includes` may be a function. den resolves aspects in a host
context, and a function whose arguments that context satisfies is called
with it. `{ host, ... }:` receives the den host, and `host.users` is the
topology from `modules/hosts.nix`. This is how shared aspects avoid
naming a user:

| File | Reads `host.users` to |
| ---- | --------------------- |
| `modules/users.nix` | create an account for every topology user |
| `modules/core.nix` | add those users to the Nix daemon's `trusted-users` |
| `modules/secrets.nix` | set the owner and path of the user-owned secret |
| `modules/tailscale.nix` | make the user the Tailscale operator |
| `modules/cli/nh.nix` | default `programs.nh.flake` to `~/src/fern` in the user's home |

The last three take the *first* topology user and so assume a
single-user host, which every host is today.

## Diamond includes: den does not dedupe

den resolves `includes` into a plain tree of module imports. If an
aspect is reachable by two paths, its module is applied **twice**.
Scalar options merge silently, but list options get every entry twice.

Where an aspect is knowingly reached twice, its `nixos` side sets a
module `key`, which lets the NixOS module system collapse the copies.
From `modules/tailscale.nix`:

```nix
nixos =
  { lib, ... }:
  {
    key = "den-aspect:tailscale";
    config = {
```

Note that a module with a `key` must put its settings under `config`.
The convention is `key = "den-aspect:<aspect-name>"`; a parametric
include inside the same aspect needs its own distinct key. The aspects
that carry one, and why, are explained in the comments of
`modules/tailscale.nix`, `modules/secrets.nix` and
`modules/audio/audio.nix`.

The rule when adding an include:

- Prefer keeping paths disjoint. `modules/roles/dev-machine.nix` states
  the intent: host-level services go in the role, language toolchains in
  the `devtools` bundle, and the two should not overlap.
- If a diamond is intended, add a `key`.

One overlap exists without a key at the time of writing: `docker` is in
both the `workstation` role and the `devtools` bundle, so on fern its
module is applied twice (the daemon's `extraOptions` reads
`--experimental --experimental` and its packages are listed twice).
Likewise `niri`, listed in both `includes` and `provides.to-users`, has
its `nixos` side applied twice; it sets no list option that is sensitive
to that.

## Upstream modules are imported once, at host level

A third-party NixOS module that *declares options* cannot be imported
twice without a "duplicate option declaration" error, and an aspect may
be reached twice. So such modules are imported in the host aspect's
`nixos.imports`, and the aspect only sets their options.

The case in this repository is niri: `inputs.niri.nixosModules.niri` is
imported in `modules/host-fern.nix` and `modules/host-yarrow.nix`, and
`den.aspects.niri` assumes it is present. That is also why `niri` is not
part of the `workstation` role or the `desktop-apps` bundle: a host opts
into the aspect alongside the import. A new host that wants Niri needs
both lines. The standalone equivalent is
`modules/desktop/niri-standalone.nix`, which imports niri-flake's Home
Manager module once at home level.

Modules imported inside an aspect that is only ever reached once, or
that carries a `key` (sops-nix in `modules/secrets.nix`), are fine.

## Option-defining aspects

A few aspects declare their own Home Manager options and leave the
values to a user layer, so the mechanism is shared and the preferences
are not.

- **Hyprland.** `modules/desktop/hyprland.nix` declares
  `desktop.hyprland.*` and does nothing until enabled.
  `modules/user-ada-hyprland.nix` includes it and sets the options. See
  [Hyprland](../desktop/hyprland.md).
- **Git suite.** `modules/git/bundle.nix` declares `programs.gitSuite.*`
  and fans it out to the `git-*` aspects; `modules/user-ada.nix` sets
  it. See [Git](../git/git.md).

Use this shape only when a second user or host would plausibly want
different values. Otherwise write the configuration directly.

## The `_` prefix

import-tree skips any path with a component that starts with `_`. Such
files are not flake-parts modules; a parent module imports or reads them
explicitly. Examples: `modules/desktop/_hyprland/` (Home Manager
sub-modules imported by `hyprland.nix`), `modules/cli/_presenterm/`
(theme assets), `modules/desktop/_studies/` (one file per wallpaper
palette, read by `wallpaper.nix`).

## Naming

- One aspect per file, `modules/<category>/<name>.nix`, dash-separated;
  the aspect name matches the file name.
- A category's bundle is `bundle.nix` and defines
  `den.aspects.<category>` (the git one is `git-suite`, the desktop one
  `desktop-apps`).
- `ada-*` aspect names are reserved for user layers. The Ada language
  toolchain is therefore `ada-lang`, in `modules/devtools/ada.nix`.
- Host aspects are `host-<name>.nix`, user layers `user-ada*.nix`, both
  at the top of `modules/`.

The full list of aspects is in the
[Aspect Index](../reference/aspect-index.md); the procedure for adding
one is in [Adding an Aspect](../operations/adding-an-aspect.md).

## Key files

| File | Role |
| ---- | ---- |
| `modules/hosts.nix` | Topology |
| `modules/host-*.nix` | Host aspects and `provides.to-users` |
| `modules/roles/` | Roles |
| `modules/*/bundle.nix` | Category bundles |
| `modules/user-ada-work.nix` | `provides."<hostname>"` for the standalone home |
| `modules/users.nix` | Parametric include, with the explanation in its header |
| `modules/tailscale.nix` | Dedupe `key`, with the explanation in its header |
