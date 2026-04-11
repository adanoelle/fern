{ den, ... }:
{
  den.aspects.crypt.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.age ];
    };
}
