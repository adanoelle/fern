# Other toolchains: Ada, Zig, VMs

> Three small aspects in the `devtools` bundle: the Ada toolchain
> (`ada-lang`), Zig, and `vm-host`, which provides quickemu for running
> desktop virtual machines.

**Goes on:** fern, yarrow, work laptop (through the `devtools` bundle in
the `ada-dev` user layer). Per-aspect differences on the work laptop are
noted below.

## Ada (`ada-lang`)

`modules/devtools/ada.nix`. The aspect is named `ada-lang` because
`ada-*` names are reserved for the user's layers
(see [Aspects](../architecture/aspects.md)).

| Side         | What it sets |
| ------------ | ------------ |
| NixOS        | `gnat13`, `gprbuild`, `alire`; `ADA_PROJECT_PATH="$HOME/.config/ada_project_path"` |
| home-manager | `alire`; Helix language server `ada_ls` (command `ada_language_server`) for the `ada` language |

- The compiler and `gprbuild` are on the NixOS side only, so the work
  laptop gets Alire alone.
- `ADA_PROJECT_PATH` is likewise NixOS-only. Nothing in the repository
  creates the directory it names.
- No module installs `ada_language_server`, and the pinned nixpkgs has
  no package for it, so the Helix entry has no effect until the binary
  is put on `PATH` by other means.
- `gnat13` is x86_64-only, one of the reasons [moss](../machines/moss.md)
  is parked.

## Zig

`modules/devtools/zig.nix` is home-manager only and installs `pkgs.zig`
from the shared pin. There is no language server and no Helix
configuration in the aspect.

## Virtual machines (`vm-host`)

`modules/devtools/vm-host.nix` is home-manager only and installs
[quickemu](https://github.com/quickemu-project/quickemu), which runs
QEMU as the user with KVM, UEFI and a software TPM. No libvirt daemon is
involved. The aspect only makes the tool available; VM recipes belong to
the projects that need them.

Things that are not obvious:

- **GL wrapping.** The package is passed through
  `config.lib.nixGL.wrap`, because QEMU's SDL window needs the host GL
  driver on a non-NixOS system. On NixOS the wrapper is a no-op. The
  nixGL setup itself is in `modules/foreign/ubuntu-desktop.nix`
  (see [Work laptop](../machines/work-laptop.md)).
- **`/dev/kvm`.** No group membership is configured: NixOS's default
  udev rule makes the device world-accessible, and Ubuntu grants it to
  the logged-in user through an ACL.
- **Shared folders.** quickemu shares `XDG_PUBLICSHARE_DIR` with a guest
  unless the VM's `.conf` sets `public_dir`. This configuration points
  that variable at the home directory
  (see [Home directory](../reference/home-directory.md)), so always set
  `public_dir` in a VM's `.conf`, to a real directory or to `"none"`.

## Key files

| File                           | Purpose                              |
| ------------------------------ | ------------------------------------ |
| `modules/devtools/ada.nix`     | `ada-lang` aspect                    |
| `modules/devtools/zig.nix`     | `zig` aspect                         |
| `modules/devtools/vm-host.nix` | `vm-host` aspect (quickemu)          |
| `modules/devtools/bundle.nix`  | Includes all three in `devtools`     |
