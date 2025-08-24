# nix/modules/desktop/sqlserver.nix
{ pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    sql-studio
  ];
}

