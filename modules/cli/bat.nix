{ den, ... }:
{
  den.aspects.bat.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.bat ];
      programs.man.enable = true;
      home.sessionVariables.MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    };
}
