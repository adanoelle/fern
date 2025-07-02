# nix/home/cli/crypt.nix
{ pkgs, ... }: {
  home.packages = [ pkgs.age ];
}

