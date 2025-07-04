{ pkgs, ... }:

{
  home.packages = with pkgs; [
    uv                               # user access too (good for upgrades)
    rye                              # local project creation
    ruff                             # ultra-fast linter/fixer  ❬Rust❭
    black                            # black in daemon mode (for IDE)
    pyright                          # LSP / type checker
    (pkgs.python312Packages.ipython) 
    (pkgs.python312Packages.jupyterlab)
  ];

  ##### Helix integration – new syntax
  programs.helix.languages = {
    language-server.pyright = {
      command = "pyright-langserver";
      args    = [ "--stdio" ];
    };

    language = [
      {
        name             = "python";
        language-servers = [ "pyright" ];
        formatter        = { command = "blackd"; args = [ "-" ]; };
      }
    ];
  };

  ##### rye & uv shell completion (optional)
  programs.zsh.enableCompletion = true;
}

