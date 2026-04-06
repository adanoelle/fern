# modules/cli/lazygit.nix — LazyGit garden theme overlay
#
# Base lazygit setup lives in modules/git/tools.nix.
# This aspect only overrides the theme with mokume palette colors.
{ den, ... }:
{
  den.aspects.lazygit.homeManager = { pkgs, lib, ... }: {
    programs.lazygit.settings.gui = {
      showIcons = true;
      border = "single";
      theme = lib.mkForce {
        # Mokume palette
        activeBorderColor = [ "#c9b88c" "bold" ];
        inactiveBorderColor = [ "#4a5568" ];
        searchingActiveBorderColor = [ "#c9b88c" "bold" ];
        optionsTextColor = [ "#6b7a8d" ];
        selectedLineBgColor = [ "#3d4759" ];
        cherryPickedCommitFgColor = [ "#c9b88c" ];
        cherryPickedCommitBgColor = [ "#3d4759" ];
        markedBaseCommitFgColor = [ "#c9b88c" ];
        markedBaseCommitBgColor = [ "#3d4759" ];
        unstagedChangesColor = [ "#c4796b" ];
        defaultFgColor = [ "#8b9bb0" ];
      };
    };
  };
}
