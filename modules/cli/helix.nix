_: {
  den.aspects.helix.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [ helix ];

      programs.helix = {
        enable = true;
        defaultEditor = true;
        settings = {
          theme = "catppuccin_frappe";
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
