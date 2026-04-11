{ den, ... }:
{
  den.aspects.zig.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.zig ];
    };
}
