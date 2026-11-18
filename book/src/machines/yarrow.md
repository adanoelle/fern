# yarrow

> yarrow is a Framework Laptop 13 Pro: the portable art,
> game-development and playtesting machine. It takes the same
> `workstation` role as fern plus a `laptop` role, runs Niri only, and
> leaves out fern's studio audio, homelab services and heavier user
> layers. Its host aspect is `den.aspects.yarrow` in
> `modules/host-yarrow.nix`.

| | |
| --- | --- |
| Topology | `den.hosts.x86_64-linux.yarrow.users.ada` (`modules/hosts.nix`) |
| Flake output | `nixosConfigurations.yarrow` (evaluates today) |
| Status | **not installed yet** |
| `system.stateVersion` | `"26.11"`; never bumped once installed |

## Status

The configuration is complete and evaluates, but the machine has not
been installed:

- `hosts/yarrow/hardware.nix` is a placeholder (ext4 root and a `/boot`
  by label) so the flake evaluates. The install replaces it with the
  generated file.
- yarrow is not yet a sops recipient. `.sops.yaml` has a commented
  `host_yarrow` line; the host key is created and registered during the
  install, before the first build.

Both are steps in [Installing yarrow](installing-yarrow.md).

## What the host includes

| Include | What it brings | Why here |
| --- | --- | --- |
| `boot` | systemd-boot (`modules/boot.nix`) | UEFI x86 machine |
| `workstation` (role) | `core`, `nh`, `users`, `secrets-guard`, `secrets`, `greetd`, `fonts`, `audio`, `bluetooth`, `docker` | same graphical base as [fern](fern.md) |
| `laptop` (role) | power profiles, zram swap, firmware updates | battery-powered machine; see below |
| `dev-machine` (role) | `aws-cli` | see [Containers and cloud](../services/containers-and-cloud.md) |
| `tailscale` | Tailscale as a plain client | reach the tailnet from anywhere; the routing features stay with the [homelab](../services/homelab.md) role on fern |
| `audio-laptop` | a noise-suppressed virtual microphone and `studio-mode` | see [Audio](../services/audio.md) |
| `gaming` | Steam, Gamescope, GameMode | playtesting; see [Gaming](../services/gaming.md) |
| `niri` | the Niri session | see [Niri](../desktop/niri.md) |

### The laptop role

`modules/roles/laptop.nix` sets three things, each with `mkDefault`:

| Option | Effect |
| --- | --- |
| `services.power-profiles-daemon.enable` | balanced / power-saver / performance, switched with `powerprofilesctl` |
| `zramSwap.enable` | compressed swap in RAM; there is no swap partition and no hibernation |
| `services.fwupd.enable` | firmware updates through LVFS (`fwupdmgr update`) |

Lid-close suspend is the logind default and is not configured. Model
quirks come from the nixos-hardware import, not from the role.

## User layers it forwards

| Layer | What it brings | Why here |
| --- | --- | --- |
| `desktop-apps` | the core desktop applications | every graphical host |
| `garden.shell` | the whole garden shell: QML, settings, screenshot tools, and the terminal theming it includes | the niri aspect only launches the shell. yarrow takes these two instead of `ada-desktop`, which carries `garden.terminal` alone; including both doubles kitty's theme include |
| `ada-dev` | the `devtools` bundle (Rust, Node/TypeScript, C/C++, Python, Ada, Zig, VM host) | development machine |
| `niri` | Niri settings, keybinds, and the lock after 10 idle minutes | the host imports the niri-flake module |
| `brightness-backlight` | brightness keys through `brightnessctl` on the panel's sysfs backlight, never below 1% | built-in panel |
| `idle-suspend` | a second idle timeout: suspend after 20 minutes, only when no mains supply is online | battery; a long build on the charger is not interrupted |
| `art` | Krita, Aseprite, Inkscape, GIMP | what the machine is for; see [Gamedev and art](../gamedev/gamedev-and-art.md) |
| `gamedev` | game libraries and tools | same page |
| `game-audio` | trackers, a sound-effect tool, REAPER, `ffmpeg`, `sox` | the light audio set; same page |
| `gaming-hm` | MangoHud, ProtonUp-Qt, Lutris, Protontricks | user side of gaming |

## Hardware facts in the host aspect

| Setting | Value | Reason |
| --- | --- | --- |
| nixos-hardware module | `framework-intel-core-ultra-series3` | model quirks maintained upstream |
| `boot.kernelPackages` | `pkgs.linuxPackages_latest` | graphics, audio and power support for this platform is still landing upstream |
| `hardware.graphics.enable` | `true` | Intel graphics on Mesa |
| `services.fprintd.enable` | `false` | see below |
| `programs.niri.package` | `pkgs.niri` | nixpkgs build, as on fern |
| System packages | `mesa-demos`, `vulkan-tools` | `glxinfo`, `vulkaninfo` |

The nixos-hardware module is where the Intel specifics come from. In
the evaluated configuration it contributes, among other things, the
`i915` module in the initrd, the `nvme.noacpi=1` kernel parameter and
fwupd. It only asks for the latest kernel when the default one is too
old; the host aspect asks for it unconditionally.

`studio-mode on` forces 48 kHz and a small buffer while an audio
interface is plugged in, and `studio-mode off` releases it. It is part
of `audio-laptop`; see [Audio](../services/audio.md).

## What it deliberately leaves out

| Left out | Why | To add it |
| --- | --- | --- |
| OBS | `modules/desktop/obs.nix` builds OBS with CUDA support, which this machine does not want | change that build first, then forward `obs` |
| Full `music` layer | `game-audio` is the light set a laptop can take alone; the DAWs and plugin collection can follow later | one line in `provides.to-users.includes` |
| `audio-studio` | it trades power for latency (performance governor, pinned quantum) | not for a machine on battery; use `studio-mode` |
| Fingerprint reader | nixos-hardware turns `fprintd` on; it is forced off until it has been tried with tuigreet and the garden lock screen, where PAM would wait on the reader before accepting a password | remove the `services.fprintd.enable = false` line, then `fprintd-enroll` |
| `homelab`, `monitoring`, `teams` | fern's roles and extras | — |
| Painted wallpaper | the `wallpaper` aspect is included only by the work-laptop layer today | forward `wallpaper`; see [Wallpaper](../desktop/wallpaper.md) |

## Rebuilding

Once installed: `just test`, then `just switch`, as on any NixOS host.
See [Day to day](../operations/day-to-day.md).

## Key files

| File | Purpose |
| --- | --- |
| `modules/host-yarrow.nix` | host aspect: includes, forwarded layers, hardware facts |
| `modules/roles/laptop.nix` | the laptop role |
| `modules/desktop/brightness-backlight.nix` | backlight keys |
| `modules/desktop/idle-suspend.nix` | suspend when idle on battery |
| `modules/audio/audio-laptop.nix` | virtual microphone and `studio-mode` |
| `hosts/yarrow/hardware.nix` | placeholder until the install |
