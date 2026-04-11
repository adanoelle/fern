# modules/cli/bundle.nix — CLI tools bundle
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
      den.aspects.nix-diff
      den.aspects.nix-tree
      den.aspects.prettier
      den.aspects.tree
      den.aspects.audio-tools

      # Garden terminal stack
      den.aspects.kitty
      den.aspects.kakoune
      den.aspects.yazi
      den.aspects.lazygit
      den.aspects.btop
      den.aspects.fzf
      den.aspects.fd
      den.aspects.ripgrep
      den.aspects.jq
    ];
  };
}
