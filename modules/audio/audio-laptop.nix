# modules/audio/audio-laptop.nix — audio extras for a laptop
#
# Sits on the base `audio` aspect (which the workstation role provides)
# and deliberately adds no latency tuning: a laptop on battery keeps
# PipeWire's defaults.
#
#   - A noise-suppressed virtual microphone (RNNoise) for calls on the
#     built-in mic. It is an extra source to pick in an application;
#     the default device is not changed.
#   - `studio-mode`, which forces a small buffer while an audio
#     interface is plugged in for recording, and releases it afterwards.
_: {
  den.aspects.audio-laptop.nixos =
    { pkgs, ... }:
    let
      studio-mode = pkgs.writeShellApplication {
        name = "studio-mode";
        runtimeInputs = [ pkgs.pipewire ];
        text = ''
          case "''${1:-status}" in
            on)
              pw-metadata -n settings 0 clock.force-rate 48000 > /dev/null
              pw-metadata -n settings 0 clock.force-quantum "''${2:-128}" > /dev/null
              echo "studio mode on: 48 kHz, ''${2:-128} frames"
              ;;
            off)
              pw-metadata -n settings 0 clock.force-quantum 0 > /dev/null
              pw-metadata -n settings 0 clock.force-rate 0 > /dev/null
              echo "studio mode off: PipeWire defaults"
              ;;
            status)
              pw-metadata -n settings 0 | grep -E "clock\.force-(quantum|rate)" || true
              ;;
            *)
              echo "usage: studio-mode [on [frames] | off | status]" >&2
              exit 1
              ;;
          esac
        '';
      };
    in
    {
      environment.systemPackages = [ studio-mode ];

      services.pipewire.extraConfig.pipewire."60-mic-denoise" = {
        "context.modules" = [
          {
            name = "libpipewire-module-filter-chain";
            args = {
              "node.description" = "Noise-suppressed microphone";
              "media.name" = "Noise-suppressed microphone";
              "filter.graph".nodes = [
                {
                  type = "ladspa";
                  name = "rnnoise";
                  plugin = "${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so";
                  label = "noise_suppressor_mono";
                  control = {
                    "VAD Threshold (%)" = 50.0;
                    "VAD Grace Period (ms)" = 200;
                    "Retroactive VAD Grace (ms)" = 0;
                  };
                }
              ];
              "capture.props" = {
                "node.name" = "capture.mic_denoise";
                "node.passive" = true;
                "audio.rate" = 48000;
              };
              "playback.props" = {
                "node.name" = "mic_denoise";
                "media.class" = "Audio/Source";
                "audio.rate" = 48000;
              };
            };
          }
        ];
      };
    };
}
