{ 
  config, 
  pkgs, 
  lib, 
  ... 
}:

let
  # ── 1.  Catppuccin Mocha accent colours ────────────────────────────────────
  # Palette reference: https://lospec.com/palette-list/catppuccin-mocha
  #                    (same hex codes as the upstream spec) :contentReference[oaicite:0]{index=0}
  rosewater = "#f5e0dc";
  flamingo  = "#f2cdcd";
  pink      = "#f5c2e7";
  mauve     = "#cba6f7";
  red       = "#f38ba8";
  maroon    = "#eba0ac";
  peach     = "#fab387";
  yellow    = "#f9e2af";
  green     = "#a6e3a1";
  teal      = "#94e2d5";
  sky       = "#89dceb";
  sapphire  = "#74c7ec";
  blue      = "#89b4fa";
  lavender  = "#b4befe";
in

{
  # Extend the existing programs.git block instead of replacing it
  programs.git.delta = {
    enable = true;          # tells HM to wire up Delta as Git’s pager/diff

    options = {                # becomes the `[delta]` section in ~/.gitconfig
      navigate         = true; # n / N jump between hunks
      line-numbers     = true;
      side-by-side     = true;
      max-line-length  = 0;    # never truncate long lines
      features         = "ada-theme";
    };
  };

  # ── 3.  Define the [delta "ada-theme"] section itself ───────────────
  programs.git.extraConfig."delta \"ada-theme\"" = {
    dark = true;                   # tells Delta we’re on a dark background

    # primary diff colours
    minus-style               = "bold ${red}";
    plus-style                = "bold ${green}";
    hunk-header-style         = "syntax ${mauve}";
    file-style                = "bold ${blue}";
    commit-style              = "bold ${mauve}";

    # gutters / line numbers
    line-numbers-minus-style  = "dim ${maroon}";
    line-numbers-plus-style   = "dim ${teal}";
    line-numbers-zero-style   = "dim ${sky}";
    line-numbers-left-style   = "dim ${yellow}";
    line-numbers-right-style  = "dim ${yellow}";
  };
}

