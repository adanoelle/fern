# fern

> fern is the x86_64 desktop workstation: an AMD machine with studio
> audio interfaces, the Niri + garden desktop with a Hyprland fallback
> session, the full development toolchain, Steam, and the always-on
> homelab services. Its host aspect is `den.aspects.fern` in
> `modules/host-fern.nix`, which is composition only: roles, the user
> layers it forwards, and the facts that are true of this hardware alone.

| | |
| --- | --- |
| Topology | `den.hosts.x86_64-linux.fern.users.ada` (`modules/hosts.nix`) |
| Flake output | `nixosConfigurations.fern` |
| Status | installed, in daily use |
| `system.stateVersion` | `"25.11"`, the release it was installed with; never bumped |

## What the host includes

These are the `includes` of `den.aspects.fern`: system-side aspects and
roles. What a role or aspect means is in
[Aspects](../architecture/aspects.md).

| Include | What it brings | Why here |
| --- | --- | --- |
| `boot` | systemd-boot, EFI variables writable (`modules/boot.nix`) | UEFI x86 machine |
| `workstation` (role) | `core`, `nh`, `users`, `secrets-guard`, `secrets`, `greetd`, `fonts`, `audio`, `bluetooth`, `docker` | the set every graphical x86 machine shares |
| `audio-studio` | musnix and a pinned low PipeWire quantum, on top of `audio` | mains-powered machine with dedicated interfaces; see [Audio](../services/audio.md) |
| `dev-machine` (role) | `aws-cli` | host-level developer services; see [Containers and cloud](../services/containers-and-cloud.md) |
| `homelab` (role) | `tailscale` (routing features on), `radicale` | fern is the always-on machine; see [Homelab](../services/homelab.md) |
| `monitoring` | `lm_sensors`, `s-tui`, `stress-ng`, a sensor log timer | see [Sensors](#sensors) below |
| `gaming` | Steam, Gamescope, GameMode, controller modules | see [Gaming](../services/gaming.md) |
| `niri` | `programs.niri.enable`, upower, xwayland-satellite, quickshell, portals | primary session; see [Niri](../desktop/niri.md) |
| `teams` | `teams-for-linux` as a system package | calls from the desktop |

The pieces of the `workstation` role are documented in
[Defaults, core and users](../architecture/defaults-core-users.md),
[sops-nix](../security/sops-nix.md),
[Secret guard](../security/secret-guard.md),
[Audio](../services/audio.md) and
[Containers and cloud](../services/containers-and-cloud.md). The role
itself is `modules/roles/workstation.nix`.

## User layers it forwards

`provides.to-users.includes` adds these to `ada` on fern, on top of the
base `ada` aspect that every machine gets
(`modules/user-ada.nix`: CLI tools, git, shells).

| Layer | What it brings | Why here |
| --- | --- | --- |
| `ada-desktop` | the `desktop-apps` bundle (Zen, Chromium, screenshot tools, imv, PDF tools, Bitwarden) and the garden terminal stack | every graphical machine; see [Browsers](../desktop/browsers.md), [Garden](../desktop/garden.md), [Terminals](../terminal/terminals.md), [Password manager](../security/password-manager.md) |
| `ada-dev` | the `devtools` bundle: [Rust](../toolchains/rust.md), [Node/TypeScript](../toolchains/typescript-node.md), [C/C++](../toolchains/c-cpp.md), [Python](../toolchains/python.md), and [Ada, Zig and the VM host](../toolchains/other.md) | development machine |
| `niri` | the Niri settings, keybinds and idle lock | forwarded by the host, not by the desktop bundle, because its options exist only where the niri-flake module is imported |
| `brightness-ddc` | brightness keys through `ddcutil` (DDC/CI); its system side enables `hardware.i2c` | external monitors have no sysfs backlight |
| `ada-hyprland` | the Hyprland session and its settings | fallback session; see [Hyprland](../desktop/hyprland.md) |
| `obs` | OBS Studio with capture plugins | streaming and recording |
| `gaming-hm` | MangoHud, ProtonUp-Qt, Lutris, Protontricks | user side of gaming |
| `music` | DAWs (`daw`) and the plugin and synth collection (`audio-tools`) | the studio machine; see [Audio](../services/audio.md) |
| `gamedev` | game libraries and tools | see [Gamedev and art](../gamedev/gamedev-and-art.md) |

fern does not forward the `art`, `game-audio`, `wallpaper`,
`brightness-backlight` or `idle-suspend` aspects. In particular the
painted wallpaper ([Wallpaper](../desktop/wallpaper.md)) is included
only by the work-laptop layer today, so fern's Niri session does not
have it.

`obs` builds OBS with `cudaSupport = true` (`modules/desktop/obs.nix`),
although fern's GPU is AMD.

## Hardware facts in the host aspect

Everything below is in the `nixos` block of `modules/host-fern.nix`.
`hosts/fern/hardware.nix` is the generated file (filesystems, initrd
modules, `kvm-amd`, AMD microcode) and is never edited by hand.

| Setting | Value | Reason |
| --- | --- | --- |
| `boot.kernelPackages` | `pkgs.linuxPackages_zen` | low-latency kernel for audio work |
| `boot.kernelParams` | `iommu=pt` | AMD IOMMU passthrough, so DMA remapping does not interfere with USB audio |
| `boot.kernelModules` | `nct6775` | the motherboard's Super-I/O sensor chip, read by `lm_sensors` |
| `hardware.graphics.enable` | `true` | AMD GPU on Mesa; no proprietary driver |
| `programs.niri.package` | `pkgs.niri` | nixpkgs build instead of the niri-flake one |
| `programs.hyprland.enable` | `true` | makes the fallback session available |
| System packages | `mesa-demos`, `vulkan-tools`, `firefox` | `glxinfo`, `vulkaninfo`, a second browser |

The host also imports `inputs.niri.nixosModules.niri`. That module must
be imported once per host, which is why it is here and not in the
`niri` aspect.

### Graphics

The GPU needs nothing beyond `hardware.graphics.enable`: the kernel's
amdgpu driver and Mesa (RADV for Vulkan) come with it. Check with
`glxinfo -B` and `vulkaninfo --summary`. The greeter is tuigreet, a TTY
greeter, because a graphical one corrupted on this machine's integrated
GPU (`modules/desktop/greetd.nix`).

### USB audio

The layers (`audio`, `audio-studio`, `music`) are explained in
[Audio](../services/audio.md). The host adds only what is specific to
the devices on this desk:

- **udev rules** for the Audient iD24 (`2708:4002`) and a Topping DAC
  (`152a:8750`): a `/dev/audio/...` symlink each, and USB autosuspend
  turned off. The Topping ID is marked unverified in the module.
- **Interface priorities**: a WirePlumber rule
  (`10-default-nodes`) gives both interfaces `priority.session = 2000`
  so they win the default-device election.
- **`musnix.rtirq`**: enabled with `nameList = "usb snd"` and
  `prioHigh = 90`, raising the realtime priority of USB and sound IRQ
  threads. The musnix module itself is imported by `audio-studio`.

### Sensors

The `monitoring` aspect (`modules/monitoring.nix`) installs
`lm_sensors`, `s-tui` and `stress-ng`, and runs a `sensor-logger` timer
every 30 seconds that appends `sensors` output to
`/var/log/sensors.log` (rotated to `.old` at 10 MB). The sensor chip
module is a per-machine fact, which is why `nct6775` is loaded by the
host aspect and not by `monitoring`.

## The Hyprland fallback

fern offers two sessions in the greeter, Niri first. Hyprland needs two
things, both present here: `programs.hyprland.enable = true` on the
host, and the `ada-hyprland` user layer. Its configuration is described
in [Hyprland](../desktop/hyprland.md).

## Rebuilding

`just test`, then `just switch`, from a checkout on fern. The recipes
and the rest of the routine are in
[Day to day](../operations/day-to-day.md).

## Key files

| File | Purpose |
| --- | --- |
| `modules/host-fern.nix` | host aspect: includes, forwarded layers, hardware facts |
| `modules/hosts.nix` | topology entry |
| `hosts/fern/hardware.nix` | generated hardware configuration |
| `modules/roles/workstation.nix`, `dev-machine.nix`, `homelab.nix` | the roles fern takes |
| `modules/user-ada-desktop.nix`, `user-ada-dev.nix`, `user-ada-hyprland.nix` | forwarded user layers |
| `modules/monitoring.nix` | sensor tools and log timer |
