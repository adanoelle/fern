# modules/shells/bundle.nix — shell environment bundle
{ den, ... }:
{
  den.aspects.shells = {
    includes = [
      den.aspects.nushell
      den.aspects.starship
      den.aspects.zoxide
      den.aspects.devenv
      den.aspects.fish
    ];
  };
}
