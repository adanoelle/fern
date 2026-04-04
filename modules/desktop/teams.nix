{ den, ... }:
{
  den.aspects.teams.nixos = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ teams-for-linux ];
  };
}
