# nix/home/cli/devenv.nix
{ pkgs, inputs, ... }:
{
  # Always add devenv; if you want a toggle, add an option here.
  home.packages = [
    inputs.devenv.packages.${pkgs.stdenv.hostPlatform.system}.devenv
  ];
}

