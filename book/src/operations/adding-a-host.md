# Adding a Host

> A checklist for bringing a new NixOS machine into the flake as a
> working graphical host, and a short section on adding a standalone
> Home Manager home. [Installing yarrow](../machines/installing-yarrow.md)
> is the worked example of the same steps on real hardware.

What each existing machine composes is on its own page under
[Machines](../machines/fern.md) ([fern](../machines/fern.md),
[yarrow](../machines/yarrow.md),
[work laptop](../machines/work-laptop.md),
[moss](../machines/moss.md)). Read one host aspect
(`modules/host-yarrow.nix` is the smallest complete one) next to this
page.

## Checklist

1. [Declare the host in the topology](#1-topology)
2. [Write the host aspect](#2-host-aspect)
3. [Provide `hosts/<name>/hardware.nix`](#3-hardware-file)
4. [Exclude the hardware file from deadnix](#4-deadnix-exclusion)
5. [Register the host for secrets](#5-secrets-registration)
6. [Stage, check, install](#6-stage-check-install)

Do the repository work in a git worktree on a branch, as for any
change ([Day to Day](day-to-day.md#the-working-loop)).

## 1. Topology

Add one line to `modules/hosts.nix`:

```nix
den.hosts.x86_64-linux.<name>.users.ada = { };
```

This creates `nixosConfigurations.<name>`, applies `den.aspects.<name>`
to it, and gives the user the base `ada` layer.

## 2. Host aspect

Create `modules/host-<name>.nix`. A graphical host needs every part
below; the comments say what breaks without each.

```nix
# modules/host-<name>.nix — <name> host aspect
{ den, inputs, ... }:
{
  den.aspects.<name> = {
    includes = [
      den.aspects.boot          # systemd-boot; nothing else sets a bootloader
      den.aspects.workstation   # role: core, users, greeter, audio, secrets, ...
      den.aspects.niri          # system side: enables the compositor
    ];

    # User layers. Without these the user has only the base layer
    # (shells, CLI tools, git).
    provides.to-users.includes = [
      den.aspects.ada-desktop
      den.aspects.ada-dev
      den.aspects.niri          # home side: binds, workspaces, idle
    ];

    nixos =
      { pkgs, ... }:
      {
        imports = [
          ../hosts/<name>/hardware.nix
          inputs.niri.nixosModules.niri
        ];

        system.stateVersion = "<release>";
        home-manager.sharedModules = [ { home.stateVersion = "<release>"; } ];

        # nixpkgs niri rather than the niri-flake build
        programs.niri.package = pkgs.niri;

        hardware.graphics.enable = true;
      };
  };
}
```

**Niri needs three lines, not one.** The `workstation` role
deliberately leaves the compositor out. A host must (a) import
`inputs.niri.nixosModules.niri`, (b) include `den.aspects.niri`, and
(c) forward `den.aspects.niri` to its users. The greeter
(`modules/desktop/greetd.nix`) offers a session only for a compositor
the host has enabled, so a host without (a) and (b) boots to a greeter
with no session to start. Without (c) the session starts with none of
this configuration's bindings, workspaces or idle handling. Both
existing hosts also set `programs.niri.package = pkgs.niri;`; the
reason is in the comment beside it in `modules/host-yarrow.nix`.

**The state versions are per host.** Set `system.stateVersion` and the
users' `home.stateVersion` to the NixOS release the machine is
installed with, and never change them afterwards. Do not copy
the value from another host. To find the current release of the
flake's nixpkgs pin:

```bash
nix eval --raw .#nixosConfigurations.fern.config.system.nixos.release
```

The `configuration.nix` that `nixos-generate-config` writes on the new
machine carries the same value. `modules/defaults.nix` holds only a
fallback.

**Roles and extras.** Add what the machine is for:

| Add | For |
| --- | --- |
| `den.aspects.laptop` | Battery-powered machines; also forward `brightness-backlight` and `idle-suspend` to users |
| `den.aspects.dev-machine` | Development machines |
| `den.aspects.tailscale` | Tailnet membership (one-time `sudo tailscale up` after install) |
| `den.aspects.audio-studio` or `den.aspects.audio-laptop` | Audio beyond the base stack |
| `den.aspects.gaming` and forwarded `gaming-hm` | Steam and game tooling |
| A `nixos-hardware` module in `imports` | Model-specific quirks |

Kernel choice, `hardware.graphics.enable`, udev rules and other facts
true of this hardware alone go in the host aspect's `nixos` block.
Anything a second machine could want belongs in a role or a shared
aspect instead. The [Aspect Index](../reference/aspect-index.md) lists
everything available.

A headless host would take `den.aspects.server` instead of
`workstation`, and no `provides.to-users`. That role is not used by any
host yet; its file lists what it still lacks.

## 3. Hardware file

`hosts/<name>/hardware.nix` is generated on the machine and never
edited by hand:

```bash
sudo nixos-generate-config --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix hosts/<name>/hardware.nix
```

To let the flake evaluate before the machine exists, commit a
placeholder that declares the root and boot filesystems and
`nixpkgs.hostPlatform`, and replace the whole file with the generated
one during installation. `hosts/yarrow/hardware.nix` is such a
placeholder until yarrow is installed.

## 4. deadnix exclusion

Generated hardware files contain unused bindings that must not be
"fixed". Add the new path to the `--exclude` list of the `deadnix`
recipe in the `justfile`, or `just lint` fails.

## 5. Secrets registration

The `workstation` role includes the `secrets` aspect, which decrypts
with the machine's SSH host key. A host that is not a registered
recipient fails at activation, on purpose.

On a fresh install this has an ordering consequence: the host key must
exist and be registered **before** the first `nixos-install`, which is
before the machine has ever booted. Generate it by hand into the target
filesystem from the installer, convert it to an age recipient, add it
to `.sops.yaml`, re-key, and commit. Only then install from that
commit.

The commands are in
[SOPS-nix: Registering a new machine](../security/sops-nix.md#registering-a-new-machine),
and [Installing yarrow](../machines/installing-yarrow.md#2-create-the-host-key-and-register-it-for-secrets)
shows them in sequence with the rest of an install.

## 6. Stage, check, install

```bash
git add modules/host-<name>.nix hosts/<name>/hardware.nix
just fmt
just check
nix eval .#nixosConfigurations.<name>.config.system.build.toplevel.drvPath
```

`git add` matters: an unstaged host aspect or hardware file is
invisible to the flake. The `nix eval` line confirms the new host
evaluates to a system without building it.

Install from the installer with `nixos-install --flake .#<name>`.
After the first boot `nh` is present, the hostname matches, and the
`just` recipes work as on any other host.

After install:

- Add the machine's page under `book/src/machines/` and its rows to
  the [Aspect Index](../reference/aspect-index.md).
- Update the machine list in `CLAUDE.md`.

## Adding a standalone home

A machine that runs another distribution gets a Home Manager
configuration only. The [work laptop](../machines/work-laptop.md) is
the one instance and its page is the reference; the shape is:

1. **Topology.** A `den.homes.<system>."<user>@<hostname>"` entry in
   `modules/hosts.nix` with `aspect = "ada"`, so a different login name
   still maps onto the `ada` aspect. The key matches
   `whoami@hostname`, which lets `home-manager switch --flake` select
   it without an argument. The existing entry also overrides `pkgs`
   (to get the flake's overlays and unfree packages) and `instantiate`
   (to pass `inputs` to Home Manager modules); a new home needs both.
2. **A layer.** There is no host aspect to forward layers, so the user
   aspect provides one keyed by hostname:
   `den.aspects.ada.provides."<hostname>".includes = [ ... ];`. See
   [Aspects & Composition](../architecture/aspects.md#provideshostname-for-standalone-homes).
3. **Only `homeManager` sides apply.** Every `nixos` side in the
   included aspects is ignored, so anything a NixOS host gets from the
   system (compositor module, fonts, Docker daemon, GL drivers) needs a
   home-level substitute. Those live in `modules/foreign/` and
   `modules/desktop/niri-standalone.nix`.
4. **Apply** with `home-manager switch --flake ~/src/fern` on that
   machine. No sops registration is involved: the `secrets` aspect is
   system-side.

## Key files

| File | Purpose |
| --- | --- |
| `modules/hosts.nix` | Topology: `den.hosts` and `den.homes` |
| `modules/host-*.nix` | Host aspects |
| `modules/roles/*.nix` | Roles a host composes |
| `modules/defaults.nix` | Fallback `stateVersion`, hostname and user batteries |
| `hosts/*/hardware.nix` | Generated hardware configuration |
| `justfile` | `deadnix` exclusion list |
| `.sops.yaml` | Secret recipients |
