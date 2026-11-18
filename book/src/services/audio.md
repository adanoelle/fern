# Audio and Bluetooth

> PipeWire handles all audio. A base aspect gives every NixOS machine
> working sound; a studio aspect adds low-latency tuning for the
> recording workstation; a laptop aspect adds a noise-suppressed
> microphone and an on-demand small buffer. Music software arrives as
> separate user layers, and rules for specific devices live with the
> host that owns the hardware.

**Goes on:** fern (`audio` + `audio-studio`), yarrow (`audio` +
`audio-laptop`). The work laptop takes only the `audio-tools` user
layer; its sound stack is Ubuntu's and is not configured here.

## Layers

| Aspect         | File                             | Side  | Reached through                        |
| -------------- | -------------------------------- | ----- | -------------------------------------- |
| `audio`        | `modules/audio/audio.nix`        | nixos | the `workstation` role (fern, yarrow)  |
| `audio-studio` | `modules/audio/audio-studio.nix` | nixos | `host-fern.nix`                        |
| `audio-laptop` | `modules/audio/audio-laptop.nix` | nixos | `host-yarrow.nix`                      |
| `bluetooth`    | `modules/bluetooth.nix`          | nixos | the `workstation` role (fern, yarrow)  |
| `music`        | `modules/audio/music.nix`        | home  | fern's user layers                     |
| `daw`          | `modules/audio/daw.nix`          | home  | `music`                                |
| `audio-tools`  | `modules/audio/audio-tools.nix`  | home  | `music`; `ada-work` (work laptop)      |
| `game-audio`   | `modules/audio/game-audio.nix`   | home  | yarrow's user layers                   |
| device rules   | `modules/host-fern.nix`          | nixos | fern only                              |

## Base: `audio`

PipeWire with its ALSA (including 32-bit), PulseAudio and JACK front
ends, realtime scheduling through rtkit, and the everyday tools:
`pavucontrol`, `pulsemixer`, `qpwgraph`, `easyeffects`, `audacity`. It
carries no latency tuning and no hardware facts, so it is safe on a
laptop running on battery.

Membership of the `audio` group is granted in `modules/users.nix`
whenever PipeWire is enabled; see
[Defaults, core and users](../architecture/defaults-core-users.md).

The aspect's module carries a `key` because fern reaches it twice (the
`workstation` role and `audio-studio`); the reason is explained under
[Homelab](homelab.md#the-diamond-include-key-pattern).

## Studio: `audio-studio`

Includes `audio` and trades power for latency. It is meant for a
mains-powered machine with a dedicated interface.

| Setting            | Value                                                |
| ------------------ | ---------------------------------------------------- |
| musnix             | enabled, with the `rtcqs` checker                    |
| PipeWire clock     | 48 kHz; quantum 64, minimum 32, maximum 128 frames   |
| pipewire-pulse     | default request 64, minimum 32, maximum 128 frames; quantum minimum 32, maximum 128 (all at 48 kHz) |
| ALSA node suspend  | disabled (`session.suspend-timeout-seconds = 0`)     |

The quantum cap is global: it also applies to browser and Bluetooth
playback. The pipewire-pulse block applies the same limits to
PulseAudio clients, which would otherwise ask for larger buffers.

The musnix NixOS module is imported by this aspect, so a host that
includes it can set further `musnix.*` options; fern does (below).

## Laptop: `audio-laptop`

Adds two things on top of `audio` and no latency tuning.

**A noise-suppressed microphone.** A PipeWire filter chain running the
RNNoise LADSPA plugin, exposed as an extra source named
"Noise-suppressed microphone". The default input device is not changed;
pick the source in the application that should use it.

**`studio-mode`.** A command that forces a small buffer while an
interface is plugged in for recording, and releases it afterwards:

```bash
studio-mode on        # force 48 kHz and a 128-frame quantum
studio-mode on 64     # same, with a different quantum
studio-mode off       # back to PipeWire's defaults
studio-mode status    # show the forced values (the default action)
```

It sets `clock.force-rate` and `clock.force-quantum` through
`pw-metadata`, so the change lasts until `studio-mode off` or until
PipeWire restarts.

## Bluetooth: `bluetooth`

BlueZ is enabled and powered on at boot, with `Experimental` (battery
reporting for headsets that support it) and `FastConnectable` set. A
WirePlumber rule for all Bluetooth cards auto-connects the A2DP sink
profile and sets the codec preference to AAC, then SBC-XQ, then SBC.

## Music software

| Layer         | Contents                                              | Machines            |
| ------------- | ----------------------------------------------------- | ------------------- |
| `music`       | `daw` + `audio-tools`                                 | fern                |
| `daw`         | Ardour, REAPER                                        | fern (via `music`)  |
| `audio-tools` | plugin suites, synths, samplers, `a2jmidid`, `sox`, `ffmpeg` | fern (via `music`), work laptop |
| `game-audio`  | FamiStudio, Furnace, sfxr-qt, REAPER, `sox`, `ffmpeg` | yarrow              |

`game-audio` is the light set for writing game music and effects, kept
separate so a laptop can take it without the full `music` layer; it is
described with the rest of the game tooling in
[Game development and art](../gamedev/gamedev-and-art.md). yarrow does
not take `music`; adding it is one more entry in the user-layer list in
`modules/host-yarrow.nix`.

The package lists are in the files; `carla` is commented out of
`audio-tools` with a note that its build is currently broken.

## fern's devices

The hardware facts live in `modules/host-fern.nix`, not in the audio
aspects: udev rules that create `/dev/audio/*` symlinks for the two
USB interfaces and turn off USB autosuspend for them, `musnix.rtirq`
priorities for USB audio, and a WirePlumber rule that raises both
devices' session priority so they are chosen over on-board audio. See
[fern](../machines/fern.md).

## Key files

| File                             | Purpose                                     |
| -------------------------------- | ------------------------------------------- |
| `modules/audio/audio.nix`        | PipeWire, rtkit, mixer and patchbay tools   |
| `modules/audio/audio-studio.nix` | musnix, low-latency quantum, no suspend     |
| `modules/audio/audio-laptop.nix` | RNNoise virtual microphone, `studio-mode`   |
| `modules/bluetooth.nix`          | BlueZ and Bluetooth codec preference        |
| `modules/audio/music.nix`        | `daw` + `audio-tools`                       |
| `modules/audio/daw.nix`          | Ardour, REAPER                              |
| `modules/audio/audio-tools.nix`  | Plugins, synths, samplers, utilities        |
| `modules/audio/game-audio.nix`   | Trackers and sound-effect tools             |
| `modules/host-fern.nix`          | fern's interface rules and IRQ priorities   |
