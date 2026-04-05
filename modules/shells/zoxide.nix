# modules/shells/zoxide.nix — zoxide directory jumper
{ den, ... }:
{
  den.aspects.zoxide.homeManager = { pkgs, ... }:
    {
      programs.zoxide = {
        enable = true;
        enableNushellIntegration = true;
        enableFishIntegration = true;
      };
    };
}
