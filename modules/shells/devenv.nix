# modules/shells/devenv.nix — devenv development environment manager
{ den, ... }:
{
  den.aspects.devenv.homeManager =
    { pkgs, inputs, ... }:
    {
      # Always add devenv; if you want a toggle, add an option here.
      home.packages = [
        inputs.devenv.packages.${pkgs.stdenv.hostPlatform.system}.devenv
      ];
    };
}
