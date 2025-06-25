{ pkgs, ... }: {
  home.packages = [ pkgs.bat ];

  # Optional: use bat as manpager
  programs.man.enable = true;
  home.sessionVariables.MANPAGER = "sh -c 'col -bx | bat -l man -p'";
}

