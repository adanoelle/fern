{ den, ... }:
{
  den.aspects.glow.homeManager = { pkgs, ... }: {
    home.packages = with pkgs; [ glow ];
  };
}
