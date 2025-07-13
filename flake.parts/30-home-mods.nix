{ self, ... }: {
  flake.homeModules = {
    desktop   = import ../nix/home/desktop.nix;
    devtools  = import ../nix/home/devtools.nix;
    shells    = import ../nix/home/shells.nix;
    cli       = import ../nix/home/cli.nix;
    workspace = import ../nix/home/workspace.nix;
  };
}
