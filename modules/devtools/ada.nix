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

        # No Helix configuration: its built-in `ada` entry already looks
        # for `ada_language_server` on PATH. nixpkgs has no package for
        # that server, so there is none until one is installed by other
        # means (AdaCore publishes prebuilt releases).
      };
  };
}
