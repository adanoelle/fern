{ den, ... }:
{
  den.aspects.python = {
    nixos = { pkgs, ... }:
      let python = pkgs.python312;
      in
      {
        environment.systemPackages = with pkgs; [
          python
          uv
        ];
      };

    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        uv rye ruff black pyright
        (pkgs.python312Packages.ipython)
        (pkgs.python312Packages.jupyterlab)
      ];

      programs.helix.languages = {
        language-server.pyright = {
          command = "pyright-langserver";
          args = [ "--stdio" ];
        };
        language = [
          {
            name = "python";
            language-servers = [ "pyright" ];
            formatter = { command = "blackd"; args = [ "-" ]; };
          }
        ];
      };

      programs.zsh.enableCompletion = true;
    };
  };
}
