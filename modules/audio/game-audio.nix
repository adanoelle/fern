# modules/audio/game-audio.nix — chiptune and sound-effect tools
#
# The light set for writing game music and effects, separate from the
# full `music` layer (DAWs plus the plugin collection) so a laptop can
# take this alone and add `music` later.
_: {
  den.aspects.game-audio.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # Trackers
        famistudio
        furnace

        # Sound effects (sfxr-qt can also export from the command line)
        sfxr-qt

        # Arranging, editing and mastering
        reaper

        # Conversion and loudness measurement
        ffmpeg
        sox
      ];
    };
}
