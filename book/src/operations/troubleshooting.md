# Troubleshooting

> The failure modes this configuration actually produces, with the
> cause and the fix for each, followed by how to find which aspect sets
> an option and how to get back to a working system. Recipes named here
> are described in [Day to Day](day-to-day.md).

## Symptom index

| Symptom | Section |
| --- | --- |
| `attribute 'my-aspect' missing`, or a new file has no effect | [New file is invisible](#a-new-file-is-invisible-to-the-flake) |
| `The option 'programs.niri...' does not exist` | [Niri options do not exist](#option-does-not-exist-for-programsniri) |
| `The option ... is already declared` | [Duplicate option declaration](#duplicate-option-declaration) |
| A list option has every entry twice; a service rejects a repeated flag | [Diamond includes](#diamond-includes-without-a-key) |
| `Exactly one of users.users.<name>.isSystemUser and ...isNormalUser must be set` | [Half-defined user](#half-defined-user) |
| Activation fails in sops with no usable key | [Unregistered host](#sops-activation-fails-on-a-new-host) |
| The greeter shows no session to pick | [greetd has no sessions](#greetd-offers-no-session) |
| `Package 'electron-...' is marked as insecure, refusing to evaluate` | [Insecure electron](#insecure-electron-refuses-to-evaluate) |
| `just deadnix` flags an unused `den` | [Lint failures](#lint-failures) |
| The system is broken after a switch | [Getting back](#getting-back-to-a-working-system) |

## Start here

```bash
just check        # does the flake evaluate at all?
just test-trace   # test build with --show-trace
```

In a trace, look for the first path under `modules/`. Aspects defined
as functions inside `includes` are reported as coming from `flake.nix`
rather than their own file; in that case search for the option name
instead (see [Finding what sets something](#finding-what-sets-something)).

## A new file is invisible to the flake

**Cause.** Nix copies only git-tracked files into the store when it
evaluates a flake. import-tree therefore never sees an unstaged module,
and no error says so. The same applies to an unstaged
`hosts/<name>/hardware.nix` or a data file an aspect reads.

**Fix.**

```bash
git add modules/category/my-aspect.nix
```

Staging is enough; a commit is not needed. A file under a `_`-prefixed
directory is skipped by import-tree on purpose and has to be imported
by the aspect that uses it.

## "option does not exist" for `programs.niri.*`

**Cause.** `den.aspects.niri` sets options but does not import the
module that declares them. The niri-flake NixOS module is imported
once, in the host aspect (`modules/host-fern.nix`,
`modules/host-yarrow.nix`). A host that includes or forwards `niri`
without that import has no `programs.niri` option, on the system side
or in Home Manager.

**Fix.** Add to the host aspect's `nixos.imports`:

```nix
inputs.niri.nixosModules.niri
```

A standalone home has no host aspect; it includes
`den.aspects.niri-standalone`, which imports the Home Manager module
instead. Background:
[Upstream modules are imported once](../architecture/aspects.md#upstream-modules-are-imported-once-at-host-level).

## Duplicate option declaration

**Cause.** The reverse of the previous case: a third-party NixOS module
that declares options is imported inside an aspect, and that aspect is
reached twice (for example from `includes` and from
`provides.to-users`, or through two roles). The module is imported
twice and its options are declared twice.

**Fix.** Move the import to the host aspect and leave only the option
settings in the aspect. If the import must stay in the aspect, give the
aspect's `nixos` module a `key` so the copies collapse, as
`modules/secrets.nix` does for sops-nix.

## Diamond includes without a `key`

**Symptom.** No evaluation error. A list option ends up with each entry
twice. The case that motivated the convention: `tailscale set`
rejecting a repeated `--operator` flag.

**Cause.** den turns `includes` into a plain import tree and does not
dedupe. An aspect reachable by two paths is applied twice.

**Fix.** Either make the paths disjoint, or set
`key = "den-aspect:<name>";` on the aspect's `nixos` module and move
its settings under `config`. The pattern and the aspects that use it
are in
[Diamond includes](../architecture/aspects.md#diamond-includes-den-does-not-dedupe).

To confirm a suspicion, look at the merged value:

```bash
nix eval --json .#nixosConfigurations.fern.config.services.tailscale.extraSetFlags
```

## Half-defined user

**Cause.** A system aspect sets something under `users.users.<name>`
(a group, a shell) on a host that does not include `den.aspects.users`.
The account then exists with no type. `users` comes with the
`workstation` and `server` roles; a host composed by hand can miss it.

**Fix.** Include `den.aspects.users`. Do not add group membership in
service aspects: `modules/users.nix` grants every group, conditional on
the service being enabled on the host.

## sops activation fails on a new host

**Cause.** The `secrets` aspect decrypts with the machine's SSH host
key. If that key is not a recipient in `.sops.yaml`, or the secrets
file was not re-keyed after adding it, nothing can be decrypted and
activation stops. This is deliberate.

**Fix.** Register the host and re-key, then build from the commit that
contains the re-keyed file:
[Registering a new machine](../security/sops-nix.md#registering-a-new-machine).
On a fresh install the host key has to be created before the first
`nixos-install`; see [Adding a Host](adding-a-host.md#5-secrets-registration).

## greetd offers no session

**Cause.** `modules/desktop/greetd.nix` builds tuigreet's session list
from the compositors the host has enabled (`programs.niri.enable`,
`programs.hyprland.enable`). With neither enabled the list is empty.
The `workstation` role does not enable a compositor.

**Fix.** The host aspect must include `den.aspects.niri` (and import
the niri-flake module). For the Hyprland fallback the host sets
`programs.hyprland.enable = true;` and forwards
`den.aspects.ada-hyprland`. Check what the greeter was given:

```bash
nix eval --raw .#nixosConfigurations.yarrow.config.services.greetd.settings.default_session.command
```

If a session is listed but starts with none of the expected bindings,
the host is missing the `provides.to-users` forward of `niri`.

## Insecure electron refuses to evaluate

**Cause.** `bitwarden-desktop` depends on an electron release that
nixpkgs marks end-of-life. `modules/desktop/bitwarden.nix` permits one
exact version string in `nixpkgs.config.permittedInsecurePackages`.
After an input update the package may depend on a different electron
version, and the permit no longer matches.

**Fix.** Put the version named in the error message into the list in
`modules/desktop/bitwarden.nix`. If the error no longer appears with
the entry removed, delete the permit.

## Lint failures

| Message | Cause | Fix |
| --- | --- | --- |
| deadnix: unused lambda pattern `den` | Module header `{ den, ... }:` on an aspect with no `includes` | Use `_:` |
| deadnix reports a `hosts/*/hardware.nix` | New host's generated file is not excluded | Add it to the `deadnix` recipe's `--exclude` list in the `justfile` |

## Finding what sets something

**Which file defines or includes an aspect:**

```bash
grep -rn "aspects.tailscale" modules/
```

**Which file sets an option** (search for the option, then for a
distinctive value):

```bash
grep -rn "services.tailscale" modules/
grep -rn "useRoutingFeatures" modules/
```

**Ask the module system.** For an option set by an aspect's plain
`nixos` block, `files` names the module file and the aspect:

```bash
nix eval --json .#nixosConfigurations.fern.options.time.timeZone.files
# ["…/modules/core.nix, via option den.aspects.core.nixos"]
```

Settings made inside a parametric include report `flake.nix`; fall back
to grep for those.

**Read the evaluated value** on each machine:

```bash
# fern, system side
nix eval --json .#nixosConfigurations.fern.config.networking.firewall.trustedInterfaces

# yarrow, system side
nix eval --json .#nixosConfigurations.yarrow.config.services.power-profiles-daemon.enable

# a NixOS host's Home Manager side
nix eval --json .#nixosConfigurations.fern.config.home-manager.users.ada.home.sessionVariables

# the standalone home: find its key, then query it
nix eval .#homeConfigurations --apply builtins.attrNames
nix eval --json '.#homeConfigurations."<user>@<hostname>".config.home.sessionVariables'
```

**Does a host evaluate to a system at all**, without building:

```bash
nix eval .#nixosConfigurations.fern.config.system.build.toplevel.drvPath
```

**What a rebuild changed:** `just diff-gen`.

**Which machines carry an aspect:** the
[Aspect Index](../reference/aspect-index.md).

## Getting back to a working system

- A configuration activated with `just test` is not the boot default.
  Reboot to leave it.
- `just rollback` switches to the previous generation.
- If the session or network is unusable, reboot and choose an older
  generation in the systemd-boot menu.
- `just gc` keeps recent generations.
  `sudo nix-collect-garbage -d` deletes all of them; do not run it
  while a rollback might still be needed.

On the work laptop, rollback is Home Manager's; see
[the work laptop page](../machines/work-laptop.md).

## Key files

| File | Relevant to |
| --- | --- |
| `modules/host-*.nix` | niri-flake import, compositor enablement, user-layer forwards |
| `modules/desktop/greetd.nix` | Session list |
| `modules/desktop/niri.nix`, `modules/desktop/niri-standalone.nix` | Niri options and the standalone import |
| `modules/tailscale.nix`, `modules/secrets.nix` | The dedupe `key` convention |
| `modules/users.nix` | Account definition and group membership |
| `modules/desktop/bitwarden.nix` | Insecure-package permit |
| `.sops.yaml` | Secret recipients |
| `justfile` | `test-trace`, `rollback`, `diff-gen`, lint recipes |
