# nix/modules/desktop/claude.nix
{ pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    vscode
  ];
}

