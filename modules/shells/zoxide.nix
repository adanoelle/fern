# modules/shells/zoxide.nix — zoxide directory jumper
_: {
  den.aspects.zoxide.homeManager = _: {
    programs.zoxide = {
      enable = true;
      enableNushellIntegration = true;
      enableFishIntegration = true;
    };
  };
}
