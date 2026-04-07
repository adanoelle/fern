# modules/cli/fzf.nix — fzf fuzzy finder
{ den, inputs, ... }:
let
  palette = inputs.garden-shell.lib.palette.colors;
in
{
  den.aspects.fzf.homeManager = { pkgs, ... }: {
    programs.fzf = {
      enable = true;
      enableFishIntegration = true;

      # Garden palette colors
      defaultOptions = [
        "--color=bg+:${palette.base-hl},bg:${palette.base},spinner:${palette.accent},hl:${palette.urgent}"
        "--color=fg:${palette.text-2},header:${palette.text-3},info:${palette.text-3},pointer:${palette.text-1}"
        "--color=marker:${palette.accent},fg+:${palette.text-1},prompt:${palette.accent},hl+:${palette.urgent}"
        "--color=border:${palette.border}"
        "--border"
      ];
    };
  };
}
