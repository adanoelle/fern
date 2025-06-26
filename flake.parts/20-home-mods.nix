{ self, ... }: {
  flake.homeModules = {
    shells    = import ../nix/home/shells.nix;
    cli       = import ../nix/home/cli.nix;
    workspace = import ../nix/home/workspace.nix;
  };
}
