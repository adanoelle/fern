# modules/audio/audio-studio.nix — low-latency tuning for a recording machine
#
# Opt-in on top of the base `audio` aspect, for a mains-powered machine
# with a dedicated interface. Everything here trades power for latency:
#
#   - musnix forces the `performance` CPU governor, threaded IRQs and
#     realtime limits for the audio group
#   - the PipeWire quantum is pinned low (64 frames, max 128 @ 48 kHz),
#     which also applies to browser and Bluetooth playback
#   - ALSA devices never suspend
#
# Do not put this on a laptop: use the base aspect there and force a
# small quantum per session instead (`pw-metadata -n settings 0
# clock.force-quantum <frames>`).
#
# Hosts may set further musnix options (fern: musnix.rtirq) because the
# musnix module is imported here.
{ den, inputs, ... }:
{
  den.aspects.audio-studio = {
    includes = [ den.aspects.audio ];

    nixos = {
      imports = [ inputs.musnix.nixosModules.musnix ];

      musnix = {
        enable = true;
        rtcqs.enable = true;
      };

      services.pipewire = {
        extraConfig.pipewire."10-lowlatency" = {
          "context.properties" = {
            "default.clock.rate" = 48000;
            "default.clock.quantum" = 64;
            "default.clock.min-quantum" = 32;
            "default.clock.max-quantum" = 128;
          };
        };

        extraConfig.pipewire-pulse."10-lowlatency" = {
          "pulse.properties" = {
            "pulse.default.req" = "64/48000";
            "pulse.min.req" = "32/48000";
            "pulse.max.req" = "128/48000";
            "pulse.min.quantum" = "32/48000";
            "pulse.max.quantum" = "128/48000";
          };
        };

        wireplumber.extraConfig."11-no-suspend" = {
          "monitor.alsa.rules" = [
            {
              matches = [
                { "node.name" = "~alsa_*"; }
              ];
              actions.update-props = {
                "session.suspend-timeout-seconds" = 0;
              };
            }
          ];
        };
      };
    };
  };
}
