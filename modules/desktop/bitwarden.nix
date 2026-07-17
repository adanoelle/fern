# modules/desktop/bitwarden.nix — Bitwarden desktop app
{ den, ... }:
{
  den.aspects.bitwarden.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.bitwarden-desktop ];
    };
}
