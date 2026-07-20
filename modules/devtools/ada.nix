# modules/devtools/ada.nix — Ada language toolchain
#
# Named ada-lang (not ada-dev) to avoid clashing with the ada-* user
# aspect layers defined in modules/user-ada*.nix.
_: {
  den.aspects.ada-lang = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          gnat13
          gprbuild
          alire
        ];

        environment.variables.ADA_PROJECT_PATH = "$HOME/.config/ada_project_path";
      };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [ alire ];

        programs.helix.languages = {
          language-server.ada_ls = {
            command = "ada_language_server";
          };
          language = [
            {
              name = "ada";
              language-servers = [ "ada_ls" ];
            }
          ];
        };
      };
  };
}
