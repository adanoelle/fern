{ den, ... }:
{
  den.aspects.gaming-hm.homeManager = { pkgs, ... }: {
    home.packages = with pkgs; [
      mangohud
      protonup-qt
      lutris
      protontricks
    ];
  };
}
