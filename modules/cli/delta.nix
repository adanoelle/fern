# modules/cli/delta.nix — delta (git diff viewer) garden theme
#
# Maps garden palette colors to delta's theme settings. Uses the
# bat-generated garden tmTheme for syntax highlighting.
{ den, inputs, ... }:
let
  palette = inputs.garden-shell.lib.palette.colors;
in
{
  den.aspects.delta.homeManager = { lib, ... }: {
    programs.git.delta = {
      enable = true;
      options = {
        navigate = true;
        line-numbers = true;
        side-by-side = true;
        max-line-length = 0;
        syntax-theme = lib.mkForce "garden";
        features = "ada-theme";
      };
    };

    programs.git.extraConfig."delta \"ada-theme\"" = {
      dark = true;
      minus-style = "bold ${palette.urgent}";
      plus-style = "bold ${palette.ok}";
      hunk-header-style = "syntax ${palette.text-3}";
      file-style = "bold ${palette.text-1}";
      commit-style = "bold ${palette.accent}";
      line-numbers-minus-style = "dim ${palette.urgent}";
      line-numbers-plus-style = "dim ${palette.ok}";
      line-numbers-zero-style = "dim ${palette.text-4}";
      line-numbers-left-style = "dim ${palette.text-3}";
      line-numbers-right-style = "dim ${palette.text-3}";
    };
  };
}
