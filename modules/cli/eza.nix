# modules/cli/eza.nix — eza (modern ls replacement)
_: {
  den.aspects.eza.homeManager = _: {
    programs.eza = {
      enable = true;
      icons = "auto";
      git = true;
      extraOptions = [
        "--group-directories-first"
      ];
    };

    programs.fish.shellAbbrs = {
      l = "eza -l";
      la = "eza -la";
      lt = "eza -lT --level=2";
      ll = "eza -l --sort=modified --reverse";
    };
  };
}
