# moss

> moss is an Apple Silicon laptop meant to run NixOS through Asahi. It
> is **parked**: its topology line is commented out, so there is no
> `nixosConfigurations.moss` and nothing here is built or tested. The
> host aspect and the two Asahi aspects are kept for the day it comes
> back.

## Why it is parked

The reasons are recorded next to the commented line in
`modules/hosts.nix`:

- `hosts/moss/hardware.nix` is still the installer placeholder: it sets
  the platform to `aarch64-linux` and declares no filesystems.
- Some aspects pull packages that exist only for x86_64. The comment
  names `gnat13`, `ldtk` and `renderdoc`. `gnat13` comes from the Ada
  toolchain in the `devtools` bundle, which moss would get through
  `ada-dev`. `ldtk` and `renderdoc` are in the `gamedev` aspect, which
  moss does not forward.

Because the host is not in the topology, none of this is evaluated;
other packages may fail on aarch64 as well.

## What is still in the tree

`modules/host-moss.nix` defines `den.aspects.moss`. It keeps an explicit
aspect list and does not use the `workstation` role.

| Part | Contents |
| --- | --- |
| Host includes | `boot-asahi`, `core`, `docker`, `users`, `audio`, `graphics-asahi`, `greetd`, `secrets`, `secrets-guard` |
| Forwarded user layers | `ada-desktop`, `ada-dev` |
| Imports | `hosts/moss/hardware.nix` and the `apple-silicon-support` module from the `nixos-apple-silicon` flake input |
| `system.stateVersion` | `"25.11"` |

Compared with the `workstation` role it lacks `nh`, `fonts` and
`bluetooth`. It does not include `niri` or import the niri-flake
module, so as written it has no graphical session: it used the
Hyprland session, which has been removed from this flake.

The two Asahi aspects are in `modules/asahi/`:

| Aspect | File | What it sets |
| --- | --- | --- |
| `boot-asahi` | `boot.nix` | systemd-boot with `canTouchEfiVariables = false` |
| `graphics-asahi` | `graphics.nix` | `mesa-demos` and `vulkan-tools` |

`graphics-asahi` no longer sets any Asahi GPU driver options: the
driver is in mainline Mesa, so only the two diagnostic packages
remain.

## What re-enabling it would take

1. Install NixOS on the machine and replace `hosts/moss/hardware.nix`
   with the generated file.
2. Gate the x86_64-only packages by platform, starting with the ones
   named above, and evaluate the host to find the rest.
3. Uncomment `den.hosts.aarch64-linux.moss.users.ada` in
   `modules/hosts.nix`.
4. Register the host key as a sops recipient before the first build
   (`.sops.yaml` has a commented `host_moss` line); see
   [sops-nix](../security/sops-nix.md).
5. Give it a session: import the niri-flake module and forward `niri`
   (and `garden.shell` or `screenshot`), as `modules/host-yarrow.nix`
   does. Moving it to the `workstation` role at the same time is the
   simpler route; see [Adding a host](../operations/adding-a-host.md).

## Key files

| File | Purpose |
| --- | --- |
| `modules/hosts.nix` | the commented topology line and the reasons |
| `modules/host-moss.nix` | host aspect |
| `modules/asahi/boot.nix`, `modules/asahi/graphics.nix` | Asahi aspects |
| `hosts/moss/hardware.nix` | installer placeholder |
