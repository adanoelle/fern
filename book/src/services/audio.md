# Audio & PipeWire

> PipeWire handles all audio. A base layer gives every machine working
> sound; a studio layer adds low-latency tuning for the recording
> workstation; device rules live with the host that owns the hardware.

## Layers

| Aspect         | File                             | Side | Goes on                         |
| -------------- | -------------------------------- | ---- | ------------------------------- |
| `audio`        | `modules/audio/audio.nix`        | nixos | every graphical host (via the `workstation` role) |
| `audio-studio` | `modules/audio/audio-studio.nix` | nixos | mains-powered recording machines (fern) |
| `music`        | `modules/audio/music.nix`        | home  | hosts where music is made (via `ada-desktop`) |
| device rules   | `modules/host-*.nix`             | nixos | the host that owns the hardware |

A laptop takes `audio` only. Adding `audio-studio` or `music` later is a
one-line include on that host.

## Base: `audio`

PipeWire with all three front ends, realtime scheduling through rtkit, and
the everyday tools. No latency tuning and no hardware facts.

| Backend    | Purpose                                         |
| ---------- | ----------------------------------------------- |
| ALSA       | Direct hardware access, 32-bit compatibility    |
| PulseAudio | Compatibility with PulseAudio applications      |
| JACK       | Low-latency audio for professional applications |

| Package       | Purpose                         |
| ------------- | ------------------------------- |
| `pavucontrol` | PulseAudio volume control (GUI) |
| `qpwgraph`    | PipeWire graph editor (GUI)     |
| `easyeffects` | Audio effects processor         |
| `pulsemixer`  | Terminal audio mixer            |
| `audacity`    | Audio editor                    |

`audio` group membership is granted in `modules/users.nix` whenever
PipeWire is enabled.

## Studio: `audio-studio`

Includes `audio` and trades power for latency:

- **musnix** — `performance` CPU governor, threaded IRQs, realtime limits
  for the `audio` group, and the `rtcqs` checker
- **Pinned quantum** — 64 frames at 48 kHz (about 1.3 ms), minimum 32,
  maximum 128. The cap applies to all playback, including browsers and
  Bluetooth
- **No suspend** — ALSA devices are never suspended

```nix
extraConfig.pipewire."10-lowlatency" = {
  "context.properties" = {
    "default.clock.rate"        = 48000;
    "default.clock.quantum"     = 64;
    "default.clock.min-quantum" = 32;
    "default.clock.max-quantum" = 128;
  };
};
```

Do not put this on a laptop. There, force a small quantum for one session
instead:

```bash
pw-metadata -n settings 0 clock.force-quantum 128   # studio mode on
pw-metadata -n settings 0 clock.force-quantum 0     # back to default
```

## fern's devices

`modules/host-fern.nix` holds the hardware facts: udev rules that symlink
the Audient iD24 and Topping DAC and disable USB autosuspend for them,
`musnix.rtirq` priorities for USB audio, and WirePlumber rules giving both
devices session priority 2000 so they are chosen over built-in audio.

## Music: `music`

A home-manager layer bundling the DAWs (`daw`: Ardour, REAPER) and the
plugin and synth collection (`audio-tools`). It is included by the
`ada-desktop` user layer.

## Key files

| File                             | Purpose                                              |
| -------------------------------- | ---------------------------------------------------- |
| `modules/audio/audio.nix`        | PipeWire, rtkit, tools (`den.aspects.audio`)         |
| `modules/audio/audio-studio.nix` | musnix, low-latency quantum, no-suspend              |
| `modules/audio/music.nix`        | DAWs + plugins bundle                                |
| `modules/audio/daw.nix`          | Ardour, REAPER                                       |
| `modules/audio/audio-tools.nix`  | Plugins, synths, samplers, sox/ffmpeg                |
| `modules/host-fern.nix`          | fern's interface rules and IRQ priorities            |
| `modules/bluetooth.nix`          | BlueZ and Bluetooth codec preference                 |
