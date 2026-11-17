# modules/audio/music.nix — music production user layer
#
# DAWs plus the plugin/synth collection. Opt-in per host or user layer:
# a machine that only needs working sound takes the system `audio`
# aspect and skips this.
{ den, ... }:
{
  den.aspects.music.includes = [
    den.aspects.daw
    den.aspects.audio-tools
  ];
}
