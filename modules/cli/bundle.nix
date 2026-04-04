{ den, ... }:
{
  den.aspects.cli = {
    includes = [
      den.aspects.bat
      den.aspects.broot
      den.aspects.claude-code
      den.aspects.crypt
      den.aspects.delta
      den.aspects.ghostty
      den.aspects.glow
      den.aspects.helix
      den.aspects.hyfetch
      den.aspects.nix-tree
      den.aspects.prettier
      den.aspects.tree
      den.aspects.audio-tools
    ];
  };
}
