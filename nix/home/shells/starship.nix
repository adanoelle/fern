{ pkgs, ... }:
{
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      # prompt style tweaks
      format = "$directory$character";
    };
  };
}

