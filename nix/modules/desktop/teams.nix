# nix/modules/desktop/teams.nix
#
# Microsoft Teams
{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    teams-for-linux
  ];
}

