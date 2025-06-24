# fern

My NixOS configuration

## Design decisions

* **flake-parts** powers the flake.  Inputs are pinned to `nixos-unstable` and
  `home-manager`, providing a clean way to manage modules and outputs.
* Host definitions live under `hosts/` while reusable modules are kept in
  `modules/`, allowing each host to mix and match only the pieces it needs.
* A `workspace` module keeps `$HOME` tidy by overriding the XDG user
  directories so unwanted folders are not created automatically.
* The `audio` module enables PipeWire with EasyEffects and disables the legacy
  PulseAudio service.
* `graphics` configures the NVIDIA driver and sets up Hyprland via `greetd` for
  a Wayland desktop.
* Development tooling for Rust is provided through the `devtools` module and a
  custom Rust overlay in `overlays/rust-toolchain.nix`.
* Home Manager manages the `ada` user environment alongside the system
  configuration.
