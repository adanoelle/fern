{ self, ... }: {
  flake.homeModules = {
    shells = import ../nix/home/shells.nix;
    git    = import ../nix/home/git.nix;
  };
}
