_: {
  den.aspects.teams = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [ teams-for-linux ];
      };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.teams-for-linux ];
      };
  };
}
