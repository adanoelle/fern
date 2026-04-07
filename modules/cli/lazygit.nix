# modules/cli/lazygit.nix — LazyGit garden theme overlay
#
# Base lazygit setup lives in modules/git/tools.nix.
# This aspect only overrides the theme with garden palette colors.
{ den, inputs, ... }:
let
  palette = inputs.garden-shell.lib.palette.colors;
in
{
  den.aspects.lazygit.homeManager = { pkgs, lib, ... }: {
    programs.lazygit.settings.gui = {
      showIcons = true;
      border = "single";
      theme = lib.mkForce {
        activeBorderColor = [ "${palette.accent}" "bold" ];
        inactiveBorderColor = [ "${palette.border}" ];
        searchingActiveBorderColor = [ "${palette.accent}" "bold" ];
        optionsTextColor = [ "${palette.text-3}" ];
        selectedLineBgColor = [ "${palette.base-hl}" ];
        cherryPickedCommitFgColor = [ "${palette.accent}" ];
        cherryPickedCommitBgColor = [ "${palette.base-hl}" ];
        markedBaseCommitFgColor = [ "${palette.accent}" ];
        markedBaseCommitBgColor = [ "${palette.base-hl}" ];
        unstagedChangesColor = [ "${palette.urgent}" ];
        defaultFgColor = [ "${palette.text-2}" ];
      };
    };
  };
}
