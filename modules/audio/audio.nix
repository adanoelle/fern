# modules/audio/audio.nix — PipeWire base audio stack
#
# The layer every machine with sound gets: PipeWire (ALSA, Pulse and
# JACK front ends), realtime scheduling via rtkit, and the everyday
# mixer/patchbay tools. It carries no latency tuning and no hardware
# facts, so it is safe on a laptop running on battery.
#
#   audio-studio  low-latency tuning for a dedicated recording machine
#   music         DAWs, plugins and synths (user layer)
#   host-*.nix    per-device rules (interface priorities, udev)
#
# The `key` lets the NixOS module system deduplicate this aspect when it
# is reached twice (workstation role + audio-studio); see the note in
# modules/tailscale.nix.
_: {
  den.aspects.audio.nixos =
    { pkgs, ... }:
    {
      key = "den-aspect:audio";
      config = {
        services.pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
          jack.enable = true;
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
    };
}
