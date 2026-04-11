# modules/cli/nh.nix — nh: NixOS rebuild helper with smart clean
{ den, ... }:
{
  den.aspects.nh.nixos = {
    programs.nh = {
      enable = true;
      flake = "/home/ada/src/fern";
      clean = {
        enable = true;
        dates = "weekly";
        extraArgs = "--keep 5 --keep-since 7d";
      };
    };
  };
}
