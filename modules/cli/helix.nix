_: {
  den.aspects.helix.homeManager =
    { pkgs, config, ... }:
    {
      home.packages = with pkgs; [ helix ];

      # The garden palette as a Helix theme: garden-themes writes
      # ~/.config/garden/themes/helix/garden.toml on every palette switch
      # and signals running editors to reload (SIGUSR1). The link points
      # at that mutable file, not the store, so switches show up live.
      # On a host without garden.terminal the link dangles and Helix
      # falls back to its default theme.
      xdg.configFile."helix/themes/garden.toml".source =
        config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/garden/themes/helix/garden.toml";

      programs.helix = {
        enable = true;
        defaultEditor = true;
        settings = {
          theme = "garden";
          editor = {
            true-color = true;
            line-number = "relative";
            mouse = false;
            cursor-shape = {
              insert = "bar";
              normal = "underline";
            };
            color-modes = true;
            cursorline = true;
            auto-save = true;
            indent-guides.render = true;
            lsp.display-messages = false;
          };
          keys.normal = {
            space = {
              space = "file_picker";
              w = ":w";
              q = ":q";
            };
            esc = [
              "collapse_selection"
              "keep_primary_selection"
            ];
          };
        };

        languages = {
          debugger = {
            command = "lldb-vscode";
            name = "lldb-vscode";
            transport = "stdio";
            templates = {
              name = "binary";
              request = "launch";
            };
          };
          language = [
            {
              name = "rust";
              auto-format = false;
            }
            {
              name = "markdown";
              auto-format = true;
              formatter = {
                command = "prettier";
                args = [
                  "--parser"
                  "markdown"
                  "--prose-wrap"
                  "always"
                  "--print-width"
                  "80"
                ];
              };
            }
          ];
        };
      };
    };
}
