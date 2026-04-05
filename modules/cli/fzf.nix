# modules/cli/fzf.nix — fzf fuzzy finder
{ den, ... }:
{
  den.aspects.fzf.homeManager = { pkgs, ... }: {
    programs.fzf = {
      enable = true;
      enableFishIntegration = true;

      # Mokume palette colors
      defaultOptions = [
        "--color=bg+:#3d4759,bg:#2c3444,spinner:#c9b88c,hl:#c4796b"
        "--color=fg:#8b9bb0,header:#6b7a8d,info:#6b7a8d,pointer:#d4c5a9"
        "--color=marker:#c9b88c,fg+:#d4c5a9,prompt:#c9b88c,hl+:#c4796b"
        "--color=border:#4a5568"
        "--border"
      ];
    };
  };
}
