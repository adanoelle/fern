{ den, ... }:
{
  den.aspects.sqlserver.nixos = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ sql-studio ];
  };
}
