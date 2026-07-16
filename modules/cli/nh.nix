# modules/cli/nh.nix — nh: NixOS rebuild helper with smart clean
{ den, ... }:
{
  den.aspects.nh.nixos =
    { lib, ... }:
    {
      programs.nh = {
        enable = true;
        # mkDefault is safe here (cf. the trusted-users note in core.nix):
        # upstream declares programs.nh.flake as `nullOr str` with an
        # OPTION default of null and never defines it, so nothing competes
        # at normal priority. Hosts where the checkout lives elsewhere
        # just set programs.nh.flake plainly.
        flake = lib.mkDefault "/home/ada/src/fern";
        clean = {
          enable = true;
          dates = "weekly";
          extraArgs = "--keep 5 --keep-since 7d";
        };
      };
    };
}
