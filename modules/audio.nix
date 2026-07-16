# modules/audio.nix — PipeWire pro audio stack with musnix tuning
{ den, inputs, ... }:
{
  den.aspects.audio.nixos =
    { pkgs, ... }:
    {
      imports = [ inputs.musnix.nixosModules.musnix ];

      musnix = {
        enable = true;
        rtcqs.enable = true;
      };

      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;

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

        wireplumber.extraConfig."10-default-nodes" = {
          "monitor.alsa.rules" = [
            {
              matches = [
                { "node.nick" = "~Audient iD24*"; }
              ];
              actions.update-props = {
                "priority.session" = 2000;
              };
            }
            {
              matches = [
                { "node.nick" = "~USB-Audio - Topping*"; }
              ];
              actions.update-props = {
                "priority.session" = 2000;
              };
            }
          ];
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

      security.rtkit.enable = true;

      # "audio" group membership is granted centrally in modules/users.nix,
      # conditional on services.pipewire.enable.

      environment.systemPackages = with pkgs; [
        audacity
        qpwgraph
        pavucontrol
        easyeffects
        pulsemixer
      ];
    };
}
