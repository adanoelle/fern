# nix/modules/desktop/cursor.nix
{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    code-cursor
  ];
}

