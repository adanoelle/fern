# Audio & PipeWire

> PipeWire handles all audio with low-latency settings, ALSA/PulseAudio/JACK
> compatibility, and priority routing for the Audient iD24 interface.

The audio subsystem is configured in a single NixOS module
(`nix/modules/audio.nix`) that sets up PipeWire as the audio server with
compatibility layers for applications expecting ALSA, PulseAudio, or JACK.

## PipeWire configuration

All audio backends are enabled:

| Backend    | Purpose                                         |
| ---------- | ----------------------------------------------- |
| ALSA       | Direct hardware access, 32-bit compatibility    |
| PulseAudio | Compatibility with PulseAudio applications      |
| JACK       | Low-latency audio for professional applications |

### Low-latency settings

```nix
extraConfig.pipewire."10-lowlatency.conf" = {
  "context.properties" = {
    "default.clock.rate"        = 48000;
    "default.clock.quantum"     = 64;
    "default.clock.min-quantum" = 32;
    "default.clock.max-quantum" = 128;
  };
};
```

At 48kHz with a quantum of 64 samples, the theoretical latency is ~1.3ms. The
quantum can drop to 32 samples (~0.7ms) for applications that request it.

## Real-time scheduling

The module enables rtkit and sets PAM limits for the `ada` user:

- **rtprio**: 95 (near-maximum real-time priority)
- **memlock**: unlimited (prevents audio buffer swaps to disk)

These allow PipeWire and JACK applications to run with real-time scheduling
priority, preventing audio dropouts.

## Audient iD24

A udev rule creates a stable symlink for the Audient iD24 USB audio interface:

```
ATTR{idVendor}=="2708", ATTR{idProduct}=="4002", SYMLINK+="audio/audient_id24"
```

WirePlumber is configured to give priority (session priority 2000) to:

- Audient iD24
- Topping USB DAC

This ensures the USB audio interface is selected as the default output device
over built-in audio.

## Audio tools

| Package       | Purpose                            |
| ------------- | ---------------------------------- |
| `pavucontrol` | PulseAudio volume control (GUI)    |
| `qpwgraph`    | PipeWire graph editor (GUI)        |
| `helvum`      | PipeWire patchbay (GUI)            |
| `easyeffects` | Audio effects processor            |
| `pulsemixer`  | Terminal audio mixer               |
| `audacity`    | Audio editor                       |
| `lsp-plugins` | LV2 plugin suite (via home module) |

## Key files

| File                           | Purpose                                         |
| ------------------------------ | ----------------------------------------------- |
| `nix/modules/audio.nix`        | PipeWire, low-latency, udev, WirePlumber, tools |
| `nix/home/cli/audio-tools.nix` | lsp-plugins (home module)                       |
