# nix/modules/desktop/claude.nix
{ pkgs, inputs, ... }:

{
  environment.systemPackages = [
    inputs.claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop-with-fhs
  ];
}

