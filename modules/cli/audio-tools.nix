# modules/cli/audio-tools.nix — audio plugins and production tools
_: {
  den.aspects.audio-tools.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # Analysis & processing
        lsp-plugins
        zam-plugins
        calf
        x42-plugins

        # Effects
        dragonfly-reverb
        wolf-shaper

        # Synthesizers
        surge-XT
        vital
        helm
        zynaddsubfx

        # Samplers & drums
        sfizz
        x42-avldrums

        # Plugin hosting & MIDI
        # carla - broken: cython 0.29.x incompatible with python 3.13
        a2jmidid

        # Audio utilities
        sox
        ffmpeg
      ];
    };
}
