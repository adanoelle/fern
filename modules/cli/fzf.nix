# modules/cli/fzf.nix — fzf fuzzy finder
{ den, ... }:
{
  den.aspects.fzf.homeManager =
    { pkgs, ... }:
    {
      programs.fzf = {
        enable = true;
        enableFishIntegration = true;
        # Colors managed by garden.terminal aspect (FZF_DEFAULT_OPTS set
        # from mutable fzf theme file sourced in fish init).
      };
    };
}
